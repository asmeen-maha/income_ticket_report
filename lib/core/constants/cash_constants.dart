/// Thai banknotes and coins, largest first, in the order they appear on
/// screen and in every report.
const List<double> thaiDenominations = [
  1000, 500, 100, 50, 20, 10, 5, 2, 1, 0.50, 0.25,
];

/// Label shown for a denomination, e.g. `1000.00`, `0.50`.
String denominationLabel(double value) => value.toStringAsFixed(2);

/// Foreign currencies printed on the seller income report, mapped to the
/// `currency_code` the API uses.
const Map<String, String> foreignCurrencyCodes = {
  'USD': '1',
  'SGD': '5',
  'TWD': '9',
  'JPY': '4',
  'HKD': '6',
  'GBP': '3',
  'CNY': '8',
  'AUD': '7',
  'EUR': '2',
};

/// Values of `flagcheck` / `paytype` / `accode` returned by the API.
abstract final class ApiCodes {
  static const verified = 'Y';
  static const notVerified = 'N';

  static const payTypeCredit = '2';
  static const payTypeAdvance = '4';

  static const accountCash = '111';
  static const accountCredit = '114';

  /// `referno` of an e-shop row that is actually a bank pay-in.
  static const payInReference = 'payin';
}
