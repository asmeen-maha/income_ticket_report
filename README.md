# Income Report

แอปสำหรับฝ่ายรายรับ ใช้ตรวจสอบเงินที่ผู้จำหน่ายบัตรนำส่งในแต่ละวัน และพิมพ์ใบนำส่งรายได้ฝ่ายบัตร (รายคน, A4 แนวนอน) กับใบสรุปส่งเงินรายได้ (ทั้งวัน, A4 แนวตั้ง)

Flutter 3.24 · ใช้งานผ่านเว็บในเครือข่ายภายในบริษัท

## Build สำหรับใช้งานจริง

```sh
flutter build web --release --pwa-strategy=none
```

นำทุกไฟล์ใน `build/web/` ไปวางบน web server ภายใน ถ้าไม่ได้วางที่ root ของเว็บ ให้เพิ่ม `--base-href /path/ที่วาง/`

ถ้าต้องเปลี่ยนที่อยู่ API โดยไม่แก้โค้ด:

```sh
flutter build web --release --pwa-strategy=none \
  --dart-define=SELF_TICKETING_URL=http://<host>/cmfrontapp/ticketing/ticketapi/datamodule/selfticketing.php \
  --dart-define=MARKETING_URL=http://<host>/clientele_cm/marketing.php
```

## ไม่เรียกใช้อินเทอร์เน็ตภายนอก

ทุกอย่างโหลดจากเซิร์ฟเวอร์ภายใน ตรวจแล้วด้วย Chrome ที่ตัดอินเทอร์เน็ต:

| สิ่งที่ปกติ Flutter / แพ็กเกจจะโหลดจากเน็ต | จัดการไว้ที่ |
|---|---|
| CanvasKit (`www.gstatic.com/flutter-canvaskit`) | `web/flutter_bootstrap.js` → `canvasKitBaseUrl: "canvaskit/"` |
| ฟอนต์ Roboto ตอนเปิดแอป (`fonts.gstatic.com`) | `pubspec.yaml` ประกาศ family `Roboto` ชี้ไปที่ฟอนต์ในแอป |
| ฟอนต์สำรองเมื่อไม่มีตัวอักษร (`fonts.gstatic.com`) | `web/flutter_bootstrap.js` → `fontFallbackBaseUrl` ชี้ภายใน |
| pdf.js สำหรับแสดง PDF (`unpkg.com`) | `web/index.html` โหลด `assets/pdfjs/pdf.min.js` เอง (ห้ามใช้ `dartPdfJsBaseUrl` ของ printing 5.14.2 เพราะมีบั๊ก error `type 'String' is not a subtype of type 'Never'`) |
| ฟอนต์ UI (Prompt, Noto Sans Thai) | อยู่ใน `assets/fonts/` (SIL OFL, ไฟล์ license อยู่ข้างกัน) |

ข้อควรระวัง
- **เปิดแอปผ่าน `http://` เท่านั้น** ถ้าเปิดผ่าน `https://` เบราว์เซอร์จะบล็อกการเรียก API ที่เป็น `http://` (mixed content)
- API ต้องตอบ header `Access-Control-Allow-Origin` (ปัจจุบันตั้งเป็น `*` แล้ว) ถ้าย้ายเซิร์ฟเวอร์ต้องคงไว้
- ไม่มี service worker แล้ว deploy เวอร์ชันใหม่ ผู้ใช้กด reload ก็ได้ของใหม่ ควรตั้ง web server ให้ `index.html` และ `flutter_bootstrap.js` ส่ง `Cache-Control: no-cache`

## รูปพนักงาน

รูปโหลดจาก `http://172.2.200.50/personpic/<รหัสพนักงาน>.jpg` เช่น `F00424.jpg`

เซิร์ฟเวอร์รูป (nginx) **ยังไม่ส่ง header CORS** ตัววาดภาพของ Flutter (CanvasKit) จึงโหลดรูปไม่ได้ ใน console จะเห็น `[object ProgressEvent]` แอปจะสลับไปแสดงรูปด้วยแท็ก `<img>` ของ HTML ซึ่งไม่ต้องใช้ CORS ให้อัตโนมัติ รูปจึงขึ้นแม้ไม่ได้แก้เซิร์ฟเวอร์ และใน console จะมีข้อความว่า `Staff photos: the browser blocked ...`

ทาง `<img>` ใช้งานได้ปกติ แต่ทาง Flutter เร็วกว่าและใช้หน่วยความจำน้อยกว่า เพราะถอดรหัสรูปที่ 96 px และไม่ต้องสร้าง HTML element ต่อรูป ถ้าทำได้ แนะนำแก้ที่เซิร์ฟเวอร์ 1 ใน 2 ทาง:

**ทาง A: เพิ่ม header ที่ nginx ของ 172.2.200.50** (ง่ายที่สุด ไม่ต้อง build ใหม่)

```nginx
location /personpic/ {
    add_header Access-Control-Allow-Origin *;
    add_header Cache-Control "public, max-age=86400";
}
```

**ทาง B: ให้ web server ที่วางแอป proxy `/personpic/` ไปที่ 172.2.200.50** แล้ว build ด้วย

```sh
flutter build web --release --pwa-strategy=none --dart-define=PHOTO_BASE_URL=personpic/
```

ปิดการแสดงรูปทั้งหมดได้ด้วย `--dart-define=PHOTO_BASE_URL=`

Performance ของรูป
- ถอดรหัสรูปที่ความกว้าง 96 px แทนขนาดเต็ม ใช้ cache ร่วมกันทุกจุดที่แสดงรูปคนเดียวกัน
- รายชื่อสร้างแถวแบบ lazy โหลดรูปเฉพาะแถวที่มองเห็น
- รูปที่ไม่มีอยู่จริง (404) จะถูกจำไว้ ไม่ยิงซ้ำ และเขียนสาเหตุลง console ครั้งเดียว
- ถ้าเจอ CORS ครั้งแรก รูปที่เหลือจะไปใช้ `<img>` ทันที ไม่ยิงรอบที่ล้มซ้ำ
- ระหว่างรอรูปจะแสดงอักษรย่อ รูปมาแล้วค่อย fade เข้า หน้าจอไม่กระตุก

## โครงสร้างโค้ด

```
lib/
├─ core/       config (URL API, timeout) · constants · theme · utils
├─ data/       models · services/income_api.dart
├─ features/home/
│   ├─ home_controller.dart   state + logic (ChangeNotifier)
│   ├─ home_page.dart         ประกอบหน้าจอ
│   └─ widgets/
└─ reports/    สร้าง PDF: daily_income/ · seller_income/
```

## ทดสอบ

```sh
flutter analyze
flutter test
```
