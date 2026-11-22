import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:income_report/data/services/seller_photos.dart';
import 'package:income_report/features/home/widgets/seller_avatar.dart';

/// Fake photo server: 404 for [_missingCode], a small JPEG otherwise.
const _missingCode = 'F09999';

final _jpeg = File('test/fixtures/sample_photo.jpg').readAsBytesSync();

class _PhotoClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _Req(url);
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Req implements HttpClientRequest {
  _Req(this.url);

  final Uri url;

  @override
  Future<HttpClientResponse> close() async => _Res(found: !url.path.contains(_missingCode));
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _Res extends Stream<List<int>> implements HttpClientResponse {
  _Res({required this.found});

  final bool found;

  List<int> get _body => found ? _jpeg : const [];

  @override
  int get statusCode => found ? 200 : 404;
  @override
  int get contentLength => _body.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      Stream.value(_body)
          .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

class _PhotoOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _PhotoClient();
}

void main() {
  // NetworkImage keeps one HttpClient for the whole run, so install the
  // fake server before the first image loads.
  setUpAll(() => HttpOverrides.global = _PhotoOverrides());
  setUp(() {
    SellerPhotos.reset();
    SellerPhotos.baseUrl = 'http://photos.test/personpic/';
  });

  test('photo URL uses the upper-case staff code', () {
    final provider = SellerPhotos.of(' f00424 ') as ResizeImage;
    expect((provider.imageProvider as NetworkImage).url, 'http://photos.test/personpic/F00424.jpg');
    expect(provider.width, SellerPhotos.decodeWidth);
  });

  test('photos can be disabled', () {
    SellerPhotos.baseUrl = '';
    expect(SellerPhotos.of('F00424'), isNull);
  });

  testWidgets('a photo that fails shows initials and is not requested again', (tester) async {
    Widget avatar() => const MaterialApp(
          home: Center(
            child: SellerAvatar(name: 'สมชาย ตัวอย่าง', code: 'F09999', tone: AvatarTone.neutral),
          ),
        );

    await tester.runAsync(() async {
      await tester.pumpWidget(avatar());
      for (var i = 0; i < 20 && SellerPhotos.of('F09999') != null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
    });
    await tester.pump();

    expect(find.text('สต'), findsOneWidget);
    expect(SellerPhotos.of('F09999'), isNull, reason: 'failure is remembered');
  });

  testWidgets('a photo that loads replaces the initials, decoded small', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(
        home: Center(
          child: SellerAvatar(
              name: 'สมชาย ตัวอย่าง', code: 'F00001', tone: AvatarTone.neutral, size: 44),
        ),
      ));
      for (var i = 0; i < 50 && !_hasImage(tester); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump(const Duration(milliseconds: 50));
      }
    });
    await tester.pump(const Duration(milliseconds: 300));

    final image = tester
        .widgetList<RawImage>(find.byType(RawImage))
        .firstWhere((r) => r.image != null)
        .image!;
    expect(image.width, SellerPhotos.decodeWidth, reason: 'decoded at avatar size, not full size');
    expect(SellerPhotos.of('F00001'), isNotNull, reason: 'not marked as failed');
  });
}

bool _hasImage(WidgetTester tester) =>
    tester.widgetList<RawImage>(find.byType(RawImage)).any((r) => r.image != null);
