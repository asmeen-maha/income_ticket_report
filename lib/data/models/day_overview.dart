import '../../core/utils/money_utils.dart';
import 'seller_transaction.dart';

/// Headline numbers for the selected day, across every seller.
class DayOverview {
  const DayOverview({
    required this.sellerCount,
    required this.verifiedCount,
    required this.dayTotal,
    required this.verifiedTotal,
    required this.cashTotal,
    required this.nonCashTotal,
  });

  final int sellerCount;
  final int verifiedCount;
  final double dayTotal;
  final double verifiedTotal;
  final double cashTotal;
  final double nonCashTotal;

  int get pendingCount => sellerCount - verifiedCount;

  /// Share of the day's money already verified, 0–1.
  double get verifiedShare => dayTotal <= 0 ? 0 : (verifiedTotal / dayTotal).clamp(0, 1);
  double get cashShare => dayTotal <= 0 ? 0 : (cashTotal / dayTotal).clamp(0, 1);

  factory DayOverview.fromSellers(List<SellerTransaction> sellers) {
    final verified = sellers.where((s) => s.isVerified);
    return DayOverview(
      sellerCount: sellers.length,
      verifiedCount: verified.length,
      dayTotal: sellers.sumBy((s) => s.grandTotal),
      verifiedTotal: verified.sumBy((s) => s.grandTotal),
      cashTotal: sellers.sumBy((s) => s.cashTotal),
      nonCashTotal: sellers.sumBy((s) => s.nonCashTotal),
    );
  }
}
