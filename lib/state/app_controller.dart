import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

import '../data/key_value_store.dart';
import '../data/wallpaper_api.dart';
import '../models/category.dart';
import '../models/collection.dart';
import '../models/home_section.dart';
import '../models/remote_config.dart';
import '../models/wallpaper.dart';
import '../utils/safe_url.dart';

enum DownloadResult { saved, alreadySaved, busy, failed, disabled, permission }

class AppController extends ChangeNotifier {
  AppController({
    WallpaperApi? api,
    KeyValueStore? store,
    bool loadOnStart = true,
    this.gallerySaver,
  }) : _api = api ?? WallpaperApi(),
       _injectedStore = store {
    if (!loadOnStart) _booting = false;
  }

  final WallpaperApi _api;
  final KeyValueStore? _injectedStore;
  final Future<void> Function(String name, Uint8List bytes)? gallerySaver;
  KeyValueStore? _openedStore;
  Future<void> _persistence = Future<void>.value();

  ThemeMode themeMode = ThemeMode.dark;
  int navIndex = 0;
  String? selectedCategoryId;
  var _booting = true;
  var _disposed = false;
  var _loadingMore = false;
  var _loadingMoreSearch = false;
  var _searching = false;
  var _started = false;
  var _page = 1;
  var _hasMore = false;
  var _searchPage = 1;
  var _searchHasMore = false;
  var _searchGen = 0;
  String _searchQuery = '';
  DateTime? _fetchedAt;
  String? _feedSeed;
  Locale? _deviceLocale;

  static const onboardingKey = 'onboarding_completed_v1';
  static const languageKey = 'aura.language';
  static const supportedLanguages = {'ar', 'tr', 'en'};

  String? languageOverride;
  String languageCode = 'en';
  bool onboardingCompleted = false;
  bool preferencesReady = false;

  String? catalogError;
  String? searchError;
  var showingCachedCatalog = false;
  RemoteAppConfig remoteConfig = RemoteAppConfig.fallback;
  List<Category> categories = const [];
  List<HomeSection> homeSections = const [];
  List<Wallpaper> wallpapers = const [];
  List<Wallpaper> featured = const [];
  List<Wallpaper> popular = const [];
  List<Wallpaper> searchResults = const [];
  List<String> popularTags = const [];

  final Map<String, Wallpaper> _known = {};
  final List<String> _favoriteOrder = [];
  final Set<String> _liked = {};
  final Map<String, int> _likeDelta = {};
  final Set<String> _downloaded = {};
  final Set<String> _viewed = {};
  final Set<String> _dismissed = {};
  final Map<String, double> _progress = {};
  final List<String> _recentSearches = [];

  bool get isBooting => _booting;
  bool get isLoadingMore => _loadingMore;
  bool get isLoadingMoreSearch => _loadingMoreSearch;
  bool get isSearching => _searching;
  bool get hasMoreWallpapers => _hasMore;
  bool get searchHasMore => _searchHasMore;
  bool get isDark => themeMode == ThemeMode.dark;
  int get favoriteCount => _favoriteOrder.length;
  int get downloadCount => _downloaded.length;
  int get likeCount => _liked.length;
  bool get downloadsEnabled => remoteConfig.downloadsEnabled;
  String get downloadsDisabledMessage => remoteConfig.downloadsDisabledMessage;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  List<Announcement> get announcements {
    return [
      for (final item in remoteConfig.announcements)
        if (!_dismissed.contains(item.id)) item,
    ];
  }

  @visibleForTesting
  Future<void> get persistenceSettled => _persistence;

  List<FeaturedCollection> get collections {
    return [
      for (final wallpaper in featured)
        FeaturedCollection(
          id: wallpaper.id,
          title: wallpaper.title,
          subtitle: wallpaper.creditName,
          badge: 'featured',
          wallpaperId: wallpaper.id,
        ),
    ];
  }

  bool isFavorite(String id) => _favoriteOrder.contains(id);
  bool isLiked(String id) => _liked.contains(id);
  bool isDownloaded(String id) => _downloaded.contains(id);
  double? downloadProgressOf(String id) => _progress[id];

