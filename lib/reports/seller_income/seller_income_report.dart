import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/cash_constants.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/utils/money_utils.dart';
import '../../data/models/booking_payment.dart';
import '../../data/models/pay_type.dart';
import '../../data/models/seller_transaction.dart';
import '../common/pdf_resources.dart';
import 'seller_income_footer.dart';
import 'seller_income_header.dart';

/// ใบนำส่งรายได้ฝ่ายบัตร / Income Report — A4 landscape, one seller's day.
///
/// Left half: payment breakdown (credit card, e-shop, foreign currency,
/// notes & coins, totals). Right half: advance and credit bookings.
class SellerIncomeReport {
  SellerIncomeReport({
    required this.transaction,
    required this.advancePayments,
    required this.creditPayments,
    required List<PayType> payTypes,
  }) : _payTypeNames = {for (final p in payTypes) p.accCode: p.shortName};

  /// Detail of the seller (from the per-seller endpoint).
  final SellerTransaction transaction;
  final List<BookingPayment> advancePayments;
  final List<BookingPayment> creditPayments;
  final Map<String, String> _payTypeNames;

  late PdfFonts _fonts;

  Future<Uint8List> generate({
    required DateTime date,
    required String sellerName,
    required String staffCode,
  }) async {
    _fonts = await PdfFonts.load();
    final logo = await loadPdfImage(AppAssets.ticketingLogo);
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.only(
          top: .5 * PdfPageFormat.cm,
          left: .45 * PdfPageFormat.cm,
          right: .5 * PdfPageFormat.cm,
          bottom: .5 * PdfPageFormat.cm,
        ),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (_) => SellerIncomeHeader(
          fonts: _fonts,
          logo: logo,
          date: date,
          sellerName: sellerName,
          staffCode: staffCode,
          showBookingTable: advancePayments.isNotEmpty || creditPayments.isNotEmpty,
        ),
        build: (_) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(width: 395, height: 335, child: _paymentBreakdown()),
              pw.Container(
                width: 400,
                height: 335,
                margin: const pw.EdgeInsets.only(left: 17),
                child: _bookings(),
              ),
            ],
          ),
        ],
        footer: (_) => SellerIncomeFooter(
          fonts: _fonts,
          title: SellerIncomeHeader.titleEnglish,
          sellerName: sellerName,
        ),
      ),
    );
    return pdf.save();
  }

  // ---------------------------------------------------------------------------
  // Left half
  // ---------------------------------------------------------------------------

  pw.Widget _paymentBreakdown() {
    final t = transaction;
    return pw.Column(
      children: [
        pw.Row(
          children: [
            _nonCashColumn(t),
            pw.SizedBox(width: 6),
            _cashColumn(t),
          ],
        ),
        pw.Row(
          children: [
            pw.SizedBox(width: 240, child: _remarks()),
            pw.Column(children: [
              _totalLine('รวมทั้งสิ้น', 'Grand Total', t.grandTotal),
              _totalLine('หักรับคืนคูปอง', 'Refund', 0, emphasised: false),
              _totalLine('รวมรายได้สุทธิ์', 'Net Amount', t.grandTotal),
            ]),
          ],
        ),
      ],
    );
  }

  /// Credit card, FCcoin and "other" (e-shop, pay-in, …).
  pw.Widget _nonCashColumn(SellerTransaction t) {
    pw.Widget otherRow(String label, double amount) =>
        _labelledAmount(label, null, formatMoney(amount), height: 15, padding: 4);

    return pw.Column(children: [
      _heading('บัตรเครดิต', 'Credit Card', 120, 6),
      _labelledAmount('(1) รวม', 'Total', formatMoney(t.creditCardTotal), bold: true),
      _heading('เอฟซีคอยน์', 'FCcoin', 120, 6),
      _labelledAmount('(2) รวม', 'Total', formatMoney(0), bold: true),
      _heading('อื่นๆ', 'Other', 120, 6),
      otherRow('E-SHOP', t.eShopExcludingPayIn),
      otherRow('VOUCHER', 0),
      otherRow('CHEQUE', 0),
      otherRow('PAY-IN', t.payInTotal),
      otherRow('TAX', 0),
      otherRow('GIFT CERTIFICATE', 0),
      _labelledAmount('(3) รวม /Total', null, formatMoney(t.eShopTotal),
          bold: true, height: 15, padding: 4),
    ]);
  }

  /// Foreign currency (left) beside Thai notes & coins (right).
  pw.Widget _cashColumn(SellerTransaction t) {
    final currencies = foreignCurrencyCodes.entries.toList();
    // The first rows pair a currency with a note; 0.50 and 0.25 get their own rows.
    final pairedNotes = thaiDenominations.take(currencies.length).toList();

    String noteQty(double d) => t.noteFor(d)?.qtyText ?? '0';
    String noteAmount(double d) => formatMoney(t.noteFor(d)?.amount ?? 0);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(children: [
          _heading('เงินสกุลต่างประเทศ', 'Foreign Currency', 135, 6),
          _heading('ธนบัตรและเหรียญกษาปณ์', 'Notes & Coins', 135, 6),
        ]),
        for (var i = 0; i < currencies.length; i++)
          _currencyAndNoteRow(
            currency: currencies[i].key,
            detail: t.currencyFor(currencies[i].value),
            noteLabel: pairedNotes[i].toStringAsFixed(0),
            noteQty: noteQty(pairedNotes[i]),
            noteAmount: noteAmount(pairedNotes[i]),
          ),
        pw.Row(children: [
          _heading('(4) รวม', 'Total', 60, 2.5),
          _cell(formatMoney(t.foreignCurrencyTotal), 75, 2, pw.Alignment.centerRight,
              height: 20, style: _amountBold),
          _cell('0.50', 40, 6.5, pw.Alignment.center),
          _cell(noteQty(0.50), 35, 2, pw.Alignment.centerRight, height: 20),
          _cell(noteAmount(0.50), 60, 2, pw.Alignment.centerRight, height: 20),
        ]),
        pw.Row(children: [
          _cell('รายได้รอบ 1 / Amount (First Collection)', 135, 5, pw.Alignment.center),
          _cell('0.25', 40, 5, pw.Alignment.center),
          _cell(noteQty(0.25), 35, 2, pw.Alignment.centerRight, height: 17),
          _cell(noteAmount(0.25), 60, 2, pw.Alignment.centerRight, height: 17),
        ]),
        pw.Row(children: [
          _labelledAmount('(5) เงินสด', 'Cash', formatMoney(0),
              bold: true, labelWidth: 55, amountWidth: 80),
          _labelledAmount('(6) รวม', 'Total', formatMoney(t.notesAndCoinsTotal),
              bold: true, labelWidth: 75, amountWidth: 60),
        ]),
      ],
    );
  }

  pw.Widget _currencyAndNoteRow({
    required String currency,
    required ForeignCurrencyCount? detail,
    required String noteLabel,
    required String noteQty,
    required String noteAmount,
  }) {
    pw.Widget cell(String text, double width, pw.Alignment alignment, {bool centred = false}) =>
        _cell(text, width, centred ? 4.5 : 2, alignment,
            height: centred ? null : 16, style: _thaiRegular);

    return pw.Row(children: [
      cell(currency, 30, pw.Alignment.center, centred: true),
      cell(detail?.rateText ?? '0.00', 30, pw.Alignment.centerRight),
      cell(detail?.qtyText ?? '0', 30, pw.Alignment.centerRight),
      cell(formatMoney(detail?.amount ?? 0), 45, pw.Alignment.centerRight),
      cell(noteLabel, 40, pw.Alignment.center, centred: true),
      cell(noteQty, 35, pw.Alignment.centerRight),
      cell(noteAmount, 60, pw.Alignment.centerRight),
    ]);
  }

  pw.Widget _remarks() {
    final line = pw.Text(
      '             _________________________________________________________________________',
      style: pw.TextStyle(font: _fonts.trajanPro, fontSize: 6),
    );
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 6),
        pw.Text('หมายเหตุ ', style: _thaiBold),
        pw.SizedBox(height: 2),
        pw.Text('Remark', style: _englishSmall),
        for (var i = 0; i < 3; i++) ...[pw.SizedBox(height: 10), line],
      ],
    );
  }

  pw.Widget _totalLine(String thai, String english, double amount, {bool emphasised = true}) {
    return pw.Row(children: [
      pw.Container(
        width: 96,
        padding: const pw.EdgeInsets.all(4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(thai, style: _thaiBold),
            pw.SizedBox(height: 2),
            pw.Text(english, style: _englishSmall),
          ],
        ),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.all(2),
        height: 23,
        width: 60,
        decoration: _border,
        alignment: pw.Alignment.centerRight,
        child: pw.Text(formatMoney(amount), style: emphasised ? _amountBold : _thaiRegular),
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Right half
  // ---------------------------------------------------------------------------

  pw.Widget _bookings() {
    return pw.Column(children: [
      if (advancePayments.isNotEmpty) ..._bookingSection('Pay advance', advancePayments),
      pw.SizedBox(height: 5),
      if (creditPayments.isNotEmpty) ..._bookingSection('Credit', creditPayments),
    ]);
  }

  List<pw.Widget> _bookingSection(String tag, List<BookingPayment> items) {
    final cash = items.where((e) => e.isPaidCash);
    final card = items.where((e) => e.isPaidByCard);
    final cashTotal = cash.sumBy((e) => e.amount);
    final cardTotal = card.sumBy((e) => e.amount);
    final totalStyle =
        pw.TextStyle(font: _fonts.trajanPro, fontSize: 10, fontWeight: pw.FontWeight.bold);

    pw.Widget totalRow(String label, double amount, pw.TextStyle style) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [pw.Text(label, style: style), pw.Text(formatMoney(amount), style: style)],
        );

    return [
      pw.Row(children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(5),
          decoration: const pw.BoxDecoration(
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
            color: PdfColors.grey400,
          ),
          child: pw.Text(tag, style: pw.TextStyle(font: _fonts.pgVim, fontSize: 10)),
        ),
      ]),
      pw.SizedBox(height: 5),
      for (final item in items) _bookingRow(item),
      pw.Divider(thickness: .5),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Column(children: [
              if (cash.isNotEmpty) totalRow('Total Cash', cashTotal, totalStyle),
              pw.SizedBox(height: 3),
              if (card.isNotEmpty) totalRow('Total Credit', cardTotal, totalStyle),
              pw.SizedBox(height: 3),
              totalRow(
                'Grand Total',
                cashTotal + cardTotal,
                totalStyle.copyWith(font: _fonts.trajanProBold, fontSize: 11),
              ),
            ]),
          ),
        ],
      ),
    ];
  }

  pw.Widget _bookingRow(BookingPayment item) {
    pw.Widget cell(String text, double width, pw.Font font,
            [pw.Alignment alignment = pw.Alignment.centerLeft]) =>
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Container(
            width: width,
            alignment: alignment,
            child: pw.Text(text,
                style: pw.TextStyle(font: font, fontSize: 9, fontWeight: pw.FontWeight.bold),
                overflow: pw.TextOverflow.span),
          ),
        );

    return pw.Row(children: [
      cell(item.rsvn, 40, _fonts.trajanPro),
      cell('${item.agentCode} ${item.agentName}', 250, _fonts.trajanPro),
      cell(_payTypeNames[item.accCode] ?? '-', 55, _fonts.pgVim),
      cell(item.amountText, 55, _fonts.trajanPro, pw.Alignment.centerRight),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Cells
  // ---------------------------------------------------------------------------

  static final _border = pw.BoxDecoration(border: pw.Border.all());

  pw.TextStyle get _thaiBold =>
      pw.TextStyle(font: _fonts.pgVim, fontSize: 7, fontWeight: pw.FontWeight.bold);
  pw.TextStyle get _thaiRegular => pw.TextStyle(font: _fonts.pgVim, fontSize: 7);
  pw.TextStyle get _englishSmall => pw.TextStyle(font: _fonts.pgVim, fontSize: 6);
  pw.TextStyle get _amountBold =>
      pw.TextStyle(font: _fonts.trajanProBold, fontSize: 8, fontWeight: pw.FontWeight.bold);

  /// Boxed Thai title with English sub-label.
  pw.Widget _heading(String thai, String english, double width, double padding) {
    return pw.Container(
      padding: pw.EdgeInsets.all(padding),
      width: width,
      decoration: _border,
      alignment: pw.Alignment.center,
      child: pw.Column(children: [
        pw.Text(thai, style: _thaiBold),
        pw.SizedBox(height: 2),
        pw.Text(english, style: _englishSmall),
      ]),
    );
  }

  /// A boxed label (optionally with English sub-label) next to a boxed amount.
  pw.Widget _labelledAmount(
    String label,
    String? subLabel,
    String amount, {
    bool bold = false,
    double labelWidth = 70,
    double amountWidth = 50,
    double height = 21,
    double padding = 3,
  }) {
    return pw.Row(children: [
      pw.Container(
        padding: pw.EdgeInsets.all(padding),
        width: labelWidth,
        decoration: _border,
        alignment: pw.Alignment.center,
        child: pw.Column(children: [
          pw.Text(label, style: _thaiBold),
          if (subLabel != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(subLabel, style: _englishSmall),
          ],
        ]),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.all(2),
        height: height,
        width: amountWidth,
        decoration: _border,
        alignment: pw.Alignment.centerRight,
        child: pw.Text(amount, style: bold ? _amountBold : _thaiBold),
      ),
    ]);
  }

  /// A single bordered cell, Thai bold text unless [style] is given.
  pw.Widget _cell(
    String text,
    double width,
    double padding,
    pw.Alignment alignment, {
    double? height,
    pw.TextStyle? style,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.all(padding),
      height: height,
      width: width,
      decoration: _border,
      alignment: alignment,
      child: pw.Text(text, style: style ?? _thaiBold),
    );
  }
}
