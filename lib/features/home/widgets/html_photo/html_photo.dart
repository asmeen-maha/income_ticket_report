/// Shows a photo with a plain HTML `<img>` element (web only).
///
/// Flutter's CanvasKit renderer fetches images itself and needs the photo
/// server to send CORS headers; an `<img>` element does not. This is the
/// fallback for servers that do not send them (Flutter 3.29+ has this built
/// in as `WebHtmlElementStrategy.fallback`).
library;

export 'html_photo_stub.dart' if (dart.library.js_interop) 'html_photo_web.dart';
