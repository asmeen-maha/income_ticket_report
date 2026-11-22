import 'package:intl/intl.dart';

final _money = NumberFormat('#,##0.00', 'en_US');

/// `1234.5` → `1,234.50`
String formatMoney(num value) => _money.format(value);

/// Parses an amount string from the API (`"1,234.50"`, `"0"`, `null`) to a
/// double, falling back to 0.
double parseAmount(String? value) =>
    double.tryParse((value ?? '').replaceAll(',', '')) ?? 0.0;

extension SumBy<T> on Iterable<T> {
  double sumBy(double Function(T item) selector) =>
      fold(0.0, (total, item) => total + selector(item));
}
