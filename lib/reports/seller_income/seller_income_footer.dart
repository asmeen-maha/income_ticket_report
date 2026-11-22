import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/date_utils.dart';
import '../common/pdf_resources.dart';

/// Signature boxes, company address and page number.
class SellerIncomeFooter extends pw.StatelessWidget {
  SellerIncomeFooter({
    required this.fonts,
    required this.title,
    required this.sellerName,
  });

  final PdfFonts fonts;
  final String title;
  final String sellerName;

  static const _fontSize = 5.5;
  static const _gap = 18.0;

  @override
  pw.Widget build(pw.Context context) {
    final today = AppDateFormat.slash(DateTime.now());
    final small = pw.TextStyle(font: fonts.pgVim, fontSize: _fontSize);

    return pw.Column(
      children: [
        pw.SizedBox(height: 10),
        pw.Row(children: [
          _signatureBox('ผู้นำส่ง', 'Reported by', sellerName: sellerName, date: today),
          _signatureBox('ผู้รับเงิน', 'Received by'),
        ]),
        pw.Row(
          children: [
            pw.SizedBox(width: _gap),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(title, style: small),
            ),
            pw.SizedBox(width: _gap),
            _divider(),
            pw.Container(
              width: 230,
              margin: const pw.EdgeInsets.only(top: 0.3 * PdfPageFormat.cm),
              child: pw.Column(children: [
                pw.Text('บริษัท คาร์นิวัลเมจิก จำกัด 999 หมู่ 3 ตำบลกมลา อำเภอกะทู้ จังหวัดภูเก็ต 83150',
                    style: small),
                pw.SizedBox(height: 3),
                pw.Text('Carnival Magic Co., Ltd. 999 Moo 3 Kamala Kathu phuket 83150 Thailand',
                    style: small),
                pw.SizedBox(height: 3),
                pw.Text('Tel: 076 385222  Email: ticketing@carnivalmagic.fun',
                    style: small.copyWith(font: fonts.trajanPro)),
              ]),
            ),
            _divider(),
            pw.SizedBox(width: _gap),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(today, style: small),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20, top: 10),
              child: pw.Text(
                context.pagesCount == 1 ? '' : '${context.pageNumber} / ${context.pagesCount}',
                style: pw.TextStyle(font: fonts.trajanPro, fontSize: 4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _divider() => pw.Container(
        height: 25,
        width: .7,
        color: PdfColors.black,
        margin: const pw.EdgeInsets.only(top: 0.3 * PdfPageFormat.cm),
      );

  /// Empty boxes get blank lines to sign on by hand.
  pw.Widget _signatureBox(String thai, String english, {String sellerName = '', String? date}) {
    const blank = '(________________________________)';
    final filled = sellerName.isNotEmpty;
    final lineStyle = pw.TextStyle(font: fonts.pgVim, fontSize: 7);

    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      width: 195,
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Column(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Column(children: [
              pw.Text(thai,
                  style: pw.TextStyle(font: fonts.pgVim, fontSize: 6, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text(english, style: pw.TextStyle(font: fonts.pgVim, fontSize: 5)),
            ]),
          ),
          pw.SizedBox(height: 5),
          pw.Text(filled ? '(              ${sellerName.split(' ').first}              )' : blank,
              style: lineStyle),
          pw.SizedBox(height: 8),
          pw.Text(filled ? '(              $sellerName              )' : blank, style: lineStyle),
          pw.SizedBox(height: 8),
          pw.Text(filled && date != null ? date : '______/______/______',
              style: pw.TextStyle(font: fonts.trajanPro, fontSize: 7)),
        ],
      ),
    );
  }
}
