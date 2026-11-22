{{flutter_js}}
{{flutter_build_config}}

// Internal-network deployment: everything is served from this server.
//  - canvasKitBaseUrl: use the bundled CanvasKit instead of www.gstatic.com.
//  - fontFallbackBaseUrl: missing-glyph fallback fonts would otherwise come
//    from fonts.gstatic.com. The app bundles every font it needs, so this
//    folder is intentionally empty; a miss just 404s locally.
//  - No serviceWorkerSettings: no service worker, so a new deploy is picked
//    up on the next reload instead of serving a cached old version.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
    fontFallbackBaseUrl: "assets/fallback-fonts/",
  },
});
