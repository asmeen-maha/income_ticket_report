import '../../core/constants/cash_constants.dart';
import '../../core/utils/money_utils.dart';
import 'json_utils.dart';

/// Everything one ticket seller handed in for a day.
class SellerTransaction {
  const SellerTransaction({
    required this.userId,
    required this.code,
    required this.name,
    this.flagCheck,
    this.creditCards = const [],
    this.notesAndCoins = const [],
    this.eShopPayments = const [],
    this.foreignCurrencies = const [],
  });

  final String userId;
  final String code;
  final String name;

  /// `Y` once the cashier has verified the submission.
  final String? flagCheck;

  final List<CreditCardPayment> creditCards;
  final List<NoteCount> notesAndCoins;
  final List<EShopPayment> eShopPayments;
  final List<ForeignCurrencyCount> foreignCurrencies;

  bool get isVerified => flagCheck == ApiCodes.verified;
  String get displayName => '$code $name';

  double get creditCardTotal => creditCards.sumBy((e) => e.amount);
  double get notesAndCoinsTotal => notesAndCoins.sumBy((e) => e.amount);
  double get foreignCurrencyTotal => foreignCurrencies.sumBy((e) => e.amount);

  /// All e-shop rows, pay-ins included.
  double get eShopTotal => eShopPayments.sumBy((e) => e.amount);
  double get payInTotal => eShopPayments.where((e) => e.isPayIn).sumBy((e) => e.amount);
  double get eShopExcludingPayIn => eShopTotal - payInTotal;

  /// Thai notes & coins plus foreign currency (as on the daily statement).
  double get cashTotal => notesAndCoinsTotal + foreignCurrencyTotal;

  /// Credit card plus all e-shop rows (pay-ins included).
  double get nonCashTotal => creditCardTotal + eShopTotal;

  double get grandTotal => cashTotal + nonCashTotal;

  int get eShopCount => eShopPayments.where((e) => !e.isPayIn).length;
  int get payInCount => eShopPayments.where((e) => e.isPayIn).length;

  NoteCount? noteFor(double denomination) {
    for (final note in notesAndCoins) {
      if (note.denomination == denomination) return note;
    }
    return null;
  }

  ForeignCurrencyCount? currencyFor(String currencyCode) {
    for (final currency in foreignCurrencies) {
      if (currency.currencyCode == currencyCode) return currency;
    }
    return null;
  }

  factory SellerTransaction.fromJson(JsonMap json) => SellerTransaction(
        userId: jsonString(json['userid']) ?? '',
        code: jsonString(json['code']) ?? '',
        name: jsonString(json['name']) ?? '',
        flagCheck: jsonString(json['flagcheck']),
        creditCards: parseJsonList(json['creditcard'], CreditCardPayment.fromJson),
        notesAndCoins: parseJsonList(json['notesandcoins'], NoteCount.fromJson),
        eShopPayments: parseJsonList(json['payeshop'], EShopPayment.fromJson),
        foreignCurrencies:
            parseJsonList(json['notesandcoins_detail'], ForeignCurrencyCount.fromJson),
      );
}

class CreditCardPayment {
  const CreditCardPayment({required this.cardNo, required this.amount});

  final String cardNo;
  final double amount;

  factory CreditCardPayment.fromJson(JsonMap json) => CreditCardPayment(
        cardNo: jsonString(json['cardno']) ?? '',
        amount: parseAmount(jsonString(json['amount'])),
      );
}

/// Count of one Thai banknote / coin denomination.
class NoteCount {
  const NoteCount({required this.type, required this.qtyText, required this.amount});

  /// Denomination as sent by the API, e.g. `1000` or `0.50`.
  final String type;

  /// Quantity exactly as sent by the API.
  final String qtyText;
  final double amount;

  double get denomination => parseAmount(type);
  double get qty => parseAmount(qtyText);

  factory NoteCount.fromJson(JsonMap json) => NoteCount(
        type: jsonString(json['ntype']) ?? '',
        qtyText: jsonString(json['qty']) ?? '0',
        amount: parseAmount(jsonString(json['amount'])),
      );
}

class EShopPayment {
  const EShopPayment({required this.referNo, required this.amount});

  final String referNo;
  final double amount;

  bool get isPayIn => referNo.toLowerCase() == ApiCodes.payInReference;

  factory EShopPayment.fromJson(JsonMap json) => EShopPayment(
        referNo: jsonString(json['referno']) ?? '',
        amount: parseAmount(jsonString(json['amount'])),
      );
}

class ForeignCurrencyCount {
  const ForeignCurrencyCount({
    required this.currencyCode,
    required this.rateText,
    required this.qtyText,
    required this.amount,
  });

  final String currencyCode;
  final String rateText;
  final String qtyText;

  /// Amount converted to THB.
  final double amount;

  factory ForeignCurrencyCount.fromJson(JsonMap json) => ForeignCurrencyCount(
        currencyCode: jsonString(json['currency_code']) ?? '',
        rateText: jsonString(json['rate']) ?? '0.00',
        qtyText: jsonString(json['qty']) ?? '0',
        amount: parseAmount(jsonString(json['amount'])),
      );
}
