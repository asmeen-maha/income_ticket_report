import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/date_utils.dart';
import 'common.dart';

/// Date picker and the "daily statement" button.
class HomeToolbar extends StatelessWidget {
  const HomeToolbar({
    super.key,
    required this.date,
    required this.onDateChanged,
    required this.onDailyReport,
  });

  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;

  /// Null disables the button.
  final VoidCallback? onDailyReport;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      barrierDismissible: false,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.pink,
            onPrimary: AppColors.white,
            onSurface: AppColors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppColors.darkPink),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.vh(.02), left: context.vw(.01)),
      child: Row(
        children: [
          SizedBox(
            width: context.vw(.15),
            height: context.vh(.05),
            child: _DateField(
              text: AppDateFormat.thaiLong(date),
              onTap: () => _pickDate(context),
            ),
          ),
          SizedBox(width: context.vw(.27)),
          ElevatedButton(
            onPressed: onDailyReport,
            style: ElevatedButton.styleFrom(
              fixedSize: Size(context.vw(.11), context.vh(.05)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(color: AppColors.darkPink, width: 2.5),
              ),
            ),
            child: Text(
              'ใบสรุปส่งเงินรายได้',
              style: TextStyle(
                color: AppColors.darkPink,
                fontFamily: AppFonts.pgVim,
                fontSize: context.vw(.0095),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Keyed by text so the field refreshes when the date changes.
      key: ValueKey(text),
      initialValue: text,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: 'เลือกวันที่',
        labelStyle: TextStyle(
          fontFamily: AppFonts.pgVim,
          fontSize: context.vw(.012),
          color: AppColors.black,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_rounded, color: AppColors.darkPink),
          onPressed: onTap,
        ),
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.darkPink, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
