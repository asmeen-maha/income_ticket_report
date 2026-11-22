import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../../data/models/day_overview.dart';
import 'ui_kit.dart';

/// Four headline tiles: day total, verified count, verified amount,
/// cash vs non-cash.
class KpiRow extends StatelessWidget {
  const KpiRow({super.key, required this.overview});

  final DayOverview overview;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _DayTotalTile(overview),
      _VerifiedCountTile(overview),
      _VerifiedAmountTile(overview),
      _CashSplitTile(overview),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      const gap = 16.0;
      final columns = constraints.maxWidth >= 1000 ? 4 : 2;
      final rows = [
        for (var i = 0; i < tiles.length; i += columns) tiles.sublist(i, i + columns),
      ];

      // Tiles in a row share the height of the tallest one.
      return Column(children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0) const SizedBox(height: gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, tile) in row.indexed) ...[
                  if (i > 0) const SizedBox(width: gap),
                  Expanded(child: tile),
                ],
              ],
            ),
          ),
        ],
      ]);
    });
  }
}

class _DayTotalTile extends StatelessWidget {
  const _DayTotalTile(this.o);

  final DayOverview o;

  @override
  Widget build(BuildContext context) {
    return Tile(
      color: AppColors.ink,
      bordered: false,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('ยอดรวมทั้งวัน · Day total', style: AppText.label(color: AppColors.onInkMuted)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(formatMoney(o.dayTotal),
                style: AppText.display(size: 34, color: AppColors.onInk)),
          ),
          const SizedBox(height: 6),
          Text('ผู้จำหน่าย ${o.sellerCount} คน · บาท',
              style: AppText.caption(color: AppColors.onInkMuted)),
        ],
      ),
    );
  }
}

class _VerifiedCountTile extends StatelessWidget {
  const _VerifiedCountTile(this.o);

  final DayOverview o;

  @override
  Widget build(BuildContext context) {
    final progress = o.sellerCount == 0 ? 0.0 : o.verifiedCount / o.sellerCount;
    return Tile(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                    color: AppColors.teal,
                    backgroundColor: AppColors.border,
                  ),
                ),
                const Icon(Icons.check_rounded, color: AppColors.teal, size: 24),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ตรวจสอบแล้ว', style: AppText.label()),
                const SizedBox(height: 2),
                Text.rich(TextSpan(children: [
                  TextSpan(text: '${o.verifiedCount} ', style: AppText.display(size: 28)),
                  TextSpan(
                    text: '/ ${o.sellerCount} คน',
                    style: AppText.display(
                        size: 18, weight: FontWeight.w500, color: AppColors.textMuted),
                  ),
                ])),
                const SizedBox(height: 2),
                Text(o.pendingCount == 0 ? 'ตรวจครบทุกคนแล้ว' : 'รอตรวจอีก ${o.pendingCount} คน',
                    style: AppText.caption()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedAmountTile extends StatelessWidget {
  const _VerifiedAmountTile(this.o);

  final DayOverview o;

  @override
  Widget build(BuildContext context) {
    final percent = (o.verifiedShare * 100).round();
    return Tile(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('ยอดที่ตรวจแล้ว', style: AppText.label()),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(formatMoney(o.verifiedTotal), style: AppText.display(size: 28)),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: o.verifiedShare,
                  minHeight: 8,
                  color: AppColors.teal,
                  backgroundColor: AppColors.border,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('$percent%',
                style: AppText.caption(color: AppColors.teal, weight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }
}

class _CashSplitTile extends StatelessWidget {
  const _CashSplitTile(this.o);

  final DayOverview o;

  @override
  Widget build(BuildContext context) {
    final cashPercent = (o.cashShare * 100).round();
    final hasMoney = o.dayTotal > 0;
    final cashFlex = hasMoney ? (o.cashShare * 1000).round() : 1;
    final nonCashFlex = hasMoney ? 1000 - cashFlex : 1;

    Widget legend(Color color, String label, double amount) => Row(children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child:
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.label()),
          ),
          const SizedBox(width: 8),
          Text(formatMoney(amount), style: AppText.body(size: 13, weight: FontWeight.w600)),
        ]);

    return Tile(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('เงินสด / ไม่ใช่เงินสด', style: AppText.label()),
          const SizedBox(height: 12),
          SizedBox(
            height: 12,
            child: !hasMoney
                // Nothing collected yet: an empty track, not a fake 50/50 split.
                ? Container(
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  )
                : Row(children: [
                    if (cashFlex > 0)
                      Expanded(
                        flex: cashFlex,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.cash,
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(AppRadius.pill), right: Radius.circular(4)),
                          ),
                        ),
                      ),
                    const SizedBox(width: 3),
                    if (nonCashFlex > 0)
                      Expanded(
                        flex: nonCashFlex,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(4), right: Radius.circular(AppRadius.pill)),
                          ),
                        ),
                      ),
                  ]),
          ),
          const SizedBox(height: 12),
          Column(children: [
            legend(AppColors.cash, 'เงินสด $cashPercent%', o.cashTotal),
            const SizedBox(height: 4),
            legend(AppColors.teal, 'ไม่ใช่เงินสด ${hasMoney ? 100 - cashPercent : 0}%',
                o.nonCashTotal),
          ]),
        ],
      ),
    );
  }
}
