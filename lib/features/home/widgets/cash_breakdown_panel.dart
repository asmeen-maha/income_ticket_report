import 'package:flutter/material.dart';

import '../../../core/constants/cash_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/money_utils.dart';
import '../../../data/models/seller_transaction.dart';
import 'common.dart';

/// Middle column: read-only breakdown of the selected seller's money.
class CashBreakdownPanel extends StatelessWidget {
  const CashBreakdownPanel({super.key, required this.detail});

  /// Null until a seller is selected and loaded.
  final SellerTransaction? detail;

  @override
  Widget build(BuildContext context) {
    final d = detail;
    final cellWidth = context.vw(.07);

    return Container(
      width: context.vw(.2125),
      height: context.vh(.85),
      margin: EdgeInsets.only(left: context.vw(.01)),
      child: Column(
        children: [
          Row(children: [
            HeaderCell('Type', width: cellWidth,
                radius: const BorderRadius.horizontal(left: Radius.circular(8))),
            HeaderCell('Quantity', width: cellWidth),
            HeaderCell('Amount', width: cellWidth,
                radius: const BorderRadius.horizontal(right: Radius.circular(8))),
          ]),
          for (final denomination in thaiDenominations)
            _DenominationRow(denomination: denomination, note: d?.noteFor(denomination)),
          SizedBox(height: context.vh(.02)),
          _AmountRow(
            label: 'Credit Card',
            amount: d?.creditCardTotal ?? 0,
            radius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          _AmountRow(label: 'E-Shop', amount: d?.eShopExcludingPayIn ?? 0),
          _AmountRow(label: 'PAY IN', amount: d?.payInTotal ?? 0),
          _AmountRow(
            label: 'Foreign Currency',
            amount: d?.foreignCurrencyTotal ?? 0,
            radius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          const Spacer(),
          _GrandTotal(amount: d == null ? 0 : _grandTotal(d)),
        ],
      ),
    );
  }

  /// Notes are valued as denomination × quantity, like the table above.
  static double _grandTotal(SellerTransaction d) {
    final notes = thaiDenominations.sumBy((v) => v * (d.noteFor(v)?.qty ?? 0));
    return notes + d.creditCardTotal + d.eShopTotal + d.foreignCurrencyTotal;
  }
}

TextStyle _valueStyle(BuildContext context, {String font = AppFonts.pgVim}) =>
    TextStyle(fontSize: context.vw(.009), fontFamily: font, color: AppColors.black);

class _DenominationRow extends StatelessWidget {
  const _DenominationRow({required this.denomination, required this.note});

  final double denomination;
  final NoteCount? note;

  @override
  Widget build(BuildContext context) {
    final qtyText = note?.qtyText ?? '';
    final amount = denomination * parseAmount(qtyText);
    final cellWidth = context.vw(.07);

    Widget cell(String text, {Alignment alignment = Alignment.center}) => Container(
          width: cellWidth,
          padding: const EdgeInsets.all(10),
          alignment: alignment,
          child: Text(text, style: _valueStyle(context)),
        );

    return Row(children: [
      cell(denominationLabel(denomination)),
      SizedBox(width: context.vw(.009)),
      SizedBox(width: context.vw(.05), child: _ReadOnlyValue(qtyText)),
      cell(qtyText.isEmpty ? formatMoney(0) : formatMoney(amount),
          alignment: Alignment.centerRight),
    ]);
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.amount, this.radius = BorderRadius.zero});

  final String label;
  final double amount;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        HeaderCell(label, width: context.vw(.08), radius: radius),
        Container(
          width: context.vw(.07),
          margin: EdgeInsets.only(right: context.vw(.01)),
          child: _ReadOnlyValue(formatMoney(amount)),
        ),
      ],
    );
  }
}

/// Disabled underlined field, matching the look of an input.
class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(text),
      initialValue: text,
      enabled: false,
      textAlign: TextAlign.center,
      style: _valueStyle(context, font: AppFonts.trajanProBold),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      ),
    );
  }
}

class _GrandTotal extends StatelessWidget {
  const _GrandTotal({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: context.vw(.012),
      fontFamily: AppFonts.trajanProBold,
      color: AppColors.black,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Grand Total', style: style),
        Padding(
          padding: EdgeInsets.only(right: context.vw(.02)),
          child: Text(formatMoney(amount), style: style),
        ),
      ],
    );
  }
}
