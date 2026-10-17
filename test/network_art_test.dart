import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallpaper/widgets/network_art.dart';

const _thumbnail =
    'https://72.62.2.1/media/media/2026/10/8ebdae3d-cf7d-4035-bb47-218b8ad78586/thumbnail.webp';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  late Uri? requested;

  setUp(() {
    requested = null;
    debugNetworkImageHttpClientProvider = () =>
        _Client((uri) => requested = uri);
  });

  tearDown(() {
    debugNetworkImageHttpClientProvider = null;
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });

  testWidgets('verified thumbnail URL is requested unchanged', (tester) async {
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 120,
            height: 180,
            child: NetworkArt(url: _thumbnail, cacheWidth: 480),
          ),
        ),
      );
      await tester.pump();

      expect(requested, Uri.parse(_thumbnail));
      final image = tester.widget<Image>(find.byType(Image));
      final provider = image.image;
      final NetworkImage network = provider is ResizeImage
          ? provider.imageProvider as NetworkImage
          : provider as NetworkImage;
      expect(network.url, _thumbnail);
      expect(network.url.contains('/api/'), isFalse);
      expect(
        network.webHtmlElementStrategy,
        kIsWeb ? WebHtmlElementStrategy.prefer : WebHtmlElementStrategy.never,
      );
    } finally {
      debugNetworkImageHttpClientProvider = null;
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('relative and unsafe URLs are not prefixed or fetched', (
    tester,
  ) async {
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 80,
            height: 80,
            child: NetworkArt(url: '/api/v1/media/thumbnail.webp'),
          ),
        ),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(requested, isNull);
    } finally {
      debugNetworkImageHttpClientProvider = null;
    }
  });
}

class _Client extends Fake implements HttpClient {
  _Client(this.onUrl);

  final void Function(Uri url) onUrl;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    onUrl(url);
    return _Request(_png);
  }
}

class _Request extends Fake implements HttpClientRequest {
  _Request(this.bytes);

  final List<int> bytes;

  @override
  Future<HttpClientResponse> close() async => _Response(bytes);
}

class _Response extends Stream<List<int>> implements HttpClientResponse {
  _Response(this.bytes);

  final List<int> bytes;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(bytes).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
