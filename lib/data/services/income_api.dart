import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../models/booking_payment.dart';
import '../models/json_utils.dart';
import '../models/pay_type.dart';
import '../models/seller_transaction.dart';

/// HTTP calls to the ticketing backends. Every method throws on failure;
/// callers decide how to report it.
class IncomeApi {
  IncomeApi({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
            ));

  final Dio _dio;

  /// Every seller's transactions for [date] (`yyyy-MM-dd`).
  Future<List<SellerTransaction>> fetchAllTransactions({required String date}) {
    return _post(
      ApiConfig.selfTicketingUrl,
      {'param': 'reportpaymentall', 'showdate': date},
      (data) => parseJsonList(data, SellerTransaction.fromJson),
    );
  }

  /// One seller's transactions for [date] (`yyyy-MM-dd`).
  Future<SellerTransaction?> fetchSellerTransaction({
    required String date,
    required String userId,
  }) async {
    final list = await _post(
      ApiConfig.selfTicketingUrl,
      {'param': 'reportpayment', 'showdate': date, 'userid': userId},
      (data) => parseJsonList(data, SellerTransaction.fromJson),
    );
    return list.isEmpty ? null : list.first;
  }

  Future<List<PayType>> fetchPayTypes() {
    return _post(
      ApiConfig.marketingUrl,
      {'param': 'listtypepay'},
      (data) => parseJsonList(data, PayType.fromJson),
    );
  }

  /// Credit and advance-payment bookings a seller collected on [bookDate].
  Future<List<BookingPayment>> fetchBookingPayments({
    required String userId,
    required String bookDate,
  }) {
    return _post(
      ApiConfig.marketingUrl,
      {'param': 'listcus', 'userid': userId, 'bookdate': bookDate},
      (data) => parseJsonList(data, BookingPayment.fromJson),
    );
  }

  /// Sets the seller's verification flag (`Y` / `N`) for [date].
  Future<void> setSellerVerified({
    required String date,
    required String userId,
    required String flag,
  }) {
    return _post(
      ApiConfig.marketingUrl,
      {'param': 'userflagcheck', 'saledate': date, 'userid': userId, 'flagcheck': flag},
      (_) {},
    );
  }

  Future<T> _post<T>(
    String url,
    Map<String, dynamic> fields,
    T Function(dynamic data) parse,
  ) async {
    final response = await _dio.post(url, data: FormData.fromMap(fields));
    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'HTTP ${response.statusCode} from ${fields['param']}',
      );
    }
    return parse(response.data);
  }
}
