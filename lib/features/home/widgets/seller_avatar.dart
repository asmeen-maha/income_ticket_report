import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/name_utils.dart';
import '../../../data/services/seller_photos.dart';
import 'html_photo/html_photo.dart';

enum AvatarTone { neutral, active, verified }

/// Staff photo in a circle. Initials show while the photo loads and stay
/// if there is no photo. [AvatarTone.active] adds a terracotta ring,
/// [AvatarTone.verified] a teal check badge.
///
/// See [SellerPhotos] for how the photo is loaded.
class SellerAvatar extends StatelessWidget {
  const SellerAvatar({
    super.key,
    required this.name,
    required this.code,
    required this.tone,
    this.size = 34,
  });

  final String name;

  /// Staff code, e.g. `F00424`; also the photo's file name.
  final String code;
  final AvatarTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SellerPhotos.htmlMode,
      builder: (context, _, __) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final url = SellerPhotos.url(code);
    if (url == null) return _Initials(name: name, tone: tone, size: size);

    // HTML elements sit above Flutter's canvas; while a dialog covers this
    // page they would show through it, so fall back to initials then.
    final canUseHtml = ModalRoute.of(context)?.isCurrent ?? true;
    if (SellerPhotos.useHtmlImage) return _htmlPhoto(url, canUseHtml);

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Image(
              image: SellerPhotos.of(code)!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -.4), // faces sit high in ID photos
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              excludeFromSemantics: true,
              // Initials underneath until the first frame; cached photos
              // arrive synchronously and skip the fade.
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return Stack(fit: StackFit.expand, children: [
                  _Initials(name: name, tone: _initialsTone, size: size),
                  AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: child,
                  ),
                ]);
              },
              // A blocked photo flips SellerPhotos.htmlMode and this avatar
              // rebuilds through _htmlPhoto; a missing one keeps initials.
              errorBuilder: (context, error, stackTrace) {
                SellerPhotos.reportFailure(code, error);
                return _Initials(name: name, tone: tone, size: size);
              },
            ),
          ),
          if (tone == AvatarTone.active)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          if (tone == AvatarTone.verified)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: size * .45,
                height: size * .45,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
                child: Icon(Icons.check_rounded, size: size * .3, color: AppColors.white),
              ),
            ),
        ],
      ),
    );
  }

  /// `<img>` over the initials (which show if the image fails or while a
  /// dialog is open). Ring and badge are drawn by the HTML element.
  Widget _htmlPhoto(String url, bool canUseHtml) {
    final html = canUseHtml
        ? buildHtmlPhoto(
            url: url,
            size: size,
            ringColor: tone == AvatarTone.active ? AppColors.primary : null,
            badgeColor: tone == AvatarTone.verified ? AppColors.teal : null,
          )
        : null;
    final initials = _Initials(name: name, tone: tone, size: size);
    if (html == null) return initials;
    return SizedBox.square(
      dimension: size,
      child: Stack(children: [initials, html]),
    );
  }

  /// While loading a verified seller's photo, show initials, not a check.
  AvatarTone get _initialsTone => tone == AvatarTone.verified ? AvatarTone.neutral : tone;
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.tone, required this.size});

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
