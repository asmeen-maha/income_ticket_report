import '../../core/constants/cash_constants.dart';
import '../../core/utils/money_utils.dart';
import 'json_utils.dart';

/// A reservation paid on credit or in advance, collected by a seller.
class BookingPayment {
  const BookingPayment({
    required this.rsvn,
    required this.agentCode,
    required this.agentName,
    required this.payType,
    required this.accCode,
    required this.amountText,
  });

  final String rsvn;
  final String agentCode;
  final String agentName;

  /// `2` = credit, `4` = advance payment. See [ApiCodes].
  final String payType;

  /// `111` = cash, `114` = credit card. See [ApiCodes].
  final String accCode;

  /// Amount exactly as returned by the API (printed as-is on the report).
  final String amountText;

  double get amount => parseAmount(amountText);
  bool get isCredit => payType == ApiCodes.payTypeCredit;
  bool get isAdvance => payType == ApiCodes.payTypeAdvance;
  bool get isPaidCash => accCode == ApiCodes.accountCash;
  bool get isPaidByCard => accCode == ApiCodes.accountCredit;

  factory BookingPayment.fromJson(JsonMap json) => BookingPayment(
        rsvn: jsonString(json['rsvn']) ?? '',
        agentCode: jsonString(json['agentcode']) ?? '',
        agentName: jsonString(json['agentname']) ?? '',
        payType: jsonString(json['paytype']) ?? '',
        accCode: jsonString(json['accode']) ?? '',
        amountText: jsonString(json['amount']) ?? '0',
      );
}
