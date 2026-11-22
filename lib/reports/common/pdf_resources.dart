import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/theme/app_fonts.dart';

/// Fonts embedded in every report. Loaded once and cached.
class PdfFonts {
  const PdfFonts({
    required this.pgVim,
    required this.trajanPro,
    required this.trajanProBold,
  });

  /// Thai text.
  final pw.Font pgVim;

  /// Latin text and numbers.
  final pw.Font trajanPro;
  final pw.Font trajanProBold;

  static Future<PdfFonts>? _cached;

  static Future<PdfFonts> load() => _cached ??= _load();

  static Future<PdfFonts> _load() async {
    Future<pw.Font> font(String asset) async => pw.Font.ttf(await rootBundle.load(asset));
    return PdfFonts(
      pgVim: await font(AppAssets.pgVimFont),
      trajanPro: await font(AppAssets.trajanProFont),
      trajanProBold: await font(AppAssets.trajanProBoldFont),
    );
  }
}

final _images = <String, Future<pw.MemoryImage>>{};

/// Loads (once) an image asset for embedding in a PDF.
Future<pw.MemoryImage> loadPdfImage(String asset) => _images[asset] ??= rootBundle
    .load(asset)
    .then((data) => pw.MemoryImage(data.buffer.asUint8List()));