  int likesFor(Wallpaper wallpaper) {
    return wallpaper.likes + (_likeDelta[wallpaper.id] ?? 0);
  }

  Wallpaper? wallpaperById(String id) => _known[id];

  List<Wallpaper> get favorites {
    return [
      for (final id in _favoriteOrder)
        if (_known[id] != null) _known[id]!,
    ];
  }

  List<Wallpaper> relatedTo(Wallpaper wallpaper, {int limit = 12}) {
    return _known.values
        .where(
          (item) =>
              item.id != wallpaper.id &&
              item.categoryId.isNotEmpty &&
              item.categoryId == wallpaper.categoryId,
        )
        .take(limit)
        .toList();
  }

  Category? categoryById(String? id) {
    if (id == null) return null;
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  void ensureLoaded() {
    if (_started || _disposed) return;
    _started = true;
    unawaited(refresh());
  }

  Future<void> refreshIfStale() async {
    if (_disposed || _booting) return;
    final fetched = _fetchedAt;
    final stale =
        catalogError != null ||
        fetched == null ||
        DateTime.now().difference(fetched) > const Duration(minutes: 2);
    if (stale) await refresh();
  }

  @visibleForTesting
  void remember(Wallpaper wallpaper) => _remember(wallpaper);

  void setNav(int index) {
    if (navIndex == index) return;
    navIndex = index;
    _emit();
  }

  void selectCategory(String? id) {
    if (selectedCategoryId == id) return;
    selectedCategoryId = id;
    _feedSeed = null;
    _emit();
    unawaited(_loadWallpapers(reset: true));
  }

  void applyDeviceLocale(Locale locale) {
    _deviceLocale = locale;
    if (languageOverride != null) return;
    final detected = supportedLanguages.contains(locale.languageCode)
        ? locale.languageCode
        : 'en';
    languageCode = detected;
    _api.languageCode = detected;
  }

  Future<void> ensurePreferences(Locale device) async {
    if (!preferencesReady) await _restoreLocal();
    applyDeviceLocale(device);
    preferencesReady = true;
    _emit();
  }

  Future<void> setLanguage(String? code) async {
    if (code != null && !supportedLanguages.contains(code)) return;
    languageOverride = code;
    final store = await _store();
    await store?.write(languageKey, code);
    if (code == null) {
      applyDeviceLocale(_deviceLocale ?? const Locale('en'));
    } else {
      languageCode = code;
      _api.languageCode = code;
    }
    _emit();
    await refresh();
  }

  Future<void> completeOnboarding() async {
    onboardingCompleted = true;
    final store = await _store();
    await store?.write(onboardingKey, '1');
    _emit();
  }

  Future<List<Wallpaper>> relatedWallpapers(String id) async {
    final page = await _api.related(id);
    final seen = <String>{id};
    final items = <Wallpaper>[];
    for (final item in page.items) {
      if (!seen.add(item.id)) continue;
      items.add(item);
      _remember(item);
    }
    return items;
  }

  void setDarkMode(bool enabled) {
    final next = enabled ? ThemeMode.dark : ThemeMode.light;
    if (next == themeMode) return;
    themeMode = next;
    _emit();
  }

  void toggleFavorite(String id) {
    if (!_favoriteOrder.remove(id)) {
      _favoriteOrder.insert(0, id);
    }
    _emit();
    _persistence = _persistDevice();
  }

  void toggleLike(Wallpaper wallpaper) {
    if (_liked.remove(wallpaper.id)) {
      _likeDelta[wallpaper.id] = (_likeDelta[wallpaper.id] ?? 0) - 1;
    } else {
      _liked.add(wallpaper.id);
      _likeDelta[wallpaper.id] = (_likeDelta[wallpaper.id] ?? 0) + 1;
    }
    _emit();
    _persistence = _persistDevice();
  }

  void dismissAnnouncement(String id) {
    if (!_dismissed.add(id)) return;
    _emit();
    _persistence = _persistDevice();
  }

  Future<void> refresh() async {
    await _restoreLocal();
    final initial =
        categories.isEmpty && wallpapers.isEmpty && homeSections.isEmpty;
    if (initial) {
      _booting = true;
      catalogError = null;
      _emit();
    }
    try {
      _feedSeed = null;
      final results = await Future.wait([
        _api.appConfig(),
        _api.categories(),
        _api.home(),
        _api.popular(),
        selectedCategoryId == null
            ? _api.wallpapers(sort: 'random')
            : _api.wallpapers(
                categoryId: selectedCategoryId,
                sort: 'random',
              ),
      ]);
      remoteConfig = results[0] as RemoteAppConfig;
      categories = (results[1] as PageResult<Category>).items;
      final feed = results[2] as HomeFeed;
      homeSections = feed.sections;
      popular = (results[3] as PageResult<Wallpaper>).items;
      final page = results[4] as PageResult<Wallpaper>;
      _feedSeed = page.seed;
      wallpapers = page.items;
      _page = page.page;
      _hasMore = page.hasMore;
      featured = [
        for (final section in homeSections)
          if (section.isFeatured) ...section.wallpapers,
      ];
      for (final section in homeSections) {
        for (final item in section.wallpapers) {
          _remember(item);
        }
      }
      for (final item in [...popular, ...wallpapers, ...featured]) {
        _remember(item);
      }
      popularTags = _collectTags(popular.isEmpty ? wallpapers : popular);
      catalogError = null;
      showingCachedCatalog = false;
      _fetchedAt = DateTime.now();
      await _hydrateFavorites();
      await _saveSnapshot();
    } on CatalogException catch (error) {
      if (error.cancelled) return;
      await _keepStale(error.message);
    } catch (_) {
      await _keepStale('load_failed');
    } finally {
      _booting = false;
      _emit();
    }
  }

  Future<void> loadMoreWallpapers() async {
    if (_booting || _loadingMore || !_hasMore) return;
    _loadingMore = true;
    _emit();
    try {
      final page = await _api.wallpapers(
        page: _page + 1,
        categoryId: selectedCategoryId,
        sort: 'random',
        seed: _feedSeed,
      );
      final seen = wallpapers.map((item) => item.id).toSet();
      final extra = [
        for (final item in page.items)
          if (seen.add(item.id)) item,
      ];
      wallpapers = [...wallpapers, ...extra];
      for (final item in page.items) {
        _remember(item);
      }
      _page = page.page;
      _hasMore = page.hasMore;
    } on CatalogException catch (error) {
      if (!error.cancelled) catalogError = error.message;
    } finally {
      _loadingMore = false;
      _emit();
    }
  }

  Future<void> search(String raw) async {
    final query = raw.trim();
    final gen = ++_searchGen;
    if (query.length < 2) {
      searchResults = const [];
      searchError = query.isEmpty ? null : 'min_length';
      _searching = false;
      _searchHasMore = false;
      _searchQuery = '';
      _emit();
      return;
    }
    _searching = true;
    searchError = null;
    _searchQuery = query;
    _emit();
    try {
      final page = await _api.search(query);
      if (gen != _searchGen || _disposed) return;
      searchResults = page.items;
      _searchPage = page.page;
      _searchHasMore = page.hasMore;
      for (final item in page.items) {
        _remember(item);
      }
      searchError = null;
    } on CatalogException catch (error) {
      if (error.cancelled || gen != _searchGen || _disposed) return;
      searchResults = const [];
      _searchHasMore = false;
      searchError = error.message;
    } finally {
      if (gen == _searchGen && !_disposed) {
        _searching = false;
        _emit();
      }
    }
  }

  Future<void> loadMoreSearch() async {
    if (_searching || _loadingMoreSearch || !_searchHasMore || _searchQuery.length < 2) {
      return;
    }
    final gen = _searchGen;
    final query = _searchQuery;
    _loadingMoreSearch = true;
    _emit();
    try {
      final page = await _api.search(query, page: _searchPage + 1);
      if (gen != _searchGen || _disposed) return;
      searchResults = [...searchResults, ...page.items];
      _searchPage = page.page;
      _searchHasMore = page.hasMore;
      for (final item in page.items) {
        _remember(item);
      }
    } on CatalogException catch (error) {
      if (!error.cancelled && gen == _searchGen) searchError = error.message;
    } finally {
      _loadingMoreSearch = false;
      if (!_disposed) _emit();
    }
  }

  void clearSearch() {
    _searchGen++;
    searchResults = const [];
    searchError = null;
    _searching = false;
    _searchHasMore = false;
    _searchQuery = '';
    _emit();
  }

  Future<Wallpaper?> resolveWallpaper(String id) async {
    final known = _known[id];
    if (known != null && known.downloadUrl != null) return known;
    try {
      final fetched = await _api.wallpaper(id);
      final merged = (_known[id] ?? fetched).overlay(fetched);
      _known[id] = merged;
      _emit();
      return merged;
    } on CatalogException catch (error) {
      if (error.statusCode == 404) return null;
      return known;
    } catch (_) {
      return known;
    }
  }

  Future<Wallpaper> openWallpaper(Wallpaper wallpaper) async {
    _remember(wallpaper);
    if (_viewed.add(wallpaper.id)) {
      unawaited(_api.track(wallpaperId: wallpaper.id, type: 'WALLPAPER_VIEW'));
    }
    try {
      final fetched = await _api.wallpaper(wallpaper.id);
      final merged = (_known[wallpaper.id] ?? wallpaper).overlay(fetched);
      _known[wallpaper.id] = merged;
      _replaceVisible(merged);
      _emit();
      return merged;
    } catch (_) {
      return _known[wallpaper.id] ?? wallpaper;
    }
  }

  Future<DownloadResult> download(String id) async {
    if (_progress.containsKey(id)) return DownloadResult.busy;
    if (_progress.containsKey(id)) return DownloadResult.busy;
    if (!remoteConfig.downloadsEnabled) return DownloadResult.disabled;

    var wallpaper = _known[id];
    if (wallpaper == null) return DownloadResult.failed;
    if (wallpaper.downloadUrl == null) {
      wallpaper = await openWallpaper(wallpaper);
    }
    final url = wallpaper.downloadUrl;
    if (url == null || url.isEmpty) return DownloadResult.disabled;

    _progress[id] = 0.02;
    _emit();
    unawaited(_api.track(wallpaperId: id, type: 'WALLPAPER_DOWNLOAD_CLICK'));
    try {
      final bytes = await _api.downloadBytes(
        url,
        onProgress: (value) {
          _progress[id] = value.clamp(0.02, 0.96);
          _emit();
        },
      );
      await _saveToGallery(id, bytes, fileExtensionForUrl(url));
      _progress.remove(id);
      _downloaded.add(id);
      _emit();
      _persistence = _persistDevice();
      unawaited(_api.track(wallpaperId: id, type: 'WALLPAPER_DOWNLOAD'));
      return DownloadResult.saved;
    } on CatalogException catch (error) {
      _progress.remove(id);
      _emit();
      if (error.message == 'gallery_permission') {
        return DownloadResult.permission;
      }
      return DownloadResult.failed;
    } catch (_) {
      _progress.remove(id);
      _emit();
      return DownloadResult.failed;
    }
  }

  void addRecentSearch(String query) {
    final value = query.trim();
    if (value.isEmpty) return;
    _recentSearches.remove(value);
    _recentSearches.insert(0, value);
    if (_recentSearches.length > 8) {
      _recentSearches.removeLast();
    }
    _emit();
    _persistence = _persistDevice();
  }

  void removeRecentSearch(String query) {
    if (_recentSearches.remove(query)) {
      _emit();
      _persistence = _persistDevice();
    }
  }

  void clearCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
    _recentSearches.clear();
    _emit();
    _persistence = _clearCachedCatalog();
  }

