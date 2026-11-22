import 'json_utils.dart';

/// Payment account (e.g. `111` = cash) and its short display name.
class PayType {
  const PayType({required this.accCode, required this.shortName});

  final String accCode;
  final String shortName;

  factory PayType.fromJson(JsonMap json) => PayType(
        accCode: jsonString(json['acccode']) ?? '',
        shortName: jsonString(json['shutname']) ?? '',
      );
}
