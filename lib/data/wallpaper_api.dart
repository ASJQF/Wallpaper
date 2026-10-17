import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' as foundation;
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/category.dart';
import '../models/home_section.dart';
import '../models/remote_config.dart';
import '../models/wallpaper.dart';
import 'api_http_client_stub.dart'
    if (dart.library.io) 'api_http_client_io.dart';

class CatalogException implements Exception {
  CatalogException(this.message, {this.statusCode, this.cancelled = false});

  final String message;
  final int? statusCode;
  final bool cancelled;

  @override
  String toString() => message;
}

class PageResult<T> {
  const PageResult({
    required this.items,
    required this.page,
    required this.totalPages,
    this.limit = 20,
    this.total = 0,
    this.seed,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final String? seed;

  bool get hasMore => page < totalPages && items.isNotEmpty;
}

class WallpaperApi {
  WallpaperApi({http.Client? client, String? baseUrl})
    : _client = client ?? createApiClient(),
      _ownsClient = client == null,
      _baseUrl = baseUrl;

  final http.Client _client;
  final bool _ownsClient;
  final String? _baseUrl;
  http.Client? _searchClient;
  String languageCode = 'en';

  static const _headerTimeout = Duration(seconds: 15);
  static const _bodyTimeout = Duration(seconds: 20);

  String get _origin => _baseUrl ?? ApiConfig.baseUrl;

  Future<RemoteAppConfig> appConfig() async {
    final json = await _get('/api/v1/public/app-config', {
      'platform': _clientPlatform,
      'appVersion': ApiConfig.appVersion,
      'lang': languageCode,
    });
    return RemoteAppConfig.fromJson(_dataMap(json), platform: _clientPlatform);
  }

  Future<HomeFeed> home() async {
    final json = await _get('/api/v1/public/home', {'lang': languageCode});
    return HomeFeed.fromJson(_dataMap(json));
  }

  Future<PageResult<Category>> categories({
    int page = 1,
    int limit = 100,
  }) async {
    final json = await _get('/api/v1/public/categories', {
      'page': '$page',
      'limit': '$limit',
      'lang': languageCode,
    });
    return _page(json, Category.fromJson);
  }

  Future<Category> categoryBySlug(String slug) async {
    final json = await _get('/api/v1/public/categories/$slug', {
      'lang': languageCode,
    });
    return Category.fromJson(_dataMap(json));
  }

  Future<PageResult<Wallpaper>> wallpapers({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? categorySlug,
    String sort = 'latest',
    String? query,
    String? seed,
  }) async {
    final json = await _get('/api/v1/public/wallpapers', {
      'page': '$page',
      'limit': '$limit',
      'sort': sort,
      'lang': languageCode,
      if (seed != null && seed.isNotEmpty) 'seed': seed,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (categorySlug != null && categorySlug.isNotEmpty)
        'categorySlug': categorySlug,
      if (query != null && query.isNotEmpty) 'q': query,
    });
    return _page(json, Wallpaper.fromSummary);
  }

  Future<PageResult<Wallpaper>> featured({
    int page = 1,
    int limit = 20,
  }) async {
    final json = await _get('/api/v1/public/wallpapers/featured', {
      'page': '$page',
      'limit': '$limit',
      'lang': languageCode,
    });
    return _page(json, Wallpaper.fromSummary);
  }

  Future<PageResult<Wallpaper>> latest({int page = 1, int limit = 20}) async {
    final json = await _get('/api/v1/public/wallpapers/latest', {
      'page': '$page',
      'limit': '$limit',
      'lang': languageCode,
    });
    return _page(json, Wallpaper.fromSummary);
  }

  Future<PageResult<Wallpaper>> popular({int page = 1, int limit = 20}) async {
    final json = await _get('/api/v1/public/wallpapers/popular', {
      'page': '$page',
      'limit': '$limit',
      'lang': languageCode,
    });
    return _page(json, Wallpaper.fromSummary);
  }

  Future<PageResult<Wallpaper>> search(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final client = _nextSearchClient();
    try {
      final json = await _send(
        'GET',
        '/api/v1/public/wallpapers/search',
        query: {
          'q': query,
          'page': '$page',
          'limit': '$limit',
          'sort': 'latest',
          'lang': languageCode,
        },
        client: client,
      );
      return _page(json, Wallpaper.fromSummary);
    } finally {
      if (_ownsClient && identical(_searchClient, client)) {
        client.close();
        _searchClient = null;
      }
    }
  }

  Future<Wallpaper> wallpaper(String id) async {
    final json = await _get('/api/v1/public/wallpapers/$id', {
      'lang': languageCode,
    });
    return Wallpaper.fromSummary(_dataMap(json));
  }

  Future<PageResult<Wallpaper>> related(
    String id, {
    int page = 1,
    int limit = 20,
  }) async {
    final json = await _get('/api/v1/public/wallpapers/$id/related', {
      'page': '$page',
      'limit': '$limit',
      'lang': languageCode,
    });
    return _page(json, Wallpaper.fromSummary);
  }

  Future<void> track({
    required String wallpaperId,
    required String type,
  }) async {
    if (!_uuid.hasMatch(wallpaperId)) return;
    if (type != 'WALLPAPER_VIEW' &&
        type != 'WALLPAPER_DOWNLOAD_CLICK' &&
        type != 'WALLPAPER_DOWNLOAD') {
      return;
    }
    try {
      await _post('/api/v1/public/events', {
        'events': [
          {
            'wallpaperId': wallpaperId,
            'type': type,
            'platform': _clientPlatform,
            'appVersion': ApiConfig.appVersion,
          },
        ],
      });
    } catch (_) {
      // Analytics must never block browsing or downloads.
    }
  }

  Future<List<int>> downloadBytes(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw CatalogException('invalid_url');
    }
    final request = http.Request('GET', uri);
    final http.StreamedResponse response;
    try {
      response = await _client.send(request).timeout(_headerTimeout);
    } on TimeoutException {
      throw CatalogException('timeout');
    } catch (_) {
      throw CatalogException('download_failed');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CatalogException(
        'download_failed',
        statusCode: response.statusCode,
      );
    }
    final total = response.contentLength ?? 0;
    final bytes = <int>[];
    var received = 0;
    try {
      await for (final chunk in response.stream.timeout(_bodyTimeout)) {
        bytes.addAll(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
    } on TimeoutException {
      throw CatalogException('download_timeout');
    }
    if (bytes.isEmpty) throw CatalogException('empty_file');
    return bytes;
  }

  void close() {
    _searchClient?.close();
    _searchClient = null;
    _client.close();
  }

  http.Client _nextSearchClient() {
    if (!_ownsClient) return _client;
    _searchClient?.close();
    final client = createApiClient();
    _searchClient = client;
    return client;
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? query,
  ]) {
    return _send('GET', path, query: query);
  }

  Future<Map<String, dynamic>> _post(String path, Object body) {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    http.Client? client,
  }) async {
    final attempts = method == 'GET' ? 2 : 1;
    Object? lastError;
    for (var attempt = 0; attempt < attempts; attempt++) {
      try {
        return await _once(method, path, query: query, body: body, client: client);
      } on CatalogException catch (error) {
        lastError = error;
        final retryable =
            error.statusCode == 502 ||
            error.statusCode == 503 ||
            error.statusCode == 504;
        if (!retryable || attempt == attempts - 1) rethrow;
      } on TimeoutException catch (error) {
        lastError = error;
        if (attempt == attempts - 1) {
          throw CatalogException('timeout');
        }
      }
    }
    throw lastError is CatalogException
        ? lastError
        : CatalogException('connection_failed');
  }

  Future<Map<String, dynamic>> _once(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    http.Client? client,
  }) async {
    final uri = Uri.parse('$_origin$path').replace(
      queryParameters: query == null || query.isEmpty ? null : query,
    );
    final request = http.Request(method, uri);
    request.headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final http.StreamedResponse response;
    try {
      response = await (client ?? _client).send(request).timeout(_headerTimeout);
    } on TimeoutException {
      rethrow;
    } on http.ClientException {
      throw CatalogException('cancelled', cancelled: true);
    } catch (_) {
      throw CatalogException('connection_failed');
    }
    final String text;
    try {
      text = await response.stream.bytesToString().timeout(_bodyTimeout);
    } on TimeoutException {
      rethrow;
    }
    Map<String, dynamic>? json;
    if (text.isNotEmpty) {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) json = decoded;
      if (decoded is Map) json = Map<String, dynamic>.from(decoded);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CatalogException(
        _errorMessage(json, response.statusCode),
        statusCode: response.statusCode,
      );
    }
    return json ?? <String, dynamic>{};
  }

  PageResult<T> _page<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) parse,
  ) {
    final raw = json['data'];
    final items = raw is List
        ? raw
              .whereType<Map>()
              .map((item) => parse(Map<String, dynamic>.from(item)))
              .toList()
        : <T>[];
    final meta = _asMap(json['meta']);
    final page = (meta['page'] as num?)?.toInt() ?? 1;
    final totalPages = (meta['totalPages'] as num?)?.toInt() ?? (items.isEmpty ? 0 : 1);
    return PageResult(
      items: items,
      page: page,
      limit: (meta['limit'] as num?)?.toInt() ?? items.length,
      total: (meta['total'] as num?)?.toInt() ?? items.length,
      totalPages: totalPages,
      seed: meta['seed']?.toString(),
    );
  }
}

Map<String, dynamic> _dataMap(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return <String, dynamic>{};
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String _errorMessage(Map<String, dynamic>? json, int statusCode) {
  final details = json?['details'];
  if (details is List && details.isNotEmpty) {
    final text = details.map((item) => item.toString()).join('، ');
    if (text.isNotEmpty) return text;
  }
  final message = json?['message'];
  final textMessage = message is List ? message.join('، ') : message?.toString();
  if (textMessage != null && textMessage.isNotEmpty) return textMessage;
  return switch (statusCode) {
    404 => 'not_found',
    429 => 'too_many_requests',
    _ => 'request_failed:$statusCode',
  };
}

final _uuid = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

String get _clientPlatform {
  if (foundation.kIsWeb) return 'OTHER';
  return switch (foundation.defaultTargetPlatform) {
    foundation.TargetPlatform.iOS => 'IOS',
    foundation.TargetPlatform.android => 'ANDROID',
    _ => 'OTHER',
  };
}
