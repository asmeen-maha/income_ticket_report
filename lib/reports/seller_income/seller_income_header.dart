import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/date_utils.dart';
import '../common/pdf_resources.dart';

/// Logo, title, seller name / staff ID / date, and — when the seller has
/// booking payments — the column headings of the "นำส่งสินเชื่อ" table.
class SellerIncomeHeader extends pw.StatelessWidget {
  SellerIncomeHeader({
    required this.fonts,
    required this.logo,
    required this.date,
    required this.sellerName,
    required this.staffCode,
    required this.showBookingTable,
  });

  static const titleThai = 'ใบนำส่งรายได้ฝ่ายบัตร';
  static const titleEnglish = 'Income Report';

  final PdfFonts fonts;
  final pw.MemoryImage logo;
  final DateTime date;
  final String sellerName;
  final String staffCode;
  final bool showBookingTable;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.SizedBox(width: 395, child: _titleAndSeller()),
            pw.SizedBox(width: 17),
            if (showBookingTable) _bookingTableHeading(),
          ],
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _titleAndSeller() {
    final titleStyle = pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold);
    return pw.Column(
      children: [
        pw.Row(
          children: [
            pw.Image(logo, width: 100),
            pw.SizedBox(width: 20),
            pw.Container(height: 65, width: 0.8, color: PdfColors.black),
            pw.SizedBox(width: 20),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(titleThai, style: titleStyle.copyWith(font: fonts.pgVim)),
                pw.SizedBox(height: 5),
                pw.Text(titleEnglish, style: titleStyle.copyWith(font: fonts.trajanPro)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(children: [
              _field('ชื่อ - สกุล', 'Name - surname', sellerName, fonts.pgVim),
              pw.SizedBox(width: 40),
              _field('เลขประจำตัว', 'Staff ID NO.', staffCode, fonts.trajanPro),
            ]),
            _field('วันที่', ' Date', ' ${AppDateFormat.dash(date)} ', fonts.pgVim, gap: 0),
          ],
        ),
      ],
    );
  }

  /// A Thai label with its value, and the English label underneath.
  pw.Widget _field(String thai, String english, String value, pw.Font valueFont,
      {double gap = 10}) {
    const thaiSize = 9.0;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(children: [
          pw.Text(thai, style: pw.TextStyle(font: fonts.pgVim, fontSize: thaiSize)),
          pw.SizedBox(width: gap),
          pw.Text(value, style: pw.TextStyle(font: valueFont, fontSize: thaiSize)),
        ]),
        pw.SizedBox(height: 2),
        pw.Text(english, style: pw.TextStyle(font: fonts.pgVim, fontSize: 7)),
      ],
    );
  }

  pw.Widget _bookingTableHeading() {
    pw.Widget heading(String text, double width, pw.Font font) => pw.Container(
          padding: const pw.EdgeInsets.all(2),
          height: 15,
          width: width,
          alignment: pw.Alignment.center,
          child: pw.Text(text,
              style: pw.TextStyle(font: font, fontSize: 11, fontWeight: pw.FontWeight.bold)),
        );

    return pw.Container(
      width: 400,
      height: 100,
      child: pw.Column(
        children: [
          pw.Spacer(),
          pw.Text('นำส่งสินเชื่อ',
              style: pw.TextStyle(font: fonts.pgVim, fontSize: 15, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              heading('rsvn', 40, fonts.pgVim),
              heading('Agent', 250, fonts.pgVim),
              heading('PayType', 55, fonts.pgVim),
              heading('Amount', 55, fonts.trajanPro),
            ],
          ),
        ],
      ),
    );
  }
}
