import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/money_utils.dart';
import '../../../data/models/seller_transaction.dart';
import 'ui_kit.dart';

/// Shows the seller's totals and asks the cashier to confirm. [onConfirm]
/// runs inside the dialog (with a busy button); a failure keeps the dialog
/// open with the error. Resolves to `true` once verified.
Future<bool> showVerifySellerDialog(
  BuildContext context, {
  required SellerTransaction seller,
  required SellerTransaction detail,
  required DateTime date,
  required Future<void> Function() onConfirm,
}) async {
  final verified = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _VerifySellerDialog(
      seller: seller,
      detail: detail,
      date: date,
      onConfirm: onConfirm,
    ),
  );
  return verified ?? false;
}

class _VerifySellerDialog extends StatefulWidget {
  const _VerifySellerDialog({
    required this.seller,
    required this.detail,
    required this.date,
    required this.onConfirm,
  });

  /// Day-list row: name and code.
  final SellerTransaction seller;

  /// Loaded breakdown: the totals shown on screen.
  final SellerTransaction detail;
  final DateTime date;
  final Future<void> Function() onConfirm;

  @override
  State<_VerifySellerDialog> createState() => _VerifySellerDialogState();
}

class _VerifySellerDialogState extends State<_VerifySellerDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('verifySeller failed: $e');
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'บันทึกไม่สำเร็จ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.seller;
    final d = widget.detail;

    Widget summaryRow(String label, String value, {bool strong = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Expanded(child: Text(label, style: AppText.body(color: AppColors.textMuted))),
            Text(value,
                style: strong
                    ? AppText.display(size: 20)
                    : AppText.body(weight: FontWeight.w600)),
          ]),
        );

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const IconTile(icon: Icons.fact_check_outlined, size: 44),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ยืนยันตรวจสอบรายการ', style: AppText.display(size: 20)),
                      Text('Verify', style: AppText.caption()),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.sunken,
                  borderRadius: BorderRadius.circular(AppRadius.inner),
                ),
                child: Column(children: [
                  summaryRow('ผู้จำหน่าย', '${s.code} · ${s.name}'),
                  summaryRow('วันที่', AppDateFormat.thaiLong(widget.date)),
                  summaryRow('เงินสด', formatMoney(d.cashTotal)),
                  summaryRow('ไม่ใช่เงินสด', formatMoney(d.nonCashTotal)),
                  const Divider(height: 16),
                  summaryRow('ยอดรวม', formatMoney(d.grandTotal), strong: true),
                ]),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.inner),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('ยืนยันแล้วจะแก้ไขหรือยกเลิกไม่ได้',
                        style: AppText.body(size: 13, color: AppColors.primaryDeep)),
                  ),
                ]),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: AppText.body(size: 13, color: AppColors.primaryText)),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PillButton(
                    label: 'กลับ',
                    onPressed: _busy ? null : () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: 10),
                  PillButton(
                    label: 'ยืนยัน',
                    icon: Icons.check_rounded,
                    style: PillButtonStyle.teal,
                    busy: _busy,
                    onPressed: _confirm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
