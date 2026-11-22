import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import 'ui_kit.dart';

/// Logo and title on the left; date stepper and the daily-statement button
/// on the right.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.version,
    required this.date,
    required this.canGoToNextDay,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onPickDate,
    required this.onDailyReport,
  });

  final String version;
  final DateTime date;
  final bool canGoToNextDay;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onPickDate;

  /// Null disables the button and shows why.
  final VoidCallback? onDailyReport;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        _Brand(version: version),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DateStepper(
              date: date,
              canGoToNextDay: canGoToNextDay,
              onPrevious: onPreviousDay,
              onNext: onNextDay,
              onPick: onPickDate,
            ),
            DailyReportButton(onPressed: onDailyReport),
          ],
        ),
      ],
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.confirmation_number_outlined, color: AppColors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Text('Income Report', style: AppText.display(size: 21)),
        const SizedBox(width: 12),
        Pill(version),
      ],
    );
  }
}

/// ‹ date › pill. The date opens a picker; "next" stops at today.
class DateStepper extends StatelessWidget {
  const DateStepper({
    super.key,
    required this.date,
    required this.canGoToNextDay,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
  });

  final DateTime date;
  final bool canGoToNextDay;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final label = AppDateFormat.thaiLong(date);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'วันก่อนหน้า',
            onPressed: onPrevious,
          ),
          Semantics(
            label: 'เลือกวันที่ $label',
            button: true,
            child: SizedBox(
              height: 44,
              child: TextButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(label),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.sunken,
                  foregroundColor: AppColors.text,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const StadiumBorder(),
                  textStyle: AppText.body(weight: FontWeight.w600),
                ),
              ),
            ),
          ),
          RoundIconButton(
            icon: Icons.chevron_right_rounded,
            tooltip: canGoToNextDay ? 'วันถัดไป' : 'วันถัดไป (ไม่เกินวันนี้)',
            onPressed: canGoToNextDay ? onNext : null,
          ),
        ],
      ),
    );
  }
}

/// Two-line primary button. Disabled until a seller is verified, with the
/// reason shown underneath.
class DailyReportButton extends StatelessWidget {
  const DailyReportButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final foreground = enabled ? AppColors.white : AppColors.textMuted;

    final button = SizedBox(
      height: enabled ? 50 : 44,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.sand,
          padding: const EdgeInsets.fromLTRB(16, 0, 20, 0),
          shape: StadiumBorder(
            side: enabled ? BorderSide.none : const BorderSide(color: AppColors.borderStrong),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(enabled ? Icons.description_outlined : Icons.lock_outline_rounded,
                size: 18, color: foreground),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ใบสรุปส่งเงินรายได้',
                    style: AppText.body(weight: FontWeight.w600, color: foreground)),
                if (enabled)
                  Text('Daily Income Statement',
                      style: AppText.body(size: 11, weight: FontWeight.w500, color: foreground)),
              ],
            ),
          ],
        ),
      ),
    );

    if (enabled) return button;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        button,
        const SizedBox(height: 3),
        Text('ใช้ได้เมื่อตรวจสอบแล้วอย่างน้อย 1 คน', style: AppText.body(size: 11, color: AppColors.textMuted)),
      ],
    );
  }
}
