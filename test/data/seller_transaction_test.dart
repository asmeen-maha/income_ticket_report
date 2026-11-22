import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:income_report/data/models/daily_summary.dart';
import 'package:income_report/data/models/json_utils.dart';
import 'package:income_report/data/models/seller_transaction.dart';

void main() {
  late List<SellerTransaction> sellers;

  setUpAll(() {
    final json = jsonDecode(File('test/fixtures/seller_transactions.json').readAsStringSync());
    sellers = parseJsonList(json, SellerTransaction.fromJson);
  });

  group('SellerTransaction', () {
    test('parses the API list and tolerates missing sections', () {
      expect(sellers, hasLength(2));
      final first = sellers.first;
      expect(first.code, 'F00424');
      expect(first.isVerified, isFalse);
      expect(first.creditCards, isEmpty);
      expect(first.notesAndCoins, isEmpty);
      expect(first.foreignCurrencies, isEmpty);
      expect(sellers[1].isVerified, isTrue);
    });

    test('splits pay-in out of e-shop (case-insensitive referno)', () {
      final s = sellers[1];
      expect(s.eShopTotal, 16200);
      expect(s.payInTotal, 5000);
      expect(s.eShopExcludingPayIn, 11200);
      expect(s.grandTotal, 16200);
    });

    test('accepts a single object where a list is expected', () {
      final s = SellerTransaction.fromJson({
        'userid': '1',
        'code': 'X',
        'name': 'N',
        'creditcard': {'cardno': '1', 'amount': '1,500.50'},
      });
      expect(s.creditCardTotal, 1500.50);
    });

    test('matches denominations numerically ("0.50" == 0.5)', () {
      final s = SellerTransaction.fromJson({
        'notesandcoins': [
          {'ntype': '1000', 'qty': '2', 'amount': '2000'},
          {'ntype': '0.50', 'qty': '3', 'amount': '1.5'},
          {'ntype': '1', 'qty': '7', 'amount': '7'},
        ],
      });
      expect(s.noteFor(1000)?.qtyText, '2');
      expect(s.noteFor(0.5)?.qtyText, '3');
      expect(s.noteFor(1)?.qtyText, '7');
      expect(s.noteFor(0.25), isNull);
      expect(s.notesAndCoinsTotal, 2008.5);
    });
  });

  test('empty or null bodies mean "no data", not an error', () {
    for (final body in ['', '  ', 'null', '[]']) {
      expect(parseJsonList(body, SellerTransaction.fromJson), isEmpty, reason: 'body "$body"');
    }
    expect(() => parseJsonList('<html>error</html>', SellerTransaction.fromJson),
        throwsFormatException);
  });

  group('DailySummary', () {
    test('sums sellers and merges denominations', () {
      final a = SellerTransaction.fromJson({
        'creditcard': [{'amount': '100'}],
        'notesandcoins': [{'ntype': '100', 'qty': '2', 'amount': '200'}],
        'payeshop': [
          {'referno': 'abc', 'amount': '50'},
          {'referno': 'payIn', 'amount': '30'},
        ],
        'notesandcoins_detail': [{'currency_code': '1', 'amount': '340'}],
      });
      final b = SellerTransaction.fromJson({
        'notesandcoins': [{'ntype': '100.00', 'qty': '1', 'amount': '100'}],
      });

      final summary = DailySummary.fromSellers([a, b]);

      expect(summary.notes[100]?.qty, 3);
      expect(summary.notes[100]?.amount, 300);
      expect(summary.creditCardTotal, 100);
      expect(summary.eShopTotal, 80);
      expect(summary.payInTotal, 30);
      expect(summary.eShopExcludingPayIn, 50);
      expect(summary.cashTotal, 640);
      expect(summary.grandTotal, 300 + 100 + 80 + 340);
    });
  });
}
