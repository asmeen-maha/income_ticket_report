import 'package:flutter/material.dart';

/// "Bento / soft-card" palette: warm sand ground, terracotta primary,
/// teal for verified.
abstract final class AppColors {
  // Ground & surfaces
  static const background = Color(0xFFF4EEE6);
  static const surface = Color(0xFFFFFDFA);
  static const sunken = Color(0xFFF4EEE6);
  static const sand = Color(0xFFEFE4D7);
  static const tableHeader = Color(0xFFF8F2EA);
  static const border = Color(0xFFEADFD3);
  static const borderStrong = Color(0xFFE0D3C4);
  static const dashed = Color(0xFFD9C9B7);

  // Text
  static const text = Color(0xFF2A1F17);
  static const textMuted = Color(0xFF6B5A4C);
  static const textSubtle = Color(0xFF5C4B3E);
  static const placeholder = Color(0xFF7A6858);
  static const disabledIcon = Color(0xFFCDBFB0);

  // Primary (terracotta)
  static const primary = Color(0xFFC64A20);
  static const primaryText = Color(0xFFA33A15);
  static const primaryDeep = Color(0xFF7E2C10);
  static const primarySoft = Color(0xFFFBE6DC);
  static const primarySoftBorder = Color(0xFFF1CDBB);
  static const cash = Color(0xFFD0592E);

  // Verified (teal)
  static const teal = Color(0xFF17605C);
  static const tealSoft = Color(0xFFDDEFEC);

  // Dark tile
  static const ink = Color(0xFF2A1F17);
  static const onInk = Color(0xFFFBF5EE);
  static const onInkMuted = Color(0xFFD9CBBB);

  static const white = Colors.white;
  static const shadow = Color(0x1F2A1F17);
}
