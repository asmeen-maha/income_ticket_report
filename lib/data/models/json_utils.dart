import 'dart:convert';

typedef JsonMap = Map<String, dynamic>;

/// The API sometimes returns a JSON string instead of decoded JSON.
dynamic decodeJson(dynamic data) => data is String ? jsonDecode(data) : data;

/// Reads a field that may be a list of objects, a single object, or absent.
List<T> parseJsonList<T>(dynamic value, T Function(JsonMap json) fromJson) {
  final decoded = decodeJson(value);
  if (decoded is List) {
    return decoded.whereType<Map>().map((e) => fromJson(JsonMap.from(e))).toList();
  }
  if (decoded is Map) {
    return [fromJson(JsonMap.from(decoded))];
  }
  return const [];
}

/// Reads a field as a string whatever JSON type the API used.
String? jsonString(dynamic value) => value?.toString();