  Future<void> _loadWallpapers({required bool reset}) async {
    if (reset) {
      _booting = wallpapers.isEmpty;
      _page = 1;
      _feedSeed = null;
      _emit();
    }
    try {
      final page = await _api.wallpapers(
        categoryId: selectedCategoryId,
        sort: 'random',
      );
      _feedSeed = page.seed;
      wallpapers = page.items;
      for (final item in page.items) {
        _remember(item);
      }
      _page = page.page;
      _hasMore = page.hasMore;
      catalogError = null;
      showingCachedCatalog = false;
    } on CatalogException catch (error) {
      if (!error.cancelled) catalogError = error.message;
    } finally {
      _booting = false;
      _emit();
    }
  }

  Future<void> _saveToGallery(String id, List<int> bytes, String extension) async {
    final name = 'aura-$id-${DateTime.now().microsecondsSinceEpoch}.$extension';
    final data = Uint8List.fromList(bytes);
    final custom = gallerySaver;
    if (custom != null) {
      await custom(name, data);
      return;
    }
    final access = await Gal.hasAccess(toAlbum: true);
    if (!access) {
      final granted = await Gal.requestAccess(toAlbum: true);
      if (!granted) {
        throw CatalogException('gallery_permission');
      }
    }
    await Gal.putImageBytes(data, name: name);
  }

