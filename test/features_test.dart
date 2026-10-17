import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wallpaper/data/key_value_store.dart';
import 'package:wallpaper/data/wallpaper_api.dart';
import 'package:wallpaper/l10n/app_localizations.dart';
import 'package:wallpaper/models/wallpaper.dart';
import 'package:wallpaper/state/app_controller.dart';

void main() {
  test('onboarding is stored once and language survives restart', () async {
    final store = MemoryStore();
    final first = AppController(
      api: _api(),
      store: store,
      loadOnStart: false,
    );
    await first.ensurePreferences(const Locale('ar'));
    expect(first.onboardingCompleted, isFalse);
    expect(first.languageCode, 'ar');

    await first.completeOnboarding();
    expect(await store.read(AppController.onboardingKey), '1');

    final restarted = AppController(
      api: _api(),
      store: store,
      loadOnStart: false,
    );
    await restarted.ensurePreferences(const Locale('fr'));
    expect(restarted.onboardingCompleted, isTrue);
    expect(restarted.languageCode, 'en');

    await restarted.setLanguage('tr');
    final again = AppController(
      api: _api(),
      store: store,
      loadOnStart: false,
    );
    await again.ensurePreferences(const Locale('ar'));
    expect(again.languageCode, 'tr');
    expect(again.onboardingCompleted, isTrue);
    await again.completeOnboarding();
    expect(await store.read(AppController.onboardingKey), '1');
  });

  test('random wallpaper requests keep the same seed across pages', () async {
    final seen = <Uri>[];
    final api = WallpaperApi(
      client: MockClient((request) async {
        seen.add(request.url);
        return http.Response(
          jsonEncode({
            'data': <Object>[],
            'meta': {
              'page': 1,
              'limit': 20,
              'total': 0,
              'totalPages': 0,
              'seed': 'stable-seed',
            },
          }),
          200,
        );
      }),
    );
    api.languageCode = 'ar';
    final first = await api.wallpapers(sort: 'random');
    final second = await api.wallpapers(sort: 'random', seed: first.seed, page: 2);
    expect(first.seed, 'stable-seed');
    expect(seen.first.queryParameters['lang'], 'ar');
    expect(seen.first.queryParameters.containsKey('seed'), isFalse);
    expect(seen.last.queryParameters['seed'], 'stable-seed');
    expect(second.page, 1);
  });

  test('the same wallpaper can be downloaded again with a new filename', () async {
    final names = <String>[];
    final api = WallpaperApi(
      client: MockClient((request) async {
        return http.Response.bytes(Uint8List.fromList([1, 2, 3, 4]), 200);
      }),
    );
    final app = AppController(
      api: api,
      store: MemoryStore(),
      loadOnStart: false,
      gallerySaver: (name, bytes) async {
        names.add(name);
        expect(bytes, isNotEmpty);
      },
    );
    app.remember(
      Wallpaper.fromSummary({
        'id': '11111111-1111-4111-8111-111111111111',
        'title': 'Nature',
        'slug': 'nature',
        'thumbnailUrl': 'https://cdn.example.com/t.webp',
        'previewUrl': 'https://cdn.example.com/p.webp',
        'downloadUrl': 'https://cdn.example.com/full.jpg',
        'width': 1000,
        'height': 1600,
      }),
    );
    expect(
      await app.download('11111111-1111-4111-8111-111111111111'),
      DownloadResult.saved,
    );
    expect(
      await app.download('11111111-1111-4111-8111-111111111111'),
      DownloadResult.saved,
    );
    expect(names, hasLength(2));
    expect(names[0], isNot(names[1]));
    expect(names.every((name) => name.endsWith('.jpg')), isTrue);
  });

  testWidgets('arabic layout is right to left and english is left to right', (
    tester,
  ) async {
    TextDirection? arabic;
    TextDirection? english;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            arabic = Directionality.of(context);
            return Text(AppLocalizations.of(context).relatedWallpapers);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(arabic, TextDirection.rtl);
    expect(find.text('صور مشابهة'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            english = Directionality.of(context);
            return Text(AppLocalizations.of(context).relatedWallpapers);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(english, TextDirection.ltr);
    expect(find.text('Related Wallpapers'), findsOneWidget);
  });
}

WallpaperApi _api() {
  return WallpaperApi(
    client: MockClient((request) async {
      final list = request.url.path.contains('wallpapers') ||
          request.url.path.contains('categories') ||
          request.url.path.contains('home');
      return http.Response(
        jsonEncode({
          'data': list ? <Object>[] : <String, Object>{},
          'meta': {'page': 1, 'limit': 20, 'total': 0, 'totalPages': 0},
        }),
        200,
      );
    }),
  );
}
