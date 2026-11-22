import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

/// Screen-proportional sizes. The layout is designed for a landscape
/// desktop / web window and scales with it.
extension ScreenSize on BuildContext {
  Size get screen => MediaQuery.sizeOf(this);
  double vw(double fraction) => screen.width * fraction;
  double vh(double fraction) => screen.height * fraction;
}

/// Crimson label cell used as a table header.
class HeaderCell extends StatelessWidget {
  const HeaderCell(
    this.text, {
    super.key,
    required this.width,
    this.radius = BorderRadius.zero,
  });

  final String text;
  final double width;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: radius, color: AppColors.crimson),
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.vw(.0085),
          fontFamily: AppFonts.pgVim,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColors.darkPink));
  }
}

class MessageText extends StatelessWidget {
  const MessageText(this.text, {super.key, this.size = .01});

  final String text;

  /// Font size as a fraction of screen width.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: TextStyle(fontSize: context.vw(size), fontFamily: AppFonts.pgVim)),
    );
  }
}
