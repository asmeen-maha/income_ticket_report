import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;

import '../../core/constants/cash_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/booking_payment.dart';
import '../../data/models/daily_summary.dart';
import '../../data/models/pay_type.dart';
import '../../data/models/seller_transaction.dart';
import '../../data/services/income_api.dart';
import '../../reports/daily_income/daily_income_report.dart';
import '../../reports/seller_income/seller_income_header.dart';
import '../../reports/seller_income/seller_income_report.dart';

/// State and actions of the home screen: pick a date, review each seller's
/// submission, verify it, and preview the PDF reports.
class HomeController extends ChangeNotifier {
  HomeController({IncomeApi? api}) : _api = api ?? IncomeApi();

  final IncomeApi _api;

  DateTime _date = DateTime.now();
  List<PayType> _payTypes = const [];

  List<SellerTransaction> _sellers = const [];
  bool _isLoadingSellers = false;
  DailySummary? _dailySummary;

  SellerTransaction? _selectedSeller;
  SellerTransaction? _sellerDetail;

  Uint8List? _report;
  String _reportTitle = '';
  bool _isGeneratingReport = false;
  String? _error;

  /// Guards against a slow response for a previous seller overwriting the
  /// one the user picked last.
  int _requestId = 0;

  DateTime get date => _date;
  List<SellerTransaction> get sellers => _sellers;
  bool get isLoadingSellers => _isLoadingSellers;
  SellerTransaction? get selectedSeller => _selectedSeller;

  /// Breakdown of the selected seller, once loaded.
  SellerTransaction? get sellerDetail => _sellerDetail;

  Uint8List? get report => _report;
  String get reportTitle => _reportTitle;
  bool get isGeneratingReport => _isGeneratingReport;
  String? get error => _error;

  /// The daily statement needs at least one verified seller.
  bool get canGenerateDailyReport => _dailySummary != null;

  bool isSelected(SellerTransaction seller) => seller.code == _selectedSeller?.code;

  Future<void> init() async {
    await Future.wait([_loadPayTypes(), loadSellers()]);
  }

  Future<void> changeDate(DateTime date) async {
    if (DateUtils.isSameDay(date, _date)) return;
    _date = date;
    _requestId++;
    _selectedSeller = null;
    _sellerDetail = null;
    _clearReport();
    notifyListeners();
    await loadSellers();
  }

  Future<void> loadSellers() async {
    _isLoadingSellers = true;
    notifyListeners();
    try {
      _sellers = await _api.fetchAllTransactions(date: AppDateFormat.api(_date));
      final verified = _sellers.where((s) => s.isVerified).toList();
      _dailySummary = verified.isEmpty ? null : DailySummary.fromSellers(verified);
    } catch (e) {
      debugPrint('loadSellers failed: $e');
      _sellers = const [];
      _dailySummary = null;
    } finally {
      _isLoadingSellers = false;
      notifyListeners();
    }
  }

  /// Loads the seller's breakdown and bookings, then renders their report.
  Future<void> selectSeller(SellerTransaction seller) async {
    final requestId = ++_requestId;
    _selectedSeller = seller;
    _clearReport();
    _isGeneratingReport = true;
    notifyListeners();

    try {
      final date = AppDateFormat.api(_date);
      final (detail, bookings) = await (
        _api.fetchSellerTransaction(date: date, userId: seller.userId),
        _api.fetchBookingPayments(userId: seller.userId, bookDate: date),
      ).wait;
      if (requestId != _requestId) return;

      if (detail == null) throw StateError('No transaction for ${seller.code}');
      _sellerDetail = detail;
      notifyListeners();

      bool hasAmount(BookingPayment b) => b.amount > 0;
      final report = await SellerIncomeReport(
        transaction: detail,
        advancePayments: bookings.where((b) => b.isAdvance && hasAmount(b)).toList(),
        creditPayments: bookings.where((b) => b.isCredit && hasAmount(b)).toList(),
        payTypes: _payTypes,
      ).generate(date: _date, sellerName: seller.name, staffCode: seller.code);
      if (requestId != _requestId) return;

      _setReport(SellerIncomeHeader.titleThai, report);
    } catch (e) {
      if (requestId != _requestId) return;
      debugPrint('selectSeller failed: $e');
      _sellerDetail = null;
      _setError();
    }
  }

  /// Marks the seller as checked, then reloads the day so totals update.
  Future<void> verifySeller(SellerTransaction seller, {required bool verified}) async {
    await _api.setSellerVerified(
      date: AppDateFormat.api(_date),
      userId: seller.userId,
      flag: verified ? ApiCodes.verified : ApiCodes.notVerified,
    );
    await loadSellers();
  }

  Future<void> generateDailyReport() async {
    final summary = _dailySummary;
    if (summary == null) return;

    final requestId = ++_requestId;
    _clearReport();
    _isGeneratingReport = true;
    notifyListeners();

    try {
      final report = await DailyIncomeReport().generate(date: _date, summary: summary);
      if (requestId != _requestId) return;
      _setReport(DailyIncomeReport.title, report);
    } catch (e) {
      if (requestId != _requestId) return;
      debugPrint('generateDailyReport failed: $e');
      _setError();
    }
  }

  Future<void> _loadPayTypes() async {
    try {
      _payTypes = await _api.fetchPayTypes();
    } catch (e) {
      debugPrint('loadPayTypes failed: $e');
    }
  }

  void _setReport(String title, Uint8List bytes) {
    _reportTitle = title;
    _report = bytes;
    _isGeneratingReport = false;
    notifyListeners();
  }

  void _setError() {
    _error = 'เกิดข้อผิดพลาด';
    _isGeneratingReport = false;
    notifyListeners();
  }

  void _clearReport() {
    _report = null;
    _error = null;
  }
}
