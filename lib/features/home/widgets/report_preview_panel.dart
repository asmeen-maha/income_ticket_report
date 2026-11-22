import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import 'common.dart';

/// Right column: preview of the generated PDF with print / share actions.
class ReportPreviewPanel extends StatelessWidget {
  const ReportPreviewPanel({
    super.key,
    required this.report,
    required this.fileName,
    required this.isLoading,
    this.error,
  });

  final Uint8List? report;
  final String fileName;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.vw(.565),
      height: context.vh(.85),
      margin: EdgeInsets.only(left: context.vw(.01)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AppColors.previewBackground,
      ),
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    final bytes = report;
    if (error != null) return MessageText(error!, size: .015);
    if (isLoading) return _loader(context);
    if (bytes == null) return const MessageText('ไม่พบข้อมูล', size: .02);

    return PdfPreview(
      pdfFileName: fileName,
      allowPrinting: true,
      allowSharing: true,
      canDebug: false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      dynamicLayout: true,
      actionBarTheme: const PdfActionBarTheme(backgroundColor: AppColors.darkPink),
      loadingWidget: _loader(context),
      build: (_) => bytes,
      onError: (_, __) => const MessageText('เกิดข้อผิดพลาด', size: .015),
    );
  }

  Widget _loader(BuildContext context) => Center(
        child: LoadingAnimationWidget.hexagonDots(color: AppColors.pink, size: context.vw(.045)),
      );
}
