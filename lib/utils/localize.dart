import '../l10n/app_localizations.dart';

String userMessage(AppLocalizations l10n, String message) {
  if (message.startsWith('request_failed:')) {
    return l10n.requestFailed(message.substring('request_failed:'.length));
  }
  return switch (message) {
    'offline' => l10n.offline,
    'refresh_failed' => l10n.refreshFailed,
    'min_length' => l10n.searchMin,
    'load_failed' => l10n.loadFailed,
    'timeout' => l10n.timeout,
    'connection_failed' => l10n.connectionFailed,
    'not_found' => l10n.notFound,
    'too_many_requests' => l10n.tooManyRequests,
    'download_failed' => l10n.downloadFailed,
    'invalid_url' => l10n.invalidUrl,
    'empty_file' => l10n.emptyFile,
    'download_timeout' => l10n.downloadTimeout,
    'gallery_permission' => l10n.galleryPermission,
    _ => message,
  };
}

String linkLabel(AppLocalizations l10n, String key) {
  return switch (key) {
    'privacy' => l10n.privacyPolicy,
    'terms' => l10n.termsOfUse,
    'website' => l10n.website,
    'support' => l10n.support,
    'link' => l10n.link,
    _ => key,
  };
}

String creditLabel(AppLocalizations l10n, String name) {
  return name.isEmpty ? l10n.appTitle : name;
}

String languageName(AppLocalizations l10n, String? code) {
  return switch (code) {
    'ar' => 'العربية',
    'tr' => 'Türkçe',
    'en' => 'English',
    _ => l10n.languageSystem,
  };
}
