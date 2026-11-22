import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;

import '../../core/constants/cash_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/booking_payment.dart';
import '../../data/models/daily_summary.dart';
import '../../data/models/day_overview.dart';
import '../../data/models/pay_type.dart';
import '../../data/models/seller_transaction.dart';
import '../../data/services/income_api.dart';
import '../../reports/daily_income/daily_income_report.dart';
import '../../reports/seller_income/seller_income_report.dart';

/// Which document the preview shows.
enum ReportKind { seller, daily }

/// State and actions of the home screen: pick a date, review each seller's
/// submission, verify it, and preview the PDF reports.
class HomeController extends ChangeNotifier {
  HomeController({IncomeApi? api}) : _api = api ?? IncomeApi();

  final IncomeApi _api;

  // Day
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  List<PayType> _payTypes = const [];
  List<SellerTransaction> _sellers = const [];
  bool _isLoadingSellers = true;
  String? _sellersError;
  DayOverview _overview = DayOverview.fromSellers(const []);
  DailySummary? _dailySummary;
  String _search = '';
  List<SellerTransaction> _pending = const [];
  List<SellerTransaction> _verified = const [];

  // Selected seller
  SellerTransaction? _selectedSeller;
  SellerTransaction? _sellerDetail;
  bool _isLoadingDetail = false;

  // Preview
  ReportKind? _reportKind;
  Uint8List? _report;
  bool _isGeneratingReport = false;
  String? _reportError;

  /// Already-rendered documents, so switching tabs is instant. Cleared
  /// whenever the day's data is reloaded.
  ({String sellerCode, Uint8List bytes})? _sellerReportCache;
  Uint8List? _dailyReportCache;

  /// Guard against a slow response for an earlier request overwriting the
  /// one the user made last: one counter for the preview, one for the list.
  int _requestId = 0;
  int _loadId = 0;

  // ---------------------------------------------------------------------------
  // Read-only state
  // ---------------------------------------------------------------------------

  DateTime get date => _date;
  bool get canGoToNextDay => _date.isBefore(_today);
  bool get isToday => DateUtils.isSameDay(_date, _today);

  bool get isLoadingSellers => _isLoadingSellers;
  String? get sellersError => _sellersError;
  bool get hasSellers => _sellers.isNotEmpty;
  DayOverview get overview => _overview;

  String get search => _search;
  List<SellerTransaction> get pendingSellers => _pending;
  List<SellerTransaction> get verifiedSellers => _verified;

  SellerTransaction? get selectedSeller => _selectedSeller;
  bool isSelected(SellerTransaction seller) => seller.code == _selectedSeller?.code;

  /// Breakdown of the selected seller, once loaded.
  SellerTransaction? get sellerDetail => _sellerDetail;
  bool get isLoadingDetail => _isLoadingDetail;

  /// The daily statement needs at least one verified seller.
  bool get canGenerateDailyReport => _dailySummary != null;

  ReportKind? get reportKind => _reportKind;
  Uint8List? get report => _report;
  bool get isGeneratingReport => _isGeneratingReport;
  String? get reportError => _reportError;

