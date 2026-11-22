import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/cash_constants.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/money_utils.dart';
import '../../data/models/daily_summary.dart';
import '../common/pdf_resources.dart';

/// ใบสรุปส่งเงินรายได้ / Daily Income Statement — A4 portrait, the day's
/// totals across all verified sellers.
class DailyIncomeReport {
  static const title = 'ใบสรุปส่งเงินรายได้';

  static const _fontSize = 10.0;
  static const _colWidth = 180.0;
  static const _labelWidth = _colWidth * 2;
  static const _amountWidth = 184.3;
  static const _tableWidth = 600.0;

  Future<Uint8List> generate({
    required DateTime date,
    required DailySummary summary,
  }) async {
    final fonts = await PdfFonts.load();
    final logo = await loadPdfImage(AppAssets.cashierLogo);
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.portrait,
        margin: const pw.EdgeInsets.symmetric(
          vertical: .5 * PdfPageFormat.cm,
          horizontal: .9 * PdfPageFormat.cm,
        ),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (_) => _header(fonts, logo, date),
        build: (_) => _body(fonts, summary),
        footer: (_) => _footer(fonts),
      ),
    );
    return pdf.save();
  }

  pw.Widget _header(PdfFonts fonts, pw.MemoryImage logo, DateTime date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Image(logo, width: 100),
        pw.SizedBox(height: 20),
        pw.Text('$title /Daily Income Statement',
            style: pw.TextStyle(font: fonts.pgVim, fontSize: 15)),
        pw.SizedBox(height: 5),
        pw.Text('วันที่ /Date  ${AppDateFormat.slash(date)}',
            style: pw.TextStyle(font: fonts.pgVim, fontSize: 12)),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _footer(PdfFonts fonts) {
    final style = pw.TextStyle(font: fonts.pgVim, fontSize: 9);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('ฝ่ายรายรับ', style: style),
        pw.Text(AppDateFormat.slash(DateTime.now()), style: style),
        pw.Text('ใบสรุปส่งรายได้', style: style),
      ],
    );
  }

  List<pw.Widget> _body(PdfFonts fonts, DailySummary s) {
    final cashRows = {
      'รวมเงินไทย /Sub Total': s.notesAndCoinsTotal,
      'เงินต่างประเทศ /Foreign Currency': s.foreignCurrencyTotal,
      'รวมเงิน /Total': s.cashTotal,
    };
    final payTypeRows = {
      'บัตรเครดิต /Credit Card': s.creditCardTotal,
      'E-Shop': s.eShopExcludingPayIn,
      'ชำระเงินผ่านธนาคาร /PAY IN': s.payInTotal,
      'ลูกหนี้(เรียกเก็บเงิน) Voucher': 0.0,
      'เช็ค /Cheque': 0.0,
      'เอฟซีคอยน์ /FCcoin': 0.0,
      'รวมรายได้ทั้งสิ้น /Grand Total': s.grandTotal,
    };

    pw.Widget labelAmountRow(String label, double amount) => pw.Row(children: [
          _cell(fonts, label, _labelWidth),
          _amountCell(fonts, amount),
        ]);

    return [
      pw.Container(
        width: _tableWidth,
        height: 30,
        alignment: pw.Alignment.center,
        decoration: _border,
        child: pw.Text('ธนบัตรและเหรียญกษาปณ์ /Notes & Coins',
            style: pw.TextStyle(font: fonts.pgVim, fontSize: 12)),
      ),
      pw.Row(children: [
        _columnTitle(fonts, 'ชนิด', 'Type', _colWidth),
        _columnTitle(fonts, 'จำนวน', 'Quantity', _colWidth),
        _columnTitle(fonts, 'รวมเงิน (บาท)', 'Amount (Bath)', _amountWidth),
      ]),
      for (final denomination in thaiDenominations)
        pw.Row(children: [
          _cell(fonts, denominationLabel(denomination), _colWidth),
          _cell(fonts, (s.notes[denomination]?.qty ?? 0).toStringAsFixed(0), _colWidth),
          _amountCell(fonts, s.notes[denomination]?.amount ?? 0),
        ]),
      for (final row in cashRows.entries) labelAmountRow(row.key, row.value),
      pw.SizedBox(height: 10),
      for (final row in payTypeRows.entries) labelAmountRow(row.key, row.value),
      pw.SizedBox(height: 10),
      pw.Row(children: [
        _cell(fonts, 'ชื่อผู้นำส่ง /Submitted by', _labelWidth),
        _cell(fonts, 'ชื่อผู้รับ /Received by', _amountWidth),
      ]),
      for (var i = 0; i < 2; i++)
        pw.Row(children: [
          _signatureCell(fonts, '1 ___________________________________________', _labelWidth),
          _signatureCell(fonts, '2 ______________________', _amountWidth),
        ]),
      pw.SizedBox(height: 15),
      pw.Text('หมายเหตุ /Remarks', style: pw.TextStyle(font: fonts.pgVim, fontSize: _fontSize)),
      pw.SizedBox(height: 5),
      pw.Divider(thickness: .5),
      pw.SizedBox(height: 5),
      pw.Divider(thickness: .5),
    ];
  }

  static final _border = pw.BoxDecoration(border: pw.Border.all(width: .5));

  pw.Widget _columnTitle(PdfFonts fonts, String thai, String english, double width) {
    return pw.Container(
      width: width,
      height: 40,
      alignment: pw.Alignment.center,
      decoration: _border,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(thai, style: pw.TextStyle(font: fonts.pgVim, fontSize: _fontSize)),
          pw.Text(english, style: pw.TextStyle(font: fonts.trajanPro, fontSize: _fontSize)),
        ],
      ),
    );
  }

  pw.Widget _cell(
    PdfFonts fonts,
    String text,
    double width, {
    double height = 20,
    pw.Alignment alignment = pw.Alignment.center,
    pw.EdgeInsets padding = pw.EdgeInsets.zero,
  }) {
    return pw.Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: _border,
      child: pw.Text(text, style: pw.TextStyle(font: fonts.pgVim, fontSize: _fontSize)),
    );
  }

  pw.Widget _amountCell(PdfFonts fonts, double amount) => _cell(
        fonts,
        formatMoney(amount),
        _amountWidth,
        alignment: pw.Alignment.centerRight,
        padding: const pw.EdgeInsets.only(right: 10),
      );

  pw.Widget _signatureCell(PdfFonts fonts, String text, double width) => _cell(
        fonts,
        text,
        width,
        height: 30,
        alignment: pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.only(left: 10),
      );
}