  Future<void> _keepStale(String message) async {
    if (wallpapers.isEmpty && homeSections.isEmpty && categories.isEmpty) {
      final restored = await _restoreSnapshot();
      showingCachedCatalog = restored;
      catalogError = restored ? 'offline' : message;
    } else {
      showingCachedCatalog = true;
      catalogError = 'refresh_failed';
    }
  }

  Future<void> _hydrateFavorites() async {
    final fresh = <String>{
      for (final item in [...wallpapers, ...popular, ...featured]) item.id,
      for (final section in homeSections)
        for (final item in section.wallpapers) item.id,
    };
    final missing = _favoriteOrder
        .where((id) => !fresh.contains(id))
        .take(24)
        .toList();
    for (var index = 0; index < missing.length; index += 4) {
      final slice = missing.skip(index).take(4);
      await Future.wait(
        slice.map((id) async {
          try {
            final item = await _api.wallpaper(id);
            _remember(item);
          } on CatalogException catch (error) {
            if (error.statusCode == 404) _favoriteOrder.remove(id);
          } catch (_) {}
        }),
      );
    }
    await _persistDevice();
  }

  Future<KeyValueStore?> _store() async {
    if (_injectedStore != null) return _injectedStore;
    if (_openedStore != null) return _openedStore;
    try {
      _openedStore = await SharedPreferencesStore.open();
      return _openedStore;
    } catch (_) {
      return null;
    }
  }

