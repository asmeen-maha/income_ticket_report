/// UI font families registered in pubspec.yaml.
abstract final class AppFonts {
  /// Headings and large numbers.
  static const display = 'Prompt';

  /// Body text.
  static const body = 'NotoSansThai';
}

/// Files under `assets/` loaded at runtime (PDF reports).
abstract final class AppAssets {
  static const pgVimFont = 'assets/fonts/pgvim.ttf';
  static const trajanProFont = 'assets/fonts/trajanpro-regular.ttf';
  static const trajanProBoldFont = 'assets/fonts/trajanpro-bold.ttf';

  static const cashierLogo = 'assets/images/Cashier_size-M.jpg';
  static const ticketingLogo = 'assets/images/Ticketing.jpg';
}
