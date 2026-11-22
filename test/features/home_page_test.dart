import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:income_report/core/theme/app_theme.dart';
import 'package:income_report/data/models/booking_payment.dart';
import 'package:income_report/data/models/pay_type.dart';
import 'package:income_report/data/models/seller_transaction.dart';
import 'package:income_report/data/services/income_api.dart';
import 'package:income_report/data/services/seller_photos.dart';
import 'package:income_report/features/home/home_controller.dart';
import 'package:income_report/features/home/home_page.dart';

SellerTransaction _seller(String id, String code, String name, {bool verified = false}) =>
    SellerTransaction.fromJson({
      'userid': id,
      'code': code,
      'name': name,
      if (verified) 'flagcheck': 'Y',
      'creditcard': [{'amount': '1000'}],
      'notesandcoins': [{'ntype': '1000', 'qty': '2', 'amount': '2000'}],
      'payeshop': [
        {'referno': 'abc', 'amount': '300'},
        {'referno': 'payIn', 'amount': '200'},
      ],
    });

class _FakeApi extends IncomeApi {
  _FakeApi(this.sellers);

  List<SellerTransaction> sellers;
  Object? failWith;
  final verifiedIds = <String>[];

  @override
  Future<List<SellerTransaction>> fetchAllTransactions({required String date}) async {
    if (failWith != null) throw failWith!;
    return sellers;
  }

  @override
  Future<SellerTransaction?> fetchSellerTransaction({
    required String date,
    required String userId,
  }) async =>
      sellers.firstWhere((s) => s.userId == userId);

  @override
  Future<List<BookingPayment>> fetchBookingPayments({
    required String userId,
    required String bookDate,
  }) async =>
      const [];

  @override
  Future<List<PayType>> fetchPayTypes() async => const [];

  @override
  Future<void> setSellerVerified({
    required String date,
    required String userId,
    required String flag,
  }) async {
    verifiedIds.add(userId);
    sellers = [
      for (final s in sellers)
        s.userId == userId ? _seller(s.userId, s.code, s.name, verified: true) : s,
    ];
  }
}

void main() {
  late _FakeApi api;

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: HomePage(controller: HomeController(api: api)),
    ));
    await tester.pump();
    await tester.pump();
  }

  setUp(() {
    SellerPhotos.baseUrl = ''; // no network images in page tests
    api = _FakeApi([
      _seller('1', 'F001', 'สมชาย ตัวอย่าง'),
      _seller('2', 'F002', 'สมหญิง ทดสอบ', verified: true),
    ]);
  });

  testWidgets('shows KPI tiles and sellers grouped by status', (tester) async {
    await pumpHome(tester);

    expect(find.text('ยอดรวมทั้งวัน · Day total'), findsOneWidget);
    // Day total = 2 sellers × (2,000 cash + 1,000 card + 500 e-shop).
    expect(find.text('7,000.00'), findsOneWidget);
    expect(find.text('รอตรวจอีก 1 คน'), findsOneWidget);
    expect(find.text('สมชาย ตัวอย่าง'), findsOneWidget);
    expect(find.text('สมหญิง ทดสอบ'), findsOneWidget);
    expect(find.text('รอตรวจ'), findsOneWidget);
  });

  testWidgets('search filters the seller list', (tester) async {
    await pumpHome(tester);

    await tester.enterText(find.byType(TextField), 'F002');
    await tester.pump();

    expect(find.text('สมชาย ตัวอย่าง'), findsNothing);
    expect(find.text('สมหญิง ทดสอบ'), findsOneWidget);
  });

  testWidgets('selecting a seller shows the breakdown; verify goes through the dialog',
      (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('สมชาย ตัวอย่าง'));
    await tester.pump();
    await tester.pump();

    expect(find.text('F001 · เงินสด Cash'), findsOneWidget);
    expect(find.text('รอตรวจสอบ'), findsOneWidget);

    await tester.tap(find.text('ยืนยันตรวจสอบ'));
    await tester.pump();
    expect(find.text('ยืนยันตรวจสอบรายการ'), findsOneWidget);
    expect(find.text('ยืนยันแล้วจะแก้ไขหรือยกเลิกไม่ได้'), findsOneWidget);

    await tester.tap(find.text('ยืนยัน'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(api.verifiedIds, ['1']);
    expect(find.text('ยืนยันตรวจสอบรายการ'), findsNothing);
    expect(find.text('ตรวจสอบแล้ว'), findsWidgets);
  });

  testWidgets('cancel in the verify dialog does not call the API', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text('สมชาย ตัวอย่าง'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('ยืนยันตรวจสอบ'));
    await tester.pump();
    await tester.tap(find.text('กลับ'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(api.verifiedIds, isEmpty);
  });

  testWidgets('empty day shows the empty state', (tester) async {
    api.sellers = [];
    await pumpHome(tester);

    expect(find.text('ไม่พบข้อมูล'), findsOneWidget);
    expect(find.text('เลือกวันอื่น'), findsOneWidget);
    // Already today, so there is no "back to today".
    expect(find.text('กลับไปวันนี้'), findsNothing);
  });

  testWidgets('load failure shows the error state and retry recovers', (tester) async {
    api.failWith = Exception('timeout');
    await pumpHome(tester);

    expect(find.text('เกิดข้อผิดพลาด'), findsOneWidget);

    api.failWith = null;
    await tester.tap(find.text('ลองอีกครั้ง'));
    await tester.pump();
    await tester.pump();

    expect(find.text('สมชาย ตัวอย่าง'), findsOneWidget);
  });

  testWidgets('daily statement button is locked until someone is verified', (tester) async {
    api.sellers = [_seller('1', 'F001', 'สมชาย ตัวอย่าง')];
    await pumpHome(tester);

    expect(find.text('ใช้ได้เมื่อตรวจสอบแล้วอย่างน้อย 1 คน'), findsOneWidget);
  });
}