  Future<void> _restoreLocal() async {
    final store = await _store();
    if (store == null) {
      preferencesReady = true;
      return;
    }
    _favoriteOrder
      ..clear()
      ..addAll(_stringList(await store.read('aura.favorites')));
    _liked
      ..clear()
      ..addAll(_stringList(await store.read('aura.likes')));
    _downloaded
      ..clear()
      ..addAll(_stringList(await store.read('aura.downloaded')));
    _recentSearches
      ..clear()
      ..addAll(_stringList(await store.read('aura.recent')));
    _dismissed
      ..clear()
      ..addAll(_stringList(await store.read('aura.dismissed')));
    onboardingCompleted = await store.read(onboardingKey) == '1';
    final storedLanguage = await store.read(languageKey);
    if (storedLanguage != null && supportedLanguages.contains(storedLanguage)) {
      languageOverride = storedLanguage;
      languageCode = storedLanguage;
      _api.languageCode = storedLanguage;
    }
    preferencesReady = true;
    final rawItems = await store.read('aura.favoriteItems');
    if (rawItems != null && rawItems.isNotEmpty) {
      final decoded = jsonDecode(rawItems);
      if (decoded is Map) {
        decoded.forEach((key, value) {
          if (value is Map) {
            _remember(Wallpaper.fromSummary(Map<String, dynamic>.from(value)));
          }
        });
      }
    }
  }

  Future<void> _persistDevice() async {
    final store = await _store();
    if (store == null) return;
    await store.write('aura.favorites', jsonEncode(_dedupe(_favoriteOrder)));
    await store.write('aura.likes', jsonEncode(_liked.toList()));
    await store.write('aura.downloaded', jsonEncode(_downloaded.toList()));
    await store.write('aura.recent', jsonEncode(_recentSearches));
    await store.write('aura.dismissed', jsonEncode(_dismissed.toList()));
    final items = <String, dynamic>{
      for (final id in _favoriteOrder)
        if (_known[id] != null) id: _known[id]!.toJson(),
    };
    await store.write('aura.favoriteItems', jsonEncode(items));
  }

