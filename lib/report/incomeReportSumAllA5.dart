import 'package:income_report/util/dateformat.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import '../model/mdTransactionSumAll.dart';
import 'footer/footerA5.dart';
import 'header/headerA5.dart';

class NoteCoinsData {
  final double amount;
  final String qty;

  NoteCoinsData({required this.amount, required this.qty});
}

class IncomReportSumAllA5 {

  Future<Uint8List> genPDFTransactionSumAllA5({required DateTime date, required String title, required List<TransactionSumAll> sumAll}) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final logoblack = pw.MemoryImage((await rootBundle.load('assets/images/Ticketing.jpg')).buffer.asUint8List());
    final pgvim = await rootBundle.load("assets/fonts/pgvim.ttf");
    final trajanpro = await rootBundle.load("assets/fonts/trajanpro-regular.ttf");
    final trajanproBold = await rootBundle.load("assets/fonts/trajanpro-bold.ttf");
    final pgVim = pw.Font.ttf(pgvim);
    final traJanPro = pw.Font.ttf(trajanpro);
    final traJanProBold = pw.Font.ttf(trajanproBold);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.only(top: .5 * PdfPageFormat.cm, left: .45 * PdfPageFormat.cm, right: .5 * PdfPageFormat.cm, bottom: .5 * PdfPageFormat.cm),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: headerReportIncomeA5(context, 'รวมใบนำส่งรายได้ฝ่ายบัตร', 'All Income Report', date, logoblack, pgVim, traJanPro, '', '', chk: 1)
          );
        },
        build: (pw.Context context) {
          return bodyReport(context, pgVim, traJanPro, sumAll, traJanProBold);
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              footerReportA5(context, pgVim, traJanPro, 'Income Report', date, ''),
            ]
          );
        },
      )
    );

    return pdf.save();
  }

  List<pw.Widget> bodyReport(pw.Context context, pw.Font pgVim, pw.Font traJanPro, List<TransactionSumAll> data, pw.Font traJanProBold) {
    NoteCoinsData buildNoteCoinsData(String coins) {
      double amount = 0.0;
      String qty = '0';

      try {
        if (data[0].notesandcoins!.isNotEmpty) {
          var note = data[0].notesandcoins!.firstWhere(
            (n) => n.ntype == coins,
            orElse: () => Notesandcoinss(),
          );

          amount = double.tryParse(note.amount!) ?? 0;
          qty = note.qty!;
        }
      } catch (e) {
        // print('Error: $e');
      }

      return NoteCoinsData(amount: amount, qty: qty);
    }

    // double fontSizeHead = 7;
    // double fontSizeBody = 5;
    double discount = 0.0;

    //coins
    double noteCoinsAmount = data[0].notesandcoins!.isNotEmpty ? data[0].notesandcoins!.fold(0.0, (sum, elem) => sum + (double.tryParse(elem.amount ?? '0.0') ?? 0)) : 0.0;
    double creditcardAmount = data[0].creditcard!.isNotEmpty ? double.parse(data[0].creditcard![0].amount ?? '0.0') : 0.0;
    double payeshopAmount = data[0].payeshop!.isNotEmpty ? double.parse(data[0].payeshop![0].amount ?? '0.0') : 0.0;
    double grandTotal = noteCoinsAmount + creditcardAmount + payeshopAmount;
    double netGrandTotal = grandTotal - 0.0;

    // print('1 > $noteCoinsAmount');
    // print('2 > $creditcardAmount');
    // print('3 > $payeshopAmount');
    // print('4 > $grandTotal');

    pw.Widget buildBodyContainer2(String title, String label, String sum, pw.Font pgVim, double width1, double width2, double height, double padding, int ckh) {
      return pw.Container(
        child: pw.Row(
          children: <pw.Widget>[
            pw.Container(
              padding: pw.EdgeInsets.all(padding),
              width: width1,
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              alignment: pw.Alignment.center,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: <pw.Widget>[
                  pw.Text(title,
                    style: pw.TextStyle(font: pgVim, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  if(ckh != 0) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(label,
                      style: pw.TextStyle(font: pgVim, fontSize: 6, fontWeight: pw.FontWeight.normal)),
                  ]             
                ]
              )
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(2),
              height: height,
              width: width2,
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              alignment: pw.Alignment.centerRight,
              child: pw.Text(sum,
                style: pw.TextStyle(font: pgVim, fontSize: 7, fontWeight: pw.FontWeight.bold))
            ),    //pw.SizedBox(height: 20),
          ]
        )
      );
    }

    pw.Widget buildHeaderContainer(String title, String label, pw.Font pgVim, double width, double padding) {
      return pw.Container(
        padding: pw.EdgeInsets.all(padding),
        width: width,
        decoration: pw.BoxDecoration(border: pw.Border.all()),
        alignment: pw.Alignment.center,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: <pw.Widget>[
            pw.Text(title,
              style: pw.TextStyle(font: pgVim, fontSize: 7, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text(label,
              style: pw.TextStyle(font: pgVim, fontSize: 6, fontWeight: pw.FontWeight.normal)), //255
            //pw.SizedBox(width: 20),
          ]
        )
      );
    }

    pw.Widget buildContainer(String title, pw.Font pgVim, double width, double padding, pw.Alignment alignment, {double? height}) {
      return pw.Container(
        padding: pw.EdgeInsets.all(padding),
        height: height,
        width: width,
        decoration: pw.BoxDecoration(border: pw.Border.all()),
        alignment: alignment,
        child: pw.Text(title,
          style: pw.TextStyle(font: pgVim, fontSize: 7, fontWeight: pw.FontWeight.bold))
      );
    }

    pw.Widget buildBodyCurrencyAndNoteCoins(String currency, String quantity, String rate, String amount, String coinsType, String coinsQuantity, String coinsAmount, pw.Font pgVim) {
      pw.Widget buildContainerCurrency(String title, pw.Font pgVim, double width, double padding, pw.Alignment alignment, {double? height}) {
        return pw.Container(
          padding: pw.EdgeInsets.all(padding),
          height: height,
          width: width,
          decoration: pw.BoxDecoration(border: pw.Border.all()),
          alignment: alignment,
          child: pw.Text(title,
            style: pw.TextStyle(font: pgVim, fontSize: 7, fontWeight: pw.FontWeight.normal)),
        );
      }

      return pw.Container(
        child: pw.Row(
          children: <pw.Widget>[
            buildContainerCurrency(currency, pgVim, 30, 4.5, pw.Alignment.center),
            buildContainerCurrency(rate, pgVim, 30, 2, pw.Alignment.centerRight, height: 16),
            buildContainerCurrency(quantity, pgVim, 30, 2, pw.Alignment.centerRight, height: 16), //35-50 15
            buildContainerCurrency(amount, pgVim, 45, 2, pw.Alignment.centerRight, height: 16),
            buildContainerCurrency(coinsType, pgVim, 40, 4.5, pw.Alignment.center),
            buildContainerCurrency(coinsQuantity, pgVim, 35, 2, pw.Alignment.centerRight, height: 16),
            buildContainerCurrency(coinsAmount, pgVim, 60, 2, pw.Alignment.centerRight, height: 16),
          ]
        )
      );
    }

    return <pw.Widget>[
      pw.Container(
        child: pw.Row(
          children: <pw.Widget>[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Container(
                  child: pw.Container(
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Container(
                          child: pw.Column(
                            children: <pw.Widget>[
                              buildHeaderContainer('บัตรเครดิต', 'Credit Card', pgVim, 120, 6.0),
                              pw.SizedBox(width: 10),
                              buildBodyContainer2('(1) รวม', 'Total', formatter.format(creditcardAmount), pgVim, 70, 50, 21, 3.0, 1),
                              pw.SizedBox(height: 7),
                              buildHeaderContainer('เอฟซีคอยน์', 'FCcion', pgVim, 120, 6.0),
                              buildBodyContainer2('(2) รวม', 'Total', '0.00', pgVim, 70, 50, 21, 3.0, 1),
                              pw.SizedBox(height: 8),
                              buildHeaderContainer('อื่นๆ', 'Other', pgVim, 120, 6.0),
                              pw.SizedBox(width: 10),
                              buildBodyContainer2('E-SHOP', 'Total', formatter.format(payeshopAmount), pgVim, 70, 50, 15, 4.0, 0),
                              buildBodyContainer2('VOUCHER', 'Total', '0.00', pgVim, 70, 50, 15, 4.0, 0),
                              buildBodyContainer2('CHEQUE', 'Total', '0.00', pgVim, 70, 50, 15, 4.0, 0),
                              buildBodyContainer2('PAY-IN', 'Total', '0.00', pgVim, 70, 50, 15, 4.0, 0),
                              buildBodyContainer2('TAX', 'Total', '0.00', pgVim, 70, 50, 15, 4.0, 0),
                              buildBodyContainer2('GIFT CERTIFICATE', 'Total', '0.00', pgVim, 70, 50, 15, 4.0, 0),
                            ]
                          ),
                        ),
                        pw.SizedBox(width: 6),
                        pw.Container(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: <pw.Widget>[
                              pw.Container(
                                child: pw.Row(
                                  children: <pw.Widget>[
                                    buildHeaderContainer('เงินสกุลต่างประเทศ', 'Foreign Currency', pgVim, 135, 6),
                                    buildHeaderContainer('ธนบัตรและเหรียญกษาปณ์', 'Notes & Coins', pgVim, 135, 6),
                                  ]
                                )
                              ),
                              buildBodyCurrencyAndNoteCoins('USD', '0', '0.00', '0.00', '1000', buildNoteCoinsData('1000').qty, formatter.format(buildNoteCoinsData('1000').amount), pgVim),
                              buildBodyCurrencyAndNoteCoins('SGD', '0', '0.00', '0.00', '500', buildNoteCoinsData('500').qty, formatter.format(buildNoteCoinsData('500').amount), pgVim),
                              buildBodyCurrencyAndNoteCoins('TWD', '0', '0.00', '0.00', '100', buildNoteCoinsData('100').qty, formatter.format(buildNoteCoinsData('100').amount), pgVim),
                              buildBodyCurrencyAndNoteCoins('JPY', '0', '0.00', '0.00', '50', buildNoteCoinsData('50').qty, formatter.format(buildNoteCoinsData('50').amount), pgVim),
                              buildBodyCurrencyAndNoteCoins('HKD', '0', '0.00', '0.00', '20', buildNoteCoinsData('20').qty, formatter.format(buildNoteCoinsData('20').amount), pgVim),
                              buildBodyCurrencyAndNoteCoins('GBP', '0', '0.00', '0.00', '10', buildNoteCoinsData('10').qty, formatter.format(buildNoteCoinsData('10').amount), pgVim),
                              buildBodyCurrencyAndNoteCoins('CNY', '0', '0.00', '0.00', '5', buildNoteCoinsData('5').qty, formatter.format(buildNoteCoinsData('5').amount), pgVim),
                              buildBodyCurrencyAndNoteCoins('AUD', '0', '0.00', '0.00', '2', buildNoteCoinsData('2').qty, formatter.format(buildNoteCoinsData('2').amount), pgVim),
                              buildBodyCurrencyAndNoteCoins('EUR', '0', '0.00', '0.00', '1', buildNoteCoinsData('1').qty, formatter.format(buildNoteCoinsData('1').amount), pgVim),
                              pw.Container(
                                child: pw.Row(
                                  children: <pw.Widget>[
                                    buildHeaderContainer('(4) รวม', 'Total', pgVim, 60, 2.5), //130
                                    buildContainer('0.00', pgVim, 75, 2, pw.Alignment.centerRight, height: 20),
                                    buildContainer('0.50', pgVim, 40, 6.5, pw.Alignment.center),
                                    buildContainer(buildNoteCoinsData('0.50').qty, pgVim, 35, 2, pw.Alignment.centerRight, height: 20),
                                    buildContainer(formatter.format(buildNoteCoinsData('0.50').amount), pgVim, 60, 2, pw.Alignment.centerRight, height: 20),
                                  ]
                                )
                              ),
                              pw.Container(
                                child: pw.Row(
                                  children: <pw.Widget>[
                                    buildContainer('รายได้รอบ 1 / Amount (First Collection)', pgVim, 135, 5, pw.Alignment.center),
                                    buildContainer('0.25', pgVim, 40, 5, pw.Alignment.center),
                                    buildContainer(buildNoteCoinsData('0.25').qty, pgVim, 35, 2, pw.Alignment.centerRight, height: 17),
                                    buildContainer(formatter.format(buildNoteCoinsData('0.25').amount), pgVim, 60, 2, pw.Alignment.centerRight, height: 17),
                                  ]
                                )
                              ),
                              pw.Container(
                                child: pw.Row(
                                  children: <pw.Widget>[
                                    buildBodyContainer2('(5) เงินสด', 'Cash', '0.00', pgVim, 55, 80, 21, 3.0, 1),
                                    buildBodyContainer2('(6) รวม', 'Total', formatter.format(noteCoinsAmount), pgVim, 75, 60, 21, 3.0, 1),
                                  ]
                                )
                              ),
                            ]
                          )
                        ),
                      ]
                    )
                  )
                ),
              ],
            ),
          ],
        )
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: <pw.Widget>[
          pw.SizedBox(
            width: 240,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.SizedBox(height: 6),
                pw.Text('หมายเหตุ ',
                  style: pw.TextStyle( font: pgVim, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text('Remark',
                  style: pw.TextStyle( font: pgVim, fontSize: 6, fontWeight: pw.FontWeight.normal)),
                pw.SizedBox(height: 10),
                pw.Text('             _________________________________________________________________________',
                  style: pw.TextStyle( font: traJanPro, fontSize: 6, fontWeight: pw.FontWeight.normal)),
                pw.SizedBox(height: 10),
                pw.Text('             _________________________________________________________________________',
                  style: pw.TextStyle( font: traJanPro, fontSize: 6, fontWeight: pw.FontWeight.normal)),
                pw.SizedBox(height: 10),
                pw.Text('             _________________________________________________________________________',
                  style: pw.TextStyle( font: traJanPro, fontSize: 6, fontWeight: pw.FontWeight.normal)),
              ]
            ),
          ),
          pw.SizedBox(
            child: pw.Column(
              children: <pw.Widget>[
                buildTotal('รวมทั้งสิ้น', 'Grand Total', pgVim, formatter.format(grandTotal), traJanProBold),
                buildTotal('หักรับคืนคูปอง', 'Refund', pgVim, formatter.format(discount), traJanProBold),
                buildTotal('รวมรายได้สุทธิ์', 'Net Amount', pgVim, formatter.format(netGrandTotal), traJanProBold),
              ]
            ) 
          )
        ]
      ),
      // pw.NewPage(),
    ];
  }

  pw.Widget buildTotal(String title, String label, pw.Font pgVim, String sum, pw.Font traJanProBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Container(
          width: 96,
          padding: const pw.EdgeInsets.all(4.0),
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(title,
                style: pw.TextStyle(font: pgVim, fontSize: 7, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text(label,
                style: pw.TextStyle(font: pgVim, fontSize: 6, fontWeight: pw.FontWeight.normal)),
            ]
          )
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(2),
          height: 23,
          width: 60,
          decoration: pw.BoxDecoration(border: pw.Border.all()),
          alignment: pw.Alignment.centerRight,
          child: pw.Text(sum,
            style: pw.TextStyle(font: label != 'Refund' ? traJanProBold : pgVim, fontSize: label != 'Refund' ? 8 : 7, fontWeight: label != 'Refund' ? pw.FontWeight.bold : null)
          )
        )
      ]
    );
  }
}