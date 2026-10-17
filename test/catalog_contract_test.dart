import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wallpaper/data/key_value_store.dart';
import 'package:wallpaper/data/wallpaper_api.dart';
import 'package:wallpaper/models/category.dart';
import 'package:wallpaper/models/home_section.dart';
import 'package:wallpaper/models/remote_config.dart';
import 'package:wallpaper/models/wallpaper.dart';
import 'package:wallpaper/state/app_controller.dart';

const _wallpaperId = '01928c1e-0000-7000-8000-00000000a001';

http.Response _json(Object? body, int status) {
  return http.Response(
    body is String ? body : jsonEncode(body),
    status,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}

Map<String, dynamic> _summary({String id = _wallpaperId, String title = 'جبال'}) {
  return {
    'id': id,
    'title': title,
    'slug': 'mountains',
    'thumbnailUrl': 'https://cdn.example.com/t.webp',
    'previewUrl': 'https://cdn.example.com/p.webp',
    'width': 1440,
    'height': 3200,
    'orientation': 'PORTRAIT',
    'isFeatured': true,
    'extraIgnored': true,
    'tags': ['جبال'],
    'categories': [
      {'id': 'c1', 'name': 'طبيعة', 'slug': 'nature'},
    ],
  };
}

void main() {
  test('wallpaper and category parsers keep media URLs and ignore unknown fields', () {
    final category = Category.fromJson({
      'id': 'c1',
      'name': 'طبيعة',
      'slug': 'nature',
      'description': 'غابات',
      'thumbnailUrl': 'https://cdn.example.com/cover.webp',
      'previewUrl': 'javascript:alert(1)',
      'wallpaperCount': 4,
      'isPublished': true,
    });
    final wallpaper = Wallpaper.fromSummary({
      ..._summary(),
      'downloadUrl': 'https://cdn.example.com/original.jpg',
      'description': 'ضباب',
    });
    final rejected = Wallpaper.fromSummary({
      ..._summary(id: 'bad'),
      'thumbnailUrl': 'file:///tmp/secret.jpg',
      'previewUrl': 'not a url',
      'downloadUrl': 'data:image/png;base64,aaaa',
    });

    expect(category.coverUrl, 'https://cdn.example.com/cover.webp');
    expect(category.previewUrl, isNull);
    expect(wallpaper.imageUrl, contains('t.webp'));
    expect(wallpaper.previewUrl, contains('p.webp'));
    expect(wallpaper.downloadUrl, endsWith('original.jpg'));
    expect(wallpaper.resolution, '1440×3200');
    expect(rejected.imageUrl, isEmpty);
    expect(rejected.downloadUrl, isNull);
  });

  test('home feed drops unknown sections and empty content', () {
    final feed = HomeFeed.fromJson({
      'sections': [
        {
          'id': 's-featured',
          'title': 'مميز',
          'type': 'FEATURED_WALLPAPERS',
          'items': [_summary()],
        },
        {
          'id': 's-unknown',
          'title': 'غريب',
          'type': 'SOMETHING_NEW',
          'items': [_summary()],
        },
        {
          'id': 's-empty',
          'title': 'فارغ',
          'type': 'LATEST_WALLPAPERS',
          'items': [],
        },
        {
          'id': 's-banner',
          'title': 'بانر',
          'type': 'BANNERS',
          'items': [
            {
              'id': 'b1',
              'title': 'عرض',
              'subtitle': null,
              'imageUrl': 'https://cdn.example.com/banner.webp',
              'thumbnailUrl': 'https://cdn.example.com/banner-thumb.webp',
              'action': {
                'type': 'OPEN_CATEGORY',
                'categoryId': 'c1',
                'categorySlug': 'nature',
              },
            },
            {
              'id': 'b2',
              'title': 'غير آمن',
              'imageUrl': 'https://cdn.example.com/x.webp',
              'action': {'type': 'OPEN_URL', 'url': 'http://insecure.example'},
            },
          ],
        },
      ],
    });

    expect(feed.sections.map((section) => section.type), [
      'FEATURED_WALLPAPERS',
      'BANNERS',
    ]);
    expect(feed.sections.last.banners, hasLength(1));
    expect(feed.sections.last.banners.single.action, isA<BannerOpenCategory>());
  });

  test('app config reads maintenance, update status, announcements and links', () {
    final config = RemoteAppConfig.fromJson({
      'maintenance': {'enabled': true, 'title': 'صيانة', 'message': 'نعود قريباً'},
      'update': {
        'android': {
          'minSupportedVersion': '1.0.0',
          'latestVersion': '1.2.0',
          'updateRequiredMessage': 'حدّث التطبيق',
          'updateAvailableMessage': 'يتوفر إصدار',
          'storeUrl': 'https://play.example/app',
        },
        'status': 'AVAILABLE',
      },
      'announcements': [
        {
          'id': 'summer',
          'title': 'جديد',
          'message': 'خلفيات',
          'level': 'PROMO',
          'actionUrl': 'https://example.com/promo',
          'dismissible': true,
        },
      ],
      'downloads': {
        'enabled': false,
        'allowOriginalDownload': false,
        'disabledMessage': 'متوقف',
      },
      'links': {
        'privacyPolicyUrl': 'https://example.com/privacy',
        'supportEmail': 'help@example.com',
        'other': [
          {'key': 'blog', 'label': 'المدونة', 'url': 'https://example.com/blog'},
        ],
      },
      'features': {'experimentalGrid': true, 'note': 'ignore'},
      'serverTime': '2026-01-01T00:00:00.000Z',
    }, platform: 'ANDROID');

    expect(config.maintenanceEnabled, isTrue);
    expect(config.updateAvailable, isTrue);
    expect(config.updateMessage, 'يتوفر إصدار');
    expect(config.storeUrl, 'https://play.example/app');
    expect(config.downloadsEnabled, isFalse);
    expect(config.announcements.single.actionUrl, contains('promo'));
    expect(config.links.map((link) => link.label), containsAll(['privacy', 'support', 'المدونة']));
    expect(config.features, {'experimentalGrid': true});
  });

  test('pagination reports another page only when the server says so', () {
    const more = PageResult<int>(items: [1], page: 1, totalPages: 3, total: 40, limit: 20);
    const done = PageResult<int>(items: [1], page: 3, totalPages: 3, total: 41, limit: 20);
    const empty = PageResult<int>(items: [], page: 1, totalPages: 0, total: 0, limit: 20);
    expect(more.hasMore, isTrue);
    expect(done.hasMore, isFalse);
    expect(empty.hasMore, isFalse);
  });

  test('api client unwraps data, retries 503, and surfaces error messages', () async {
    var homeCalls = 0;
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/home')) {
        homeCalls++;
        if (homeCalls == 1) {
          return _json({'message': 'unavailable'}, 503);
        }
        return _json({
            'data': {
              'sections': [
                {
                  'id': 's1',
                  'title': 'الأحدث',
                  'type': 'LATEST_WALLPAPERS',
                  'items': [_summary()],
                },
              ],
            },
          },
          200,
        );
      }
      if (path.endsWith('/wallpapers') && request.url.queryParameters['page'] == '2') {
        return _json({
            'data': [_summary(id: '01928c1e-0000-7000-8000-00000000a002', title: 'بحر')],
            'meta': {'page': 2, 'limit': 20, 'total': 21, 'totalPages': 2},
          },
          200,
        );
      }
      if (path.endsWith('/missing')) {
        return _json({
          'statusCode': 400,
          'message': 'Validation failed',
          'details': ['q must be longer than or equal to 2 characters'],
        }, 400);
      }
      return _json({'data': {}}, 200);
    });
    final api = WallpaperApi(client: client, baseUrl: 'https://72.62.2.1');
    try {
      final home = await api.home();
      expect(homeCalls, 2);
      expect(home.sections.single.title, 'الأحدث');
      expect(home.sections.single.wallpapers.single.imageUrl, contains('t.webp'));

      final page = await api.wallpapers(page: 2);
      expect(page.page, 2);
      expect(page.hasMore, isFalse);
      expect(page.items.single.title, 'بحر');

      expect(
        () => api.wallpaper('missing'),
        throwsA(
          isA<CatalogException>().having(
            (error) => error.message,
            'message',
            contains('q must be longer'),
          ),
        ),
      );
    } finally {
      api.close();
    }
  });

  test('favorites survive restart and drop unpublished wallpapers', () async {
    final store = MemoryStore();
    final saved = Wallpaper.fromSummary(_summary());
    final first = AppController(
      api: WallpaperApi(client: MockClient((_) async => _json({'message': 'down'}, 500)), baseUrl: 'https://72.62.2.1'),
      store: store,
      loadOnStart: false,
    );
    first.remember(saved);
    first.toggleFavorite(saved.id);
    await first.persistenceSettled;
    first.dispose();

    final offline = AppController(
      api: WallpaperApi(
        client: MockClient((_) async => _json({'message': 'down'}, 500)),
        baseUrl: 'https://72.62.2.1',
      ),
      store: store,
      loadOnStart: false,
    );
    await offline.refresh();
    expect(offline.isFavorite(saved.id), isTrue);
    expect(offline.favorites.single.title, 'جبال');
    expect(offline.showingCachedCatalog, isFalse);
    offline.dispose();

    final online = AppController(
      api: WallpaperApi(client: _catalogClient(missingDetail: true), baseUrl: 'https://72.62.2.1'),
      store: store,
      loadOnStart: false,
    );
    await online.refresh();
    expect(online.isFavorite(saved.id), isFalse);
    expect(online.homeSections.single.type, 'LATEST_WALLPAPERS');
    online.dispose();
  });
}

