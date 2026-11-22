/// Backend endpoints used by the app.
abstract final class ApiConfig {
  /// Customer / marketing service: pay types, credit & advance bookings,
  /// seller verification flag.
  static const marketingUrl = 'http://172.2.100.14/clientele_cm/marketing.php';

  /// Self-ticketing service: seller payment transactions.
  static const selfTicketingUrl =
      'http://172.2.200.200/cmfrontapp/ticketing/ticketapi/datamodule/selfticketing.php';
}
