import '../../core/utils/money_utils.dart';
import 'seller_transaction.dart';

/// Day totals across every verified seller — the data behind the
/// Daily Income Statement.
class DailySummary {
  const DailySummary({
    required this.creditCardTotal,
    required this.eShopTotal,
    required this.payInTotal,
    required this.foreignCurrencyTotal,
    required this.notes,
  });

  final double creditCardTotal;

  /// All e-shop rows, pay-ins included.
  final double eShopTotal;
  final double payInTotal;
  final double foreignCurrencyTotal;

  /// Denomination → summed quantity and amount.
  final Map<double, NoteTotal> notes;

  double get notesAndCoinsTotal => notes.values.sumBy((e) => e.amount);
  double get eShopExcludingPayIn => eShopTotal - payInTotal;
  double get cashTotal => notesAndCoinsTotal + foreignCurrencyTotal;
  double get grandTotal =>
      notesAndCoinsTotal + creditCardTotal + eShopTotal + foreignCurrencyTotal;

  factory DailySummary.fromSellers(Iterable<SellerTransaction> sellers) {
    final notes = <double, NoteTotal>{};
    for (final note in sellers.expand((s) => s.notesAndCoins)) {
      final current = notes[note.denomination] ?? const NoteTotal(qty: 0, amount: 0);
      notes[note.denomination] = NoteTotal(
        qty: current.qty + note.qty,
        amount: current.amount + note.amount,
      );
    }

    return DailySummary(
      creditCardTotal: sellers.sumBy((s) => s.creditCardTotal),
      eShopTotal: sellers.sumBy((s) => s.eShopTotal),
      payInTotal: sellers.sumBy((s) => s.payInTotal),
      foreignCurrencyTotal: sellers.sumBy((s) => s.foreignCurrencyTotal),
      notes: notes,
    );
  }
}

class NoteTotal {
  const NoteTotal({required this.qty, required this.amount});

  final double qty;
  final double amount;
}
