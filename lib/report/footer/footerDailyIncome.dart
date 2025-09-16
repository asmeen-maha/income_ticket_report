import 'package:income_report/util/dateformat.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Container footerDailyIncome(pw.Context context, pw.Font pgVim, pw.Font traJanPro, pw.Font traJanProBold){
  double fontSize = 9;
  return pw.Container(
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('ฝ่ายรายรับ', style: pw.TextStyle(font: pgVim, fontSize: fontSize)),
        pw.Text(dateformat(date: DateTime.now(), type: 'dsn'), style: pw.TextStyle(font: pgVim, fontSize: fontSize)),
        pw.Text('ใบสรุปส่งรายได้', style: pw.TextStyle(font: pgVim, fontSize: fontSize)),
      ]
    )
  );
}