import 'package:intl/intl.dart';

abstract final class AppDateFormat {
  static final _api = DateFormat('yyyy-MM-dd');
  static final _slash = DateFormat('dd/MM/yyyy');
  static final _dash = DateFormat('dd-MM-yyyy');
  static final _day = DateFormat('dd');

  static const _thaiMonths = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  /// `2025-02-10` — the format the backend expects.
  static String api(DateTime date) => _api.format(date);

  /// `10/02/2025`
  static String slash(DateTime date) => _slash.format(date);

  /// `10-02-2025`
  static String dash(DateTime date) => _dash.format(date);

  /// `10 กุมภาพันธ์ 2568` (Buddhist year).
  static String thaiLong(DateTime date) =>
      '${_day.format(date)} ${_thaiMonths[date.month - 1]} ${date.year + 543}';
}