  Future<void> _saveSnapshot() async {
    final store = await _store();
    if (store == null) return;
    await store.write(
      'aura.catalog',
      jsonEncode({
        'fetchedAt': _fetchedAt?.toIso8601String(),
        'categories': [for (final item in categories) item.toJson()],
        'sections': [for (final item in homeSections) item.toJson()],
        'wallpapers': [for (final item in wallpapers) item.toJson()],
        'popular': [for (final item in popular) item.toJson()],
        'page': _page,
        'totalPages': _hasMore ? _page + 1 : _page,
      }),
    );
    await _persistDevice();
  }

  Future<bool> _restoreSnapshot() async {
    final store = await _store();
    final raw = await store?.read('aura.catalog');
    if (raw == null || raw.isEmpty) return false;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return false;
    final json = Map<String, dynamic>.from(decoded);
    categories = _maps(json['categories']).map(Category.fromJson).toList();
    homeSections = HomeFeed.fromJson({
      'sections': json['sections'],
    }).sections;
    wallpapers = _maps(json['wallpapers']).map(Wallpaper.fromSummary).toList();
    popular = _maps(json['popular']).map(Wallpaper.fromSummary).toList();
    featured = [
      for (final section in homeSections)
        if (section.isFeatured) ...section.wallpapers,
    ];
    for (final item in [...wallpapers, ...popular, ...featured]) {
      _remember(item);
    }
    for (final section in homeSections) {
      for (final item in section.wallpapers) {
        _remember(item);
      }
    }
    _page = (json['page'] as num?)?.toInt() ?? 1;
    final totalPages = (json['totalPages'] as num?)?.toInt() ?? _page;
    _hasMore = _page < totalPages;
    final fetched = DateTime.tryParse(json['fetchedAt']?.toString() ?? '');
    _fetchedAt = fetched;
    return categories.isNotEmpty || wallpapers.isNotEmpty || homeSections.isNotEmpty;
  }

  Future<void> _clearCachedCatalog() async {
    final store = await _store();
    await store?.write('aura.catalog', null);
    await _persistDevice();
  }

  void _remember(Wallpaper wallpaper) {
    if (wallpaper.id.isEmpty) return;
    final previous = _known[wallpaper.id];
    _known[wallpaper.id] = previous == null
        ? wallpaper
        : previous.overlay(wallpaper);
  }

  void _replaceVisible(Wallpaper wallpaper) {
    final current = _known[wallpaper.id];
    if (current == null) return;
    wallpapers = [
      for (final item in wallpapers)
        if (item.id == wallpaper.id) current else item,
    ];
    featured = [
      for (final item in featured)
        if (item.id == wallpaper.id) current else item,
    ];
    popular = [
      for (final item in popular)
        if (item.id == wallpaper.id) current else item,
    ];
    homeSections = [
      for (final section in homeSections)
        HomeSection(
          id: section.id,
          title: section.title,
          type: section.type,
          categoryId: section.categoryId,
          categoryName: section.categoryName,
          categorySlug: section.categorySlug,
          categories: section.categories,
          banners: section.banners,
          wallpapers: [
            for (final item in section.wallpapers)
              if (item.id == wallpaper.id) current else item,
          ],
        ),
    ];
  }

  List<String> _collectTags(List<Wallpaper> source) {
    final tags = <String>[];
    for (final wallpaper in source) {
      for (final tag in wallpaper.tags) {
        if (!tags.contains(tag)) tags.add(tag);
        if (tags.length == 12) return tags;
      }
    }
    return tags;
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchGen++;
    _api.close();
    super.dispose();
  }
}

List<String> _stringList(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const [];
  return _dedupe(decoded.map((item) => item.toString()));
}

List<String> _dedupe(Iterable<String> values) {
  final seen = <String>{};
  final list = <String>[];
  for (final value in values) {
    if (value.isEmpty || !seen.add(value)) continue;
    list.add(value);
  }
  return list;
}

List<Map<String, dynamic>> _maps(Object? value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map) Map<String, dynamic>.from(item),
  ];
}
