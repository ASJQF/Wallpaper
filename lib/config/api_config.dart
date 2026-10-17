/// Public API origin.
///
/// Override at build time:
/// `flutter build apk --release --dart-define=API_BASE_URL=https://72.62.2.1`
///
/// [appVersion] must stay in sync with `version:` in pubspec.yaml (MAJOR.MINOR.PATCH).
class ApiConfig {
  static const defaultBaseUrl = 'https://72.62.2.1';
  static const appVersion = '1.0.0';
  static const publicPrefix = '/api/v1/public';

  static String get baseUrl {
    const defined = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: defaultBaseUrl,
    );
    final trimmed = defined.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty) return defaultBaseUrl;
    return trimmed;
  }

  static Uri uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized').replace(
      queryParameters: query == null || query.isEmpty ? null : query,
    );
  }
}
