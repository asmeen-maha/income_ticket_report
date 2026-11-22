import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/seller_transaction.dart';
import 'home_controller.dart';
import 'widgets/cash_breakdown_panel.dart';
import 'widgets/common.dart';
import 'widgets/home_toolbar.dart';
import 'widgets/report_preview_panel.dart';
import 'widgets/seller_list_panel.dart';
import 'widgets/verify_seller_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const version = 'V0.0.7';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = HomeController();
  late final _progress = SimpleFontelicoProgressDialog(context: context);

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify(SellerTransaction seller, bool verified) async {
    if (!await confirmVerifySeller(context)) return;

    _progress.show(
      message: 'Loading...',
      type: SimpleFontelicoProgressDialogType.custom,
      hideText: true,
      loadingIndicator:
          LoadingAnimationWidget.threeArchedCircle(color: AppColors.golden, size: 100),
      backgroundColor: Colors.transparent,
    );
    try {
      await _controller.verifySeller(seller, verified: verified);
    } catch (e) {
      debugPrint('verifySeller failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกไม่สำเร็จ กรุณาลองใหม่')),
        );
      }
    } finally {
      _progress.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(fontFamily: AppFonts.trajanPro, color: AppColors.white);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.pink,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Income report', style: titleStyle.copyWith(fontSize: context.vw(.011))),
            Text(HomePage.version, style: titleStyle.copyWith(fontSize: context.vw(.008))),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final c = _controller;
          return Column(
            children: [
              HomeToolbar(
                date: c.date,
                onDateChanged: c.changeDate,
                onDailyReport: c.canGenerateDailyReport ? c.generateDailyReport : null,
              ),
              SizedBox(height: context.vh(.01)),
              Row(
                children: [
                  SellerListPanel(
                    sellers: c.sellers,
                    isLoading: c.isLoadingSellers,
                    isSelected: c.isSelected,
                    onSelect: c.selectSeller,
                    onVerify: _verify,
                  ),
                  CashBreakdownPanel(detail: c.sellerDetail),
                  ReportPreviewPanel(
                    report: c.report,
                    fileName: '${c.reportTitle} ${AppDateFormat.dash(c.date)}',
                    isLoading: c.isGeneratingReport,
                    error: c.error,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
