import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/name_utils.dart';

/// Rounded "bento" tile.
class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = AppColors.surface,
    this.bordered = true,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final bool bordered;

  /// Clip children to the rounded corners (tables with header bands).
  final bool clip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        border: bordered ? Border.all(color: AppColors.border) : null,
      ),
      child: child,
    );
  }
}

enum PillButtonStyle { primary, secondary, dark, teal }

/// Fully rounded button, 44 px tall by default.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = PillButtonStyle.secondary,
    this.height = 44,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PillButtonStyle style;
  final double height;

  /// Shows a spinner instead of the icon and ignores taps.
  final bool busy;

  (Color, Color) get _colors => switch (style) {
        PillButtonStyle.primary => (AppColors.primary, AppColors.white),
        PillButtonStyle.secondary => (AppColors.sunken, AppColors.text),
        PillButtonStyle.dark => (AppColors.ink, AppColors.onInk),
        PillButtonStyle.teal => (AppColors.teal, AppColors.white),
      };

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors;
    final enabled = onPressed != null && !busy;

    return SizedBox(
      height: height,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: busy ? background : AppColors.sand,
          disabledForegroundColor: busy ? foreground : AppColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: const StadiumBorder(),
          textStyle: AppText.body(weight: FontWeight.w600),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy)
              SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
              )
            else if (icon != null)
              Icon(icon, size: 18),
            if (busy || icon != null) const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Round icon-only button with a tooltip (used as its accessible label).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      color: AppColors.textSubtle,
      disabledColor: AppColors.disabledIcon,
      style: IconButton.styleFrom(fixedSize: Size.square(size), shape: const CircleBorder()),
    );
  }
}

/// Small rounded label, e.g. a count or a status.
class Pill extends StatelessWidget {
  const Pill(
    this.text, {
    super.key,
    this.background = AppColors.border,
    this.foreground = AppColors.textSubtle,
    this.size = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
  });

  final String text;
  final Color background;
  final Color foreground;
  final double size;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(text, style: AppText.body(size: size, weight: FontWeight.w600, color: foreground)),
    );
  }
}

/// "รอตรวจสอบ" / "ตรวจแล้ว" badge.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    return verified
        ? const Pill('ตรวจแล้ว',
            background: AppColors.tealSoft,
            foreground: AppColors.teal,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5))
        : const Pill('รอตรวจสอบ',
            background: AppColors.primarySoft,
            foreground: AppColors.primaryText,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5));
  }
}

enum AvatarTone { neutral, active, verified }

/// Initials in a circle; verified sellers get a check mark instead.
class SellerAvatar extends StatelessWidget {
  const SellerAvatar({super.key, required this.name, required this.tone, this.size = 34});

  final String name;
  final AvatarTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      AvatarTone.neutral => (AppColors.sunken, AppColors.textSubtle),
      AvatarTone.active => (AppColors.primary, AppColors.white),
      AvatarTone.verified => (AppColors.tealSoft, AppColors.teal),
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: tone == AvatarTone.verified
          ? Icon(Icons.check_rounded, size: size * .5, color: foreground)
          : Text(
              initialsOf(name),
              style: AppText.body(size: size * .38, weight: FontWeight.w600, color: foreground),
            ),
    );
  }
}

/// Small rounded square holding an icon.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.background = AppColors.tealSoft,
    this.foreground = AppColors.teal,
    this.size = 28,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(icon, size: size * .58, color: foreground),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: AppText.caption()),
          ],
        ],
      ),
    );
  }
}

/// Dashed horizontal rule.
class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key, this.color = AppColors.dashed});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const dash = 4.0, gap = 3.0;
      final count = (constraints.maxWidth / (dash + gap)).floor();
      return Row(
        children: List.generate(
          count,
          (_) => Container(
            width: dash,
            height: 1,
            margin: const EdgeInsets.only(right: gap),
            color: color,
          ),
        ),
      );
    });
  }
}
