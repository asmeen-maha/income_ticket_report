import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../home_controller.dart';
import 'ui_kit.dart';

/// Right tile: document switcher, PDF preview, zoom and print / share.
class ReportPreviewPanel extends StatefulWidget {
  const ReportPreviewPanel({
    super.key,
    required this.kind,
    required this.report,
    required this.fileName,
    required this.caption,
    required this.isLoading,
    required this.error,
    required this.onShowSeller,
    required this.onShowDaily,
  });

  final ReportKind? kind;
  final Uint8List? report;
  final String fileName;

  /// Line under the page, e.g. "ใบนำส่งรายได้ฝ่ายบัตร · ชื่อผู้จำหน่าย".
  final String caption;
  final bool isLoading;
  final String? error;

  /// Null disables that tab.
  final VoidCallback? onShowSeller;
  final VoidCallback? onShowDaily;

  @override
  State<ReportPreviewPanel> createState() => _ReportPreviewPanelState();
}

class _ReportPreviewPanelState extends State<ReportPreviewPanel> {
  static const _zoomSteps = [.5, .75, 1.0, 1.25, 1.5, 2.0];
  static const _basePageWidth = 760.0;
  int _zoomIndex = 2;

  double get _zoom => _zoomSteps[_zoomIndex];

  /// PdfPreview re-rasterises whenever its `build` callback changes
  /// identity, so keep one callback per document instead of a new closure
  /// on every rebuild (e.g. each keystroke in the seller search).
  LayoutCallback? _build;

  @override
  void initState() {
    super.initState();
    _build = _callbackFor(widget.report);
  }

  @override
  void didUpdateWidget(ReportPreviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.report, widget.report)) _build = _callbackFor(widget.report);
  }

  static LayoutCallback? _callbackFor(Uint8List? bytes) =>
      bytes == null ? null : (_) async => bytes;

  Future<void> _print(Uint8List bytes) =>
      Printing.layoutPdf(onLayout: (_) async => bytes, name: widget.fileName);

  Future<void> _share(Uint8List bytes) =>
      Printing.sharePdf(bytes: bytes, filename: '${widget.fileName}.pdf');

  @override
  Widget build(BuildContext context) {
    final bytes = widget.report;

    return Tile(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text('ตัวอย่างเอกสาร', style: AppText.display()),
                _Segmented(
                  options: [
                    ('ใบนำส่งรายได้ · รายบุคคล', widget.kind == ReportKind.seller, widget.onShowSeller),
                    ('ใบสรุปส่งเงินรายได้ · ทั้งวัน', widget.kind == ReportKind.daily, widget.onShowDaily),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.row),
              child: ColoredBox(color: AppColors.sand, child: _preview(bytes)),
            ),
          ),
          if (bytes != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(widget.caption, style: AppText.caption(color: AppColors.textSubtle)),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _ZoomControl(
                percent: (_zoom * 100).round(),
                onZoomOut: bytes != null && _zoomIndex > 0 ? () => setState(() => _zoomIndex--) : null,
                onZoomIn: bytes != null && _zoomIndex < _zoomSteps.length - 1
                    ? () => setState(() => _zoomIndex++)
                    : null,
              ),
              Wrap(spacing: 8, runSpacing: 8, children: [
                PillButton(
                  // On the web "share" saves the file.
                  label: kIsWeb ? 'ดาวน์โหลด' : 'แชร์',
                  icon: kIsWeb ? Icons.download_rounded : Icons.ios_share_rounded,
                  onPressed: bytes == null ? null : () => _share(bytes),
                ),
                PillButton(
                  label: 'พิมพ์',
                  icon: Icons.print_outlined,
                  style: PillButtonStyle.dark,
                  onPressed: bytes == null ? null : () => _print(bytes),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _preview(Uint8List? bytes) {
    if (widget.error != null) {
      return _Message(icon: Icons.error_outline_rounded, text: widget.error!);
    }
    if (widget.isLoading) return const LoadingView(message: 'กำลังสร้างเอกสาร');
    if (bytes == null) {
      return const _Message(
        icon: Icons.description_outlined,
        text: 'เลือกผู้จำหน่ายบัตร หรือกดใบสรุปส่งเงินรายได้\nเพื่อดูตัวอย่างเอกสาร',
      );
    }

    // Zoom only changes maxPageWidth: the rendered pages are rescaled, not
    // re-rasterised.
    return PdfPreview(
      build: _build!,
      pdfFileName: widget.fileName,
      useActions: false,
      canDebug: false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      maxPageWidth: _basePageWidth * _zoom,
      previewPageMargin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      scrollViewDecoration: const BoxDecoration(color: AppColors.sand),
      pdfPreviewPageDecoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 30, offset: Offset(0, 14))],
      ),
      loadingWidget: const LoadingView(),
      onError: (_, __) => const _Message(icon: Icons.error_outline_rounded, text: 'แสดงเอกสารไม่สำเร็จ'),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTile(icon: icon, size: 52, background: AppColors.surface, foreground: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: AppText.body(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

/// Pill-shaped toggle. Each option: label, selected, onTap (null = disabled).
class _Segmented extends StatelessWidget {
  const _Segmented({required this.options});

  final List<(String, bool, VoidCallback?)> options;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.sunken,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Wrap(
        spacing: 4,
        children: [
          for (final (label, selected, onTap) in options)
            Semantics(
              selected: selected,
              button: true,
              child: SizedBox(
                height: 38,
                child: TextButton(
                  onPressed: selected ? null : onTap,
                  style: TextButton.styleFrom(
                    backgroundColor: selected ? AppColors.surface : Colors.transparent,
                    disabledBackgroundColor: selected ? AppColors.surface : Colors.transparent,
                    foregroundColor: AppColors.textSubtle,
                    disabledForegroundColor: selected ? AppColors.text : AppColors.disabledIcon,
                    elevation: selected ? 1 : 0,
                    shadowColor: AppColors.shadow,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const StadiumBorder(),
                    textStyle: AppText.body(
                      size: 13,
                      weight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  child: Text(label),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoomControl extends StatelessWidget {
  const _ZoomControl({required this.percent, required this.onZoomOut, required this.onZoomIn});

  final int percent;
  final VoidCallback? onZoomOut;
  final VoidCallback? onZoomIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.sunken,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundIconButton(icon: Icons.remove_rounded, tooltip: 'ย่อ', onPressed: onZoomOut, size: 40),
          SizedBox(
            width: 48,
            child: Text('$percent%',
                textAlign: TextAlign.center,
                style: AppText.body(size: 13, weight: FontWeight.w600, color: AppColors.textSubtle)),
          ),
          RoundIconButton(icon: Icons.add_rounded, tooltip: 'ขยาย', onPressed: onZoomIn, size: 40),
        ],
      ),
    );
  }
}