  String get reportFileName => switch (_reportKind) {
        ReportKind.seller =>
          'ใบนำส่งรายได้ ${_selectedSeller?.code ?? ''} ${AppDateFormat.dash(_date)}',
        ReportKind.daily => '${DailyIncomeReport.title} ${AppDateFormat.dash(_date)}',
        null => 'report',
      };

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    await Future.wait([_loadPayTypes(), loadSellers()]);
  }

  Future<void> changeDate(DateTime date) async {
    final day = DateUtils.dateOnly(date);
    if (DateUtils.isSameDay(day, _date) || day.isAfter(_today)) return;
    _date = day;
    _requestId++;
    _selectedSeller = null;
    _sellerDetail = null;
    _isLoadingDetail = false;
    _reportKind = null;
    _sellerReportCache = null;
    _clearReport();
    notifyListeners();
    await loadSellers();
  }

  Future<void> previousDay() => changeDate(_date.subtract(const Duration(days: 1)));
  Future<void> nextDay() => changeDate(_date.add(const Duration(days: 1)));
  Future<void> goToToday() => changeDate(_today);

  void setSearch(String value) {
    final search = value.trim();
    if (search == _search) return;
    _search = search;
    _applyFilter();
    notifyListeners();
  }

  /// Reloads the selected day. A response for a day the user has already
  /// left is dropped.
  Future<void> loadSellers() async {
    final loadId = ++_loadId;
    final date = _date;
    _isLoadingSellers = true;
    _sellersError = null;
    notifyListeners();

    List<SellerTransaction> sellers;
    String? error;
    try {
      sellers = await _api.fetchAllTransactions(date: AppDateFormat.api(date));
    } catch (e) {
      debugPrint('loadSellers failed: $e');
      sellers = const [];
      error = e.toString();
    }
    if (loadId != _loadId) return;

    _setSellers(sellers);
    _sellersError = error;
    _isLoadingSellers = false;
    notifyListeners();

    // The open daily statement reflects the old totals: rebuild it.
    if (_reportKind == ReportKind.daily && _dailySummary != null) await showDailyReport();
  }

  /// Loads the seller's breakdown and bookings, then renders their report.
  Future<void> selectSeller(SellerTransaction seller) async {
    final requestId = ++_requestId;
    _selectedSeller = seller;
    _sellerDetail = null;
    _isLoadingDetail = true;
    _startReport(ReportKind.seller);

    try {
      final date = AppDateFormat.api(_date);
      final (detail, bookings) = await (
        _api.fetchSellerTransaction(date: date, userId: seller.userId),
        _api.fetchBookingPayments(userId: seller.userId, bookDate: date),
      ).wait;
      if (requestId != _requestId) return;
      if (detail == null) throw StateError('No transaction for ${seller.code}');

      _sellerDetail = detail;
      _isLoadingDetail = false;
      notifyListeners();

      bool hasAmount(BookingPayment b) => b.amount > 0;
      final report = await SellerIncomeReport(
        transaction: detail,
        advancePayments: bookings.where((b) => b.isAdvance && hasAmount(b)).toList(),
        creditPayments: bookings.where((b) => b.isCredit && hasAmount(b)).toList(),
        payTypes: _payTypes,
      ).generate(date: _date, sellerName: seller.name, staffCode: seller.code);
      if (requestId != _requestId) return;

      _sellerReportCache = (sellerCode: seller.code, bytes: report);
      _finishReport(report);
    } catch (e) {
      if (requestId != _requestId) return;
      debugPrint('selectSeller failed: $e');
      _isLoadingDetail = false;
      _failReport();
    }
  }

  /// Switches the preview back to the selected seller's report, reusing the
  /// one already rendered when possible.
  Future<void> showSellerReport() async {
    final seller = _selectedSeller;
    if (seller == null || _reportKind == ReportKind.seller) return;

    final cached = _sellerReportCache;
    if (cached != null && cached.sellerCode == seller.code && _sellerDetail != null) {
      _requestId++;
      _startReport(ReportKind.seller);
      _finishReport(cached.bytes);
      return;
    }
    await selectSeller(seller);
  }

  Future<void> showDailyReport() async {
    final summary = _dailySummary;
    if (summary == null) return;

    final requestId = ++_requestId;
    _startReport(ReportKind.daily);

    final cached = _dailyReportCache;
    if (cached != null) {
      _finishReport(cached);
      return;
    }
    try {
      final report = await DailyIncomeReport().generate(date: _date, summary: summary);
      if (requestId != _requestId) return;
      _dailyReportCache = report;
      _finishReport(report);
    } catch (e) {
      if (requestId != _requestId) return;
      debugPrint('showDailyReport failed: $e');
      _failReport();
    }
  }

  /// Marks the seller as verified and reloads the day so totals update.
  /// Throws if the server call fails.
  Future<void> verifySeller(SellerTransaction seller) async {
    await _api.setSellerVerified(
      date: AppDateFormat.api(_date),
      userId: seller.userId,
      flag: ApiCodes.verified,
    );
    await loadSellers();
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  DateTime get _today => DateUtils.dateOnly(DateTime.now());

  /// Recomputes the two list groups; run only when the list or the search
  /// changes, not on every build.
  void _applyFilter() {
    final query = _search.toLowerCase();
    final matches = query.isEmpty
        ? _sellers
        : _sellers.where(
            (s) => s.code.toLowerCase().contains(query) || s.name.toLowerCase().contains(query),
          );
    _pending = matches.where((s) => !s.isVerified).toList(growable: false);
    _verified = matches.where((s) => s.isVerified).toList(growable: false);
  }

  void _setSellers(List<SellerTransaction> sellers) {
    _sellers = sellers;
    _overview = DayOverview.fromSellers(sellers);
    final verified = sellers.where((s) => s.isVerified).toList();
    _dailySummary = verified.isEmpty ? null : DailySummary.fromSellers(verified);
    _dailyReportCache = null;
    _applyFilter();

    // Keep the selection pointing at the refreshed row (e.g. after verifying).
    final selected = _selectedSeller;
    if (selected != null) {
      _selectedSeller = sellers.where((s) => s.code == selected.code).firstOrNull ?? selected;
    }
  }

  Future<void> _loadPayTypes() async {
    try {
      _payTypes = await _api.fetchPayTypes();
    } catch (e) {
      debugPrint('loadPayTypes failed: $e');
    }
  }

  void _startReport(ReportKind kind) {
    _reportKind = kind;
    _clearReport();
    _isGeneratingReport = true;
    notifyListeners();
  }

  void _finishReport(Uint8List bytes) {
    _report = bytes;
    _isGeneratingReport = false;
    notifyListeners();
  }

  void _failReport() {
    _reportError = 'สร้างเอกสารไม่สำเร็จ';
    _isGeneratingReport = false;
    notifyListeners();
  }

  void _clearReport() {
    _report = null;
    _reportError = null;
    _isGeneratingReport = false;
  }
}
