import 'package:flutter_test/flutter_test.dart';
import 'package:income_report/data/models/booking_payment.dart';
import 'package:income_report/data/models/daily_summary.dart';
import 'package:income_report/data/models/pay_type.dart';
import 'package:income_report/data/models/seller_transaction.dart';
import 'package:income_report/reports/daily_income/daily_income_report.dart';
import 'package:income_report/reports/seller_income/seller_income_report.dart';

bool _isPdf(List<int> bytes) => String.fromCharCodes(bytes.take(5)) == '%PDF-';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final seller = SellerTransaction.fromJson({
    'userid': '1',
    'code': 'F00001',
    'name': 'สมชาย ตัวอย่าง',
    'flagcheck': 'Y',
    'creditcard': [{'amount': '1200'}],
    'notesandcoins': [
      {'ntype': '1000', 'qty': '3', 'amount': '3000'},
      {'ntype': '0.25', 'qty': '4', 'amount': '1'},
    ],
    'payeshop': [{'referno': 'payIn', 'amount': '500'}],
    'notesandcoins_detail': [
      {'currency_code': '1', 'rate': '34.00', 'qty': '10', 'amount': '340'},
    ],
  });

  test('daily income statement renders', () async {
    final bytes = await DailyIncomeReport()
        .generate(date: DateTime(2025, 9, 29), summary: DailySummary.fromSellers([seller]));
    expect(_isPdf(bytes), isTrue);
  });

  test('seller income report renders with bookings', () async {
    final booking = BookingPayment.fromJson({
      'rsvn': '123',
      'agentcode': 'AG1',
      'agentname': 'Agent',
      'paytype': '4',
      'accode': '111',
      'amount': '900',
    });
    final bytes = await SellerIncomeReport(
      transaction: seller,
      advancePayments: [booking],
      creditPayments: const [],
      payTypes: const [PayType(accCode: '111', shortName: 'CASH')],
    ).generate(date: DateTime(2025, 9, 29), sellerName: seller.name, staffCode: seller.code);
    expect(_isPdf(bytes), isTrue);
  });
}