MockClient _catalogClient({required bool missingDetail}) {
  return MockClient((request) async {
    final path = request.url.path;
    if (path.endsWith('/app-config')) {
      return _json({
        'data': {
          'maintenance': {'enabled': false, 'title': '', 'message': ''},
          'downloads': {'enabled': true, 'disabledMessage': 'متوقف'},
          'update': {'status': 'NONE', 'android': {}},
          'announcements': [],
          'links': {},
          'features': {},
        },
      }, 200);
    }
    if (path.endsWith('/categories')) {
      return _json({
        'data': [
          {
            'id': 'c1',
            'name': 'طبيعة',
            'slug': 'nature',
            'thumbnailUrl': 'https://cdn.example.com/cover.webp',
            'wallpaperCount': 1,
          },
        ],
        'meta': {'page': 1, 'limit': 100, 'total': 1, 'totalPages': 1},
      }, 200);
    }
    if (path.endsWith('/home')) {
      return _json({
        'data': {
          'sections': [
            {
              'id': 's1',
              'title': 'الأحدث',
              'type': 'LATEST_WALLPAPERS',
              'items': [_summary(id: '01928c1e-0000-7000-8000-00000000a009', title: 'أخرى')],
            },
          ],
        },
      }, 200);
    }
    if (path.endsWith('/popular') || path.endsWith('/latest')) {
      return _json({
        'data': [],
        'meta': {'page': 1, 'limit': 20, 'total': 0, 'totalPages': 0},
      }, 200);
    }
    if (missingDetail && path.endsWith('/wallpapers/$_wallpaperId')) {
      return _json({'message': 'Wallpaper not found'}, 404);
    }
    return _json({'data': {}}, 200);
  });
}
