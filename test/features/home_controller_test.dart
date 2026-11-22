import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:income_report/data/models/booking_payment.dart';
import 'package:income_report/data/models/pay_type.dart';
import 'package:income_report/data/models/seller_transaction.dart';
import 'package:income_report/data/services/income_api.dart';
import 'package:income_report/features/home/home_controller.dart';

/// Each day's list resolves only when the test completes it.
class _ControlledApi extends IncomeApi {
  final pending = <String, Completer<List<SellerTransaction>>>{};

  @override
  Future<List<SellerTransaction>> fetchAllTransactions({required String date}) =>
      (pending[date] = Completer()).future;

  @override
  Future<List<PayType>> fetchPayTypes() async => const [];

  @override
  Future<SellerTransaction?> fetchSellerTransaction({required String date, required String userId}) =>
      throw UnimplementedError();

  @override
  Future<List<BookingPayment>> fetchBookingPayments({required String userId, required String bookDate}) =>
      throw UnimplementedError();
}

SellerTransaction _seller(String code) =>
    SellerTransaction.fromJson({'userid': code, 'code': code, 'name': code});

void main() {
  test('a late response for a previous day does not overwrite the current day', () async {
    final api = _ControlledApi();
    final c = HomeController(api: api);
    final today = c.date;
    final yesterday = today.subtract(const Duration(days: 1));
    String key(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final first = c.loadSellers();
    final second = c.changeDate(yesterday);

    // Yesterday answers first, today's (stale) request answers last.
    api.pending[key(yesterday)]!.complete([_seller('YESTERDAY')]);
    await second;
    api.pending[key(today)]!.complete([_seller('TODAY')]);
    await first;

    expect(c.date, yesterday);
    expect(c.pendingSellers.map((s) => s.code), ['YESTERDAY']);
    expect(c.isLoadingSellers, isFalse);
  });

  test('search filters without touching the loaded list', () async {
    final api = _ControlledApi();
    final c = HomeController(api: api);
    final load = c.loadSellers();
    api.pending.values.single.complete([_seller('F001'), _seller('F002')]);
    await load;

    c.setSearch(' f002 ');
    expect(c.pendingSellers.map((s) => s.code), ['F002']);
    c.setSearch('');
    expect(c.pendingSellers, hasLength(2));
  });
}
