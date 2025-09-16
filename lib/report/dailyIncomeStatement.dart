import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import '../util/dateformat.dart';
import 'footer/footerDailyIncome.dart';
import 'header/headerDailyIncome.dart';

class NoteCoinsData {
  final double amount;
  final String qty;

  NoteCoinsData({required this.amount, required this.qty});
}

class DailyIncome {

  Future<Uint8List> genPDFDailyIncome({required DateTime date, required String title}) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final logoblack = pw.MemoryImage((await rootBundle.load('assets/images/Cashier_size-M.jpg')).buffer.asUint8List());
    final pgvim = await rootBundle.load("assets/fonts/pgvim.ttf");
    final trajanpro = await rootBundle.load("assets/fonts/trajanpro-regular.ttf");
    final trajanprobold = await rootBundle.load("assets/fonts/trajanpro-bold.ttf");
    final pgVim = pw.Font.ttf(pgvim);
    final traJanPro = pw.Font.ttf(trajanpro);
    final traJanProBold = pw.Font.ttf(trajanprobold);


    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.portrait,
        margin: const pw.EdgeInsets.only(top: .5 * PdfPageFormat.cm, left: .9 * PdfPageFormat.cm, right: .9 * PdfPageFormat.cm, bottom: .5 * PdfPageFormat.cm),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: headerDailyIncome(context, pgVim, traJanPro, traJanProBold, logoblack, date, title)
          );
        },
        build: (pw.Context context) {
          return bodyReport(context, pgVim, traJanPro, traJanProBold);
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              footerDailyIncome(context, pgVim, traJanPro, traJanProBold)
            ]
          );
        },
      )
    );
    
    return pdf.save();
  }

  List<pw.Widget> bodyReport(pw.Context context, pw.Font pgVim, pw.Font traJanPro, pw.Font traJanProBold) {
    List<String> coins = ['1000.00', '500.00', '100.00', '50.00', '20.00', '10.00', '5.00', '2.00', '1.00', '0.50', '0.25'];
    List<String> coinsTotal = ['รวมเงินไทย /Sub Total', 'เงินต่างประเทศ /Foreign Currency', 'รวมเงิน /Total'];
    List<String> payType =['บัตรเครดิต /Credit Card', 'E-Shop', 'ชำระเงินผ่านธนาคาร /PAY IN', 'ลูกหนี้(เรียกเก็บเงิน) Voucher', 'เช็ค /Cheque', 'เอฟซีคอยน์ /FCcoin', 'รวมรายได้ทั้งสิ้น /Grand Total'];

    pw.Widget buildTitle(String title, String titleEng, double width){
      return pw.Container(
        width: width,
        height: 40,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          // border: pw.Border(left: titleEng == 'Type' ? const pw.BorderSide(width: .5) : pw.BorderSide.none, bottom: const pw.BorderSide(width: .5), right: const pw.BorderSide(width: .5))
          border: pw.Border.all(width: .5)
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(title, style: pw.TextStyle(font: pgVim, fontSize: 10)),
            pw.Text(titleEng, style: pw.TextStyle(font: traJanPro, fontSize: 10)),
          ]
        )
      );
    }

    pw.Widget buildBody(String title, double width, {double height = 20, pw.Alignment alignment = pw.Alignment.center, pw.EdgeInsets padding = const pw.EdgeInsets.only(right: 0)}){
      return pw.Container(
        width: width,
        height: height,
        alignment: alignment,
        padding: padding,
        decoration: pw.BoxDecoration(
          // border: pw.Border(left: pw.BorderSide(width: .5), bottom: pw.BorderSide(width: .5), right: pw.BorderSide(width: .5))
          border: pw.Border.all(width: .5)
        ),
        child: pw.Text(title, style: pw.TextStyle(font: pgVim, fontSize: 10)),
      );
    }

    double boxTitle = 180;
    double boxTitle2 = 360;

    return <pw.Widget>[
      pw.Container(
        width: 600,
        height: 30,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: .5)
        ),
        child: pw.Text('ธนบัตรและเหรียญกษาปณ์ /Notes & Coins', style: pw.TextStyle(font: pgVim, fontSize: 12))
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          buildTitle('ชนิด', 'Type', boxTitle),
          buildTitle('จำนวน', 'Quantity', boxTitle),
          buildTitle('รวมเงิน (บาท)', 'Amount (Bath)', 184.3),
        ]
      ),
      ...List.generate(coins.length, (index) {
        final data = coins[index];

        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            buildBody(data, boxTitle),
            buildBody('0', boxTitle),
            buildBody(formatter.format(0), 184.3, alignment: pw.Alignment.centerRight, padding: const pw.EdgeInsets.only(right: 10)),
          ]
        );
      }),
      ...List.generate(coinsTotal.length, (index) {
        final title = coinsTotal[index];
        
        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            buildBody(title, boxTitle2),
            buildBody(formatter.format(0), 184.3, alignment: pw.Alignment.centerRight, padding: const pw.EdgeInsets.only(right: 10)),
          ]
        );
      }),
      pw.SizedBox(height: 10),
      ...List.generate(payType.length, (index) {
        final title = payType[index];

        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            buildBody(title, boxTitle2),
            buildBody(formatter.format(0), 184.3, alignment: pw.Alignment.centerRight, padding: const pw.EdgeInsets.only(right: 10)),
          ]
        );
      }),
      pw.SizedBox(height: 10),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          buildBody('ชื่อผู้นำส่ง /Submitted by', boxTitle2),
          buildBody('ชื่อผู้รับ /Received by', 184.3),
        ]
      ),
      ...List.generate(2, (index) {
        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            buildBody('1 ___________________________________________', boxTitle2, height: 30, alignment: pw.Alignment.centerLeft, padding: const pw.EdgeInsets.only(left: 10)),
            buildBody('2 ______________________', 184.3, height: 30, alignment: pw.Alignment.centerLeft, padding: const pw.EdgeInsets.only(left: 10)),
          ]
        );
      }),
      pw.SizedBox(height: 15),
      pw.Text('หมายเหตุ /Remarks', style: pw.TextStyle(font: pgVim, fontSize: 10)),
      pw.SizedBox(height: 5),
      pw.Divider(thickness: .5),
      pw.SizedBox(height: 5),
      pw.Divider(thickness: .5),
    ];
  }
}