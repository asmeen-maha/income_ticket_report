import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../core/config/api_config.dart';

/// Staff photos from the HR photo server.
///
/// Performance:
/// - Photos are decoded at [decodeWidth] px (not their full size), and the
///   same provider is used for every avatar size, so one photo = one small
///   entry in Flutter's image cache however often it is shown.
/// - A photo that failed (missing, or blocked by CORS) is remembered for the
///   session and not requested again; the avatar shows initials instead.
abstract final class SellerPhotos {
  /// Overridable in tests; empty disables photos.
  static String baseUrl = ApiConfig.photoBaseUrl;

  /// Covers the largest avatar (44 px) on a 2× screen.
  static const decodeWidth = 96;

  static final _failed = <String>{};

  static String _key(String code) => code.trim().toUpperCase();

  /// The photo for [code], or null when there is none to try.
  static ImageProvider? of(String code) {
    final key = _key(code);
    if (baseUrl.isEmpty || key.isEmpty || _failed.contains(key)) return null;
    return ResizeImage(
      NetworkImage('$baseUrl${Uri.encodeComponent(key)}.jpg'),
      width: decodeWidth,
    );
  }

  /// Logged once per code, so a missing photo or a CORS block can be
  /// diagnosed from the browser console.
  static void markFailed(String code, Object error) {
    if (_failed.add(_key(code))) debugPrint('Staff photo ${_key(code)} not shown: $error');
  }
}
