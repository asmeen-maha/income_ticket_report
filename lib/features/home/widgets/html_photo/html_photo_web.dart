import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// A round `<img>` of [size] px. The selection ring and verified badge are
/// drawn in the same HTML element, so Flutter paints nothing on top of it
/// (anything Flutter paints over an HTML element costs an extra canvas).
///
/// Taps pass through to the Flutter row underneath (see [_letTapsThrough]).
/// If the image fails to load the element hides itself, uncovering whatever
/// the caller placed beneath it.
Widget? buildHtmlPhoto({
  required String url,
  required double size,
  Color? ringColor,
  Color? badgeColor,
}) {
  _letTapsThrough();
  return SizedBox.square(
    dimension: size,
    // HtmlElementView is opaque to Flutter's hit testing; without this the
    // row's InkWell underneath would never see the tap.
    child: IgnorePointer(
      child: HtmlElementView.fromTagName(
        // A new element whenever what it shows changes.
        key: ValueKey('$url|$size|$ringColor|$badgeColor'),
        tagName: 'div',
        onElementCreated: (element) {
          final box = element as web.HTMLDivElement..className = _photoClass;
          box.style
            ..width = '100%'
            ..height = '100%'
            ..position = 'relative'
            ..pointerEvents = 'none';

          final img = web.HTMLImageElement()
            ..src = url
            ..alt = ''
            ..decoding = 'async'
            ..draggable = false;
          img.style
            ..width = '100%'
            ..height = '100%'
            ..display = 'block'
            ..boxSizing = 'border-box'
            ..borderRadius = '50%'
            ..objectFit = 'cover'
            ..objectPosition = '50% 30%';
          if (ringColor != null) img.style.border = '2px solid ${_css(ringColor)}';
          img.onerror = ((web.Event _) => box.style.display = 'none').toJS;
          box.append(img);

          if (badgeColor != null) {
            final badgeSize = size * .45;
            final badge = web.HTMLDivElement();
            badge.style
              ..position = 'absolute'
              ..right = '0'
              ..bottom = '0'
              ..width = '${badgeSize}px'
              ..height = '${badgeSize}px'
              ..borderRadius = '50%'
              ..boxSizing = 'border-box'
              ..border = '1.5px solid #FFFDFA'
              ..background = _css(badgeColor)
              ..display = 'flex'
              ..alignItems = 'center'
              ..justifyContent = 'center';
            badge.innerHTML = '<svg width="${badgeSize * .7}" height="${badgeSize * .7}" '
                    'viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3.2" '
                    'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">'
                    '<path d="M5 12.5l4.5 4.5L19 7.5"/></svg>'
                .toJS;
            box.append(badge);
          }
        },
      ),
    ),
  );
}

const _photoClass = 'staff-photo';
var _tapsThroughInstalled = false;

/// Flutter wraps every HTML element in a `<flt-platform-view>` that takes
/// browser pointer events, so a click on the photo would never reach
/// Flutter. One stylesheet rule makes those wrappers transparent.
void _letTapsThrough() {
  if (_tapsThroughInstalled) return;
  _tapsThroughInstalled = true;
  final style = web.HTMLStyleElement()
    ..textContent = 'flt-platform-view:has(> .$_photoClass) { pointer-events: none !important; }';
  web.document.head?.append(style);
}

String _css(Color c) => 'rgba(${c.red}, ${c.green}, ${c.blue}, ${c.opacity})';
