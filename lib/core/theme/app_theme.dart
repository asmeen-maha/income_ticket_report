import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

abstract final class AppRadius {
  static const tile = 22.0;
  static const row = 16.0;
  static const inner = 14.0;
  static const pill = 999.0;
}

/// Text styles used across the app. Numbers use tabular figures so columns
/// of money line up.
abstract final class AppText {
  static const _tabular = [FontFeature.tabularFigures()];

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
  }) =>
      TextStyle(
        fontFamily: AppFonts.body,
        fontFamilyFallback: const [AppFonts.display],
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.35,
        fontFeatures: _tabular,
      );

  static TextStyle display({
    double size = 17,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.text,
  }) =>
      TextStyle(
        fontFamily: AppFonts.display,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.15,
        letterSpacing: size >= 28 ? -.3 : 0,
        fontFeatures: _tabular,
      );

  /// Small muted label, e.g. a tile heading.
  static TextStyle label({Color color = AppColors.textMuted, FontWeight weight = FontWeight.w500}) =>
      body(size: 13, weight: weight, color: color);

  static TextStyle caption({Color color = AppColors.textMuted, FontWeight weight = FontWeight.w400}) =>
      body(size: 12, weight: weight, color: color);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.teal,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    error: AppColors.primaryText,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: AppFonts.body,
    fontFamilyFallback: const [AppFonts.display],
    dividerColor: AppColors.border,
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.primary),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: const BorderSide(color: AppColors.textMuted, width: 1.5),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.surface,
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.tile)),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: AppText.body(color: AppColors.onInk),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.inner)),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: AppText.caption(color: AppColors.onInk),
    ),
  );
}
