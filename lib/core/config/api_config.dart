/// Backend endpoints and network limits.
///
/// URLs can be overridden per build without code changes, e.g.
/// `flutter build web --dart-define=MARKETING_URL=http://10.0.0.5/marketing.php`.
abstract final class ApiConfig {
  /// Customer / marketing service: pay types, credit & advance bookings,
  /// seller verification flag.
  static const marketingUrl = String.fromEnvironment(
    'MARKETING_URL',
    defaultValue: 'http://172.2.100.14/clientele_cm/marketing.php',
  );

  /// Self-ticketing service: seller payment transactions.
  static const selfTicketingUrl = String.fromEnvironment(
    'SELF_TICKETING_URL',
    defaultValue: 'http://172.2.200.200/cmfrontapp/ticketing/ticketapi/datamodule/selfticketing.php',
  );

  /// Without these a dead server leaves the screen loading forever.
  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 30);
}
