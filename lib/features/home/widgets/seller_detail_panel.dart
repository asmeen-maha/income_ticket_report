import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/cash_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../../data/models/seller_transaction.dart';
import 'seller_avatar.dart';
import 'ui_kit.dart';

/// Middle column: the selected seller's cash count, other payment channels
/// and grand total with the verify action.
class SellerDetailPanel extends StatelessWidget {
  const SellerDetailPanel({
    super.key,
    required this.seller,
    required this.detail,
    required this.isLoading,
    required this.onVerify,
  });

  /// Row from the day list (name, code, verified flag). Null = nothing selected.
  final SellerTransaction? seller;

  /// Full breakdown, once loaded.
  final SellerTransaction? detail;
  final bool isLoading;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final s = seller;
    if (s == null) {
      return const Tile(
        child: _Placeholder(
          icon: Icons.touch_app_outlined,
          text: 'เลือกผู้จำหน่ายบัตรทางซ้าย\nเพื่อดูรายละเอียดเงินที่นำส่ง',
        ),
      );
    }

    final d = detail;
    if (d == null) {
      return Tile(
        child: isLoading
            ? const LoadingView(message: 'กำลังโหลดรายละเอียด')
            : const _Placeholder(icon: Icons.error_outline_rounded, text: 'โหลดรายละเอียดไม่สำเร็จ'),
      );
    }

    // The total and the verify button stay pinned; the breakdown scrolls.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              _CashTile(seller: s, detail: d),
              const SizedBox(height: 16),
              _NonCashTile(detail: d),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _GrandTotalTile(
          amount: d.grandTotal,
          verified: s.isVerified,
          onVerify: onVerify,
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTile(icon: icon, size: 48, background: AppColors.sunken, foreground: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: AppText.body(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

final _wholeNumber = NumberFormat('#,##0', 'en_US');

String _denominationText(double value) =>
    value >= 1 ? _wholeNumber.format(value) : value.toStringAsFixed(2);

class _CashTile extends StatelessWidget {
  const _CashTile({required this.seller, required this.detail});

  final SellerTransaction seller;
  final SellerTransaction detail;

  static const _banknotes = [1000.0, 500.0, 100.0, 50.0, 20.0];

  @override
  Widget build(BuildContext context) {
    final banknotes = thaiDenominations.where(_banknotes.contains);
    final coins = thaiDenominations.where((d) => !_banknotes.contains(d));
    final totalQty = detail.notesAndCoins.sumBy((n) => n.qty);

    return Tile(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(children: [
              SellerAvatar(
                name: seller.name,
                code: seller.code,
                tone: seller.isVerified ? AvatarTone.verified : AvatarTone.active,
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(seller.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.display(size: 18)),
                    const SizedBox(height: 2),
                    Text('${seller.code} · เงินสด Cash', style: AppText.caption()),
                  ],
                ),
              ),
              StatusPill(verified: seller.isVerified),
            ]),
          ),
          Container(
            color: AppColors.tableHeader,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const _TableRow(
              cells: ['Type', 'Quantity', 'Amount'],
              header: true,
            ),
          ),
          const _GroupLabel('ธนบัตร'),
          for (final d in banknotes) _denominationRow(d),
          const _GroupLabel('เหรียญ'),
          for (final d in coins) _denominationRow(d),
          const SizedBox(height: 6),
          _TableRow(
            cells: ['เงินต่างประเทศ', '${detail.foreignCurrencies.length}', formatMoney(detail.foreignCurrencyTotal)],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: DashedDivider(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 14),
            child: _TableRow(
              cells: ['รวมเงินสด', _wholeNumber.format(totalQty), formatMoney(detail.cashTotal)],
              emphasis: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _denominationRow(double denomination) {
    final note = detail.noteFor(denomination);
    return _TableRow(cells: [
      _denominationText(denomination),
      note?.qtyText ?? '0',
      formatMoney(note?.amount ?? 0),
    ]);
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
      child: Text(text, style: AppText.caption(weight: FontWeight.w600)),
    );
  }
}

/// Type | Quantity | Amount, the last two right-aligned.
class _TableRow extends StatelessWidget {
  const _TableRow({required this.cells, this.header = false, this.emphasis = false});

  final List<String> cells;
  final bool header;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final TextStyle first, qty, amount;
    if (header) {
      first = qty = amount = AppText.caption(weight: FontWeight.w500);
    } else if (emphasis) {
      first = AppText.body(size: 13, weight: FontWeight.w600);
      qty = amount = AppText.body(weight: FontWeight.w600);
    } else {
      first = AppText.body();
      qty = AppText.body(color: AppColors.textMuted);
      amount = AppText.body(weight: FontWeight.w500);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: header ? 0 : 5),
      child: Row(children: [
        Expanded(flex: 5, child: Text(cells[0], style: first)),
        Expanded(flex: 3, child: Text(cells[1], textAlign: TextAlign.right, style: qty)),
        Expanded(flex: 5, child: Text(cells[2], textAlign: TextAlign.right, style: amount)),
      ]),
    );
  }
}

class _NonCashTile extends StatelessWidget {
  const _NonCashTile({required this.detail});

  final SellerTransaction detail;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.credit_card_rounded, 'Credit Card', detail.creditCards.length, detail.creditCardTotal),
      (Icons.shopping_bag_outlined, 'E-Shop', detail.eShopCount, detail.eShopExcludingPayIn),
      (Icons.account_balance_outlined, 'PAY IN', detail.payInCount, detail.payInTotal),
    ];

    return Tile(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ไม่ใช่เงินสด · Non-cash', style: AppText.caption(weight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (final (icon, label, count, amount) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                IconTile(icon: icon),
                const SizedBox(width: 10),
                Expanded(child: Text(label, style: AppText.body(weight: FontWeight.w500))),
                SizedBox(
                  width: 48,
                  child: Text('$count',
                      textAlign: TextAlign.right, style: AppText.body(color: AppColors.textMuted)),
                ),
                SizedBox(
                  width: 120,
                  child: Text(formatMoney(amount),
                      textAlign: TextAlign.right, style: AppText.body(weight: FontWeight.w500)),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}

class _GrandTotalTile extends StatelessWidget {
  const _GrandTotalTile({required this.amount, required this.verified, required this.onVerify});

  final double amount;
  final bool verified;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return Tile(
      color: verified ? AppColors.tealSoft : AppColors.primarySoft,
      bordered: false,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 14,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Grand Total · ยอดรวมทั้งสิ้น',
                  style: AppText.label(
                    color: verified ? AppColors.teal : AppColors.primaryDeep,
                    weight: FontWeight.w600,
                  )),
              const SizedBox(height: 2),
              Text(formatMoney(amount), style: AppText.display(size: 34)),
            ],
          ),
          verified
              ? const PillButton(
                  label: 'ตรวจสอบแล้ว',
                  icon: Icons.verified_outlined,
                  style: PillButtonStyle.teal,
                  height: 48,
                  onPressed: null,
                )
              : PillButton(
                  label: 'ยืนยันตรวจสอบ',
                  icon: Icons.check_circle_outline_rounded,
                  style: PillButtonStyle.teal,
                  height: 48,
                  onPressed: onVerify,
                ),
        ],
      ),
    );
  }
}
