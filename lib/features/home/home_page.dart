import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';
import '../../data/models/seller_transaction.dart';
import 'home_controller.dart';
import 'widgets/day_state_view.dart';
import 'widgets/home_header.dart';
import 'widgets/kpi_row.dart';
import 'widgets/report_preview_panel.dart';
import 'widgets/seller_detail_panel.dart';
import 'widgets/seller_list_panel.dart';
import 'widgets/ui_kit.dart';
import 'widgets/verify_seller_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.controller});

  /// Injected in tests; the page creates its own otherwise.
  final HomeController? controller;

  static const version = 'V0.0.7';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller = widget.controller ?? HomeController();

  /// Below these sizes the three columns no longer fit; the page scrolls.
  static const _wideLayoutMinWidth = 1200.0;
  static const _fixedLayoutMinHeight = 760.0;
  static const _gap = 16.0;

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) await _controller.changeDate(picked);
  }

  Future<void> _verify(SellerTransaction seller) async {
    final detail = _controller.sellerDetail;
    if (detail == null || !_controller.isSelected(seller) || seller.isVerified) return;

    final verified = await showVerifySellerDialog(
      context,
      seller: seller,
      detail: detail,
      date: _controller.date,
      onConfirm: () => _controller.verifySeller(seller),
    );
    if (verified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ตรวจสอบ ${seller.code} ${seller.name} แล้ว')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => LayoutBuilder(builder: _buildPage),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, BoxConstraints constraints) {
    final c = _controller;
    final wide = constraints.maxWidth >= _wideLayoutMinWidth;
    final scrolls = !wide || constraints.maxHeight < _fixedLayoutMinHeight;
    final showWorkArea = c.hasSellers && c.sellersError == null;

    final header = HomeHeader(
      version: HomePage.version,
      date: c.date,
      canGoToNextDay: c.canGoToNextDay,
      onPreviousDay: c.previousDay,
      onNextDay: c.nextDay,
      onPickDate: _pickDate,
      onDailyReport: c.canGenerateDailyReport ? c.showDailyReport : null,
    );

    final body = showWorkArea ? _workArea(wide: wide) : _dayState();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: _gap),
        if (showWorkArea) ...[
          KpiRow(overview: c.overview),
          const SizedBox(height: _gap),
        ],
        if (scrolls) body else Expanded(child: body),
      ],
    );

    final padded = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1680),
        child: Padding(padding: const EdgeInsets.fromLTRB(28, 20, 28, 28), child: content),
      ),
    );

    return scrolls ? SingleChildScrollView(child: padded) : padded;
  }

  /// Loading, error or empty — replaces the three columns.
  Widget _dayState() {
    final c = _controller;
    final Widget child;
    if (c.isLoadingSellers) {
      child = const Tile(child: LoadingView(message: 'กำลังโหลดข้อมูล'));
    } else if (c.sellersError != null) {
      child = DayStateView.error(date: c.date, error: c.sellersError!, onRetry: c.loadSellers);
    } else {
      child = DayStateView.empty(
        date: c.date,
        onPickDate: _pickDate,
        onToday: c.isToday ? null : c.goToToday,
      );
    }
    return ConstrainedBox(constraints: const BoxConstraints(minHeight: 520), child: child);
  }

  Widget _workArea({required bool wide}) {
    final c = _controller;
    final seller = c.selectedSeller;

    final list = SellerListPanel(
      pending: c.pendingSellers,
      verified: c.verifiedSellers,
      isSelected: c.isSelected,
      onSearch: c.setSearch,
      onSelect: c.selectSeller,
      onVerify: _verify,
    );
    final detail = SellerDetailPanel(
      seller: seller,
      detail: c.sellerDetail,
      isLoading: c.isLoadingDetail,
      onVerify: () {
        if (seller != null) _verify(seller);
      },
    );
    final preview = ReportPreviewPanel(
      kind: c.reportKind,
      report: c.report,
      fileName: c.reportFileName,
      caption: switch (c.reportKind) {
        ReportKind.daily => 'ใบสรุปส่งเงินรายได้ · ${AppDateFormat.thaiLong(c.date)} · A4 แนวตั้ง',
        _ => 'ใบนำส่งรายได้ฝ่ายบัตร · ${seller?.name ?? ''} · A4 แนวนอน',
      },
      isLoading: c.isGeneratingReport,
      error: c.reportError,
      onShowSeller: seller == null ? null : c.showSellerReport,
      onShowDaily: c.canGenerateDailyReport ? c.showDailyReport : null,
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 300, child: list),
          const SizedBox(width: _gap),
          SizedBox(width: 380, child: detail),
          const SizedBox(width: _gap),
          Expanded(child: preview),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 680,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 300, child: list),
              const SizedBox(width: _gap),
              Expanded(child: detail),
            ],
          ),
        ),
        const SizedBox(height: _gap),
        SizedBox(height: 760, child: preview),
      ],
    );
  }
}
