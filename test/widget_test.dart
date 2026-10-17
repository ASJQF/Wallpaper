import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper/main.dart';
import 'package:wallpaper/models/category.dart';
import 'package:wallpaper/models/wallpaper.dart';
import 'package:wallpaper/state/app_controller.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('favorites and likes stay on the device', () {
    final app = AppController(loadOnStart: false);
    final wallpaper = Wallpaper.fromSummary({
      'id': 'ph-1',
      'title': 'جبال',
      'slug': 'mountains',
      'thumbnailUrl': 'https://cdn.example.com/t.webp',
      'previewUrl': 'https://cdn.example.com/p.webp',
      'width': 1080,
      'height': 1920,
      'orientation': 'PORTRAIT',
      'isFeatured': true,
      'tags': ['جبال'],
      'categories': [
        {'id': 'nature', 'name': 'طبيعة'},
      ],
    });
    app.remember(wallpaper);
    try {
      app.toggleFavorite(wallpaper.id);
      expect(app.isFavorite(wallpaper.id), isTrue);
      expect(app.favorites.single.id, wallpaper.id);
      expect(app.likesFor(wallpaper), 0);
      app.toggleLike(wallpaper);
      expect(app.isLiked(wallpaper.id), isTrue);
      expect(app.likesFor(wallpaper), 1);
      app.toggleLike(wallpaper);
      app.toggleFavorite(wallpaper.id);
      expect(app.isLiked(wallpaper.id), isFalse);
      expect(app.isFavorite(wallpaper.id), isFalse);
      expect(app.likesFor(wallpaper), 0);
    } finally {
      app.dispose();
    }
  });

  test('public payloads map onto the existing card model', () {
    final category = Category.fromJson({
      'id': 'c1',
      'name': 'طبيعة',
      'slug': 'nature',
      'thumbnailUrl': null,
      'wallpaperCount': 4,
    });
    final wallpaper = Wallpaper.fromSummary(
      {
        'id': 'w1',
        'title': 'ضباب',
        'slug': 'fog',
        'thumbnailUrl': 'https://cdn.example.com/t.webp',
        'previewUrl': 'https://cdn.example.com/p.webp',
        'width': 1440,
        'height': 3200,
        'isFeatured': false,
        'tags': ['جبال'],
      },
      categoryId: category.id,
      categoryName: category.name,
    );

    expect(category.slug, 'nature');
    expect(wallpaper.creditName, 'طبيعة');
    expect(wallpaper.imageUrl, contains('t.webp'));
    expect(wallpaper.previewUrl, contains('p.webp'));
    expect(wallpaper.resolution, '1440×3200');
    expect(wallpaper.tags, ['جبال']);

    final detailed = wallpaper.overlay(
      Wallpaper.fromSummary({
        'id': 'w1',
        'title': 'ضباب',
        'slug': 'fog',
        'thumbnailUrl': 'https://cdn.example.com/t.webp',
        'previewUrl': 'https://cdn.example.com/p.webp',
        'downloadUrl': 'https://cdn.example.com/original.jpg',
        'description': 'ضباب الصباح',
        'tags': ['جبال', 'هدوء'],
        'width': 1440,
        'height': 3200,
        'categories': [
          {'id': 'c1', 'name': 'طبيعة'},
        ],
      }),
    );
    expect(detailed.downloadUrl, 'https://cdn.example.com/original.jpg');
    expect(detailed.description, 'ضباب الصباح');
    expect(detailed.tags, ['جبال', 'هدوء']);
  });

  testWidgets('splash shows Aura and opens onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const WallpaperApp());
    await tester.pump();
    expect(find.text('Aura'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Discover beauty'), findsOneWidget);
  });
}
