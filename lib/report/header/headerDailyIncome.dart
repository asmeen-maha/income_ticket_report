import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../util/dateformat.dart';

List<pw.Widget> headerDailyIncome(pw.Context context, pw.Font pgVim, pw.Font traJanPro, pw.Font traJanProBold, pw.MemoryImage logo, DateTime date, String title){
  return <pw.Widget>[
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Image(
          logo,
          width: 100,
        ),
      ]
    ),
    pw.SizedBox(height: 20),
    pw.Text('$title /Daily Income Statement', style: pw.TextStyle(font: pgVim, fontSize: 15)),
    pw.SizedBox(height: 5),
    pw.Text('วันที่ /Date  ${dateformat(date: date, type: 'dsn')}', style: pw.TextStyle(font: pgVim, fontSize: 12)),
    pw.SizedBox(height: 10),
  ];
}