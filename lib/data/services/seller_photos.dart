import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../core/config/api_config.dart';

/// Staff photos from the HR photo server, `<base><STAFF CODE>.jpg`.
///
/// Two ways to show a photo:
/// 1. Through Flutter ([of]): decoded at [decodeWidth] px and shared in the
///    image cache. Needs the server to send CORS headers on the web.
/// 2. As an HTML `<img>` ([url]) when the browser blocks (1) for lack of
///    CORS headers. After the first such block every later photo goes
///    straight to (2), so no request is wasted.
///
/// A photo that does not exist (HTTP error) is remembered for the session
/// and not requested again; the avatar shows initials instead.
abstract final class SellerPhotos {
  /// Overridable in tests; empty disables photos.
  static String baseUrl = ApiConfig.photoBaseUrl;

  /// Covers the largest avatar (44 px) on a 2× screen.
  static const decodeWidth = 96;

  static final _missing = <String>{};

  /// Flips to true (web only) once the photo server is seen to block
  /// Flutter's requests for lack of `Access-Control-Allow-Origin`. Avatars
  /// listen to it and switch to `<img>`.
  static final htmlMode = ValueNotifier<bool>(false);
  static bool _blockReported = false;

  static String _key(String code) => code.trim().toUpperCase();

  /// Photo URL for [code], or null when photos are off or it is known
  /// to be missing.
  static String? url(String code) {
    final key = _key(code);
    if (baseUrl.isEmpty || key.isEmpty || _missing.contains(key)) return null;
    return '$baseUrl${Uri.encodeComponent(key)}.jpg';
  }

  /// The photo as a Flutter image, or null when there is none to try or the
  /// server is known to block it (then use [url] with an `<img>`).
  static ImageProvider? of(String code) {
    final photoUrl = url(code);
    if (photoUrl == null || useHtmlImage) return null;
    return ResizeImage(NetworkImage(photoUrl), width: decodeWidth);
  }

  static bool get useHtmlImage => kIsWeb && htmlMode.value;

  /// Records why a Flutter image request failed. Called from an image
  /// error builder, i.e. during build, so [htmlMode] is flipped afterwards.
  static void reportFailure(String code, Object error) {
    // An HTTP status means the server answered: the photo is not there.
    if (error is NetworkImageLoadException || !kIsWeb) {
      if (_missing.add(_key(code))) {
        debugPrint('Staff photo ${_key(code)}: not found ($error)');
      }
      return;
    }

    // On the web anything else is the browser's opaque network error
    // ("[object ProgressEvent]"): almost always the missing CORS header.
    if (!_blockReported) {
      _blockReported = true;
      scheduleMicrotask(() => htmlMode.value = true);
      debugPrint(
        'Staff photos: the browser blocked $baseUrl because the server sends no '
        'Access-Control-Allow-Origin header. Showing photos with <img> instead. '
        'Fix on the server: see README "รูปพนักงาน".',
      );
    }
  }

  @visibleForTesting
  static void reset() {
    _missing.clear();
    _blockReported = false;
    htmlMode.value = false;
  }
}
