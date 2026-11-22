import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import 'ui_kit.dart';

/// Full-width tile shown instead of the work area when the day has no
/// data or failed to load. Each state offers a way forward.
class DayStateView extends StatelessWidget {
  const DayStateView.empty({
    super.key,
    required this.date,
    required VoidCallback onPickDate,
    VoidCallback? onToday,
  })  : _error = null,
        _primary = onToday,
        _secondary = onPickDate;

  const DayStateView.error({
    super.key,
    required this.date,
    required String error,
    required VoidCallback onRetry,
  })  : _error = error,
        _primary = onRetry,
        _secondary = null;

  final DateTime date;
  final String? _error;
  final VoidCallback? _primary;
  final VoidCallback? _secondary;

  bool get _isError => _error != null;

  @override
  Widget build(BuildContext context) {
    final dateText = AppDateFormat.thaiLong(date);

    return Tile(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(dateText, size: 11, background: AppColors.sunken),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Illustration(isError: _isError),
                    const SizedBox(height: 18),
                    Text(_isError ? 'เกิดข้อผิดพลาด' : 'ไม่พบข้อมูล', style: AppText.display(size: 24)),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Text(
                        _isError
                            ? 'โหลดข้อมูลไม่สำเร็จ ตรวจสอบการเชื่อมต่อเครือข่าย แล้วลองอีกครั้ง '
                                'ข้อมูลที่ตรวจสอบไปแล้วจะไม่หาย'
                            : 'ยังไม่มีรายการส่งเงินของผู้จำหน่ายบัตรในวันที่ $dateText ลองเลือกวันอื่น',
                        textAlign: TextAlign.center,
                        style: AppText.body(color: AppColors.textMuted).copyWith(height: 1.65),
                      ),
                    ),
                    if (_isError) ...[
                      const SizedBox(height: 18),
                      _ErrorDetail(_error!),
                    ],
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: _isError ? _errorActions(context) : _emptyActions(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _emptyActions() => [
        PillButton(
          label: 'เลือกวันอื่น',
          icon: Icons.calendar_today_outlined,
          height: 46,
          onPressed: _secondary,
        ),
        if (_primary != null)
          PillButton(
            label: 'กลับไปวันนี้',
            style: PillButtonStyle.primary,
            height: 46,
            onPressed: _primary,
          ),
      ];

  List<Widget> _errorActions(BuildContext context) => [
        PillButton(
          label: 'คัดลอกรายละเอียด',
          icon: Icons.copy_rounded,
          height: 46,
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: _error!));
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('คัดลอกรายละเอียดแล้ว')));
            }
          },
        ),
        PillButton(
          label: 'ลองอีกครั้ง',
          icon: Icons.refresh_rounded,
          style: PillButtonStyle.primary,
          height: 46,
          onPressed: _primary,
        ),
      ];
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.isError});

  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isError ? AppColors.primarySoft : AppColors.sunken,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isError ? AppColors.primarySoftBorder : AppColors.border),
        ),
        child: Icon(
          isError ? Icons.warning_amber_rounded : Icons.inbox_outlined,
          size: 32,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}

class _ErrorDetail extends StatelessWidget {
  const _ErrorDetail(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.sunken,
        borderRadius: BorderRadius.circular(AppRadius.inner),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('รายละเอียด', style: AppText.body(size: 11, weight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(text, maxLines: 4, overflow: TextOverflow.ellipsis, style: AppText.body(size: 13)),
        ],
      ),
    );
  }
}
