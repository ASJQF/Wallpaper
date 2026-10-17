import '../utils/safe_url.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.dismissible,
    this.actionUrl,
  });

  final String id;
  final String title;
  final String message;
  final String level;
  final bool dismissible;
  final String? actionUrl;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      level: json['level']?.toString() ?? 'INFO',
      dismissible: json['dismissible'] != false,
      actionUrl: httpsUrl(json['actionUrl']),
    );
  }
}

class NamedLink {
  const NamedLink({required this.label, required this.url});

  final String label;
  final String url;
}

class RemoteAppConfig {
  const RemoteAppConfig({
    required this.maintenanceEnabled,
    required this.maintenanceTitle,
    required this.maintenanceMessage,
    required this.downloadsEnabled,
    required this.downloadsDisabledMessage,
    required this.allowOriginalDownload,
    required this.updateStatus,
    required this.updateMessage,
    required this.storeUrl,
    required this.announcements,
    required this.links,
    required this.features,
  });

  final bool maintenanceEnabled;
  final String maintenanceTitle;
  final String maintenanceMessage;
  final bool downloadsEnabled;
  final String downloadsDisabledMessage;
  final bool allowOriginalDownload;
  final String updateStatus;
  final String updateMessage;
  final String? storeUrl;
  final List<Announcement> announcements;
  final List<NamedLink> links;
  final Map<String, bool> features;

  bool get updateRequired => updateStatus == 'REQUIRED';
  bool get updateAvailable => updateStatus == 'AVAILABLE';

  static const fallback = RemoteAppConfig(
    maintenanceEnabled: false,
    maintenanceTitle: '',
    maintenanceMessage: '',
    downloadsEnabled: true,
    downloadsDisabledMessage: '',
    allowOriginalDownload: true,
    updateStatus: 'NONE',
    updateMessage: '',
    storeUrl: null,
    announcements: [],
    links: [],
    features: {},
  );

  factory RemoteAppConfig.fromJson(
    Map<String, dynamic> json, {
    required String platform,
  }) {
    final maintenance = _map(json['maintenance']);
    final downloads = _map(json['downloads']);
    final update = _map(json['update']);
    final policyKey = switch (platform) {
      'IOS' => 'ios',
      'ANDROID' => 'android',
      _ => null,
    };
    final policy = policyKey == null ? const <String, dynamic>{} : _map(update[policyKey]);
    final status = switch (update['status']?.toString()) {
      'REQUIRED' => 'REQUIRED',
      'AVAILABLE' => 'AVAILABLE',
      _ => 'NONE',
    };
    final message = switch (status) {
      'REQUIRED' => policy['updateRequiredMessage']?.toString() ?? '',
      'AVAILABLE' => policy['updateAvailableMessage']?.toString() ?? '',
      _ => '',
    };
    final rawAnnouncements = json['announcements'];
    final announcements = rawAnnouncements is List
        ? [
            for (final item in rawAnnouncements)
              if (item is Map)
                Announcement.fromJson(Map<String, dynamic>.from(item)),
          ].where((item) => item.id.isNotEmpty && (item.title.isNotEmpty || item.message.isNotEmpty)).toList()
        : const <Announcement>[];
    return RemoteAppConfig(
      maintenanceEnabled: maintenance['enabled'] == true,
      maintenanceTitle: maintenance['title']?.toString() ?? '',
      maintenanceMessage: maintenance['message']?.toString() ?? '',
      downloadsEnabled: downloads['enabled'] != false,
      downloadsDisabledMessage:
          downloads['disabledMessage']?.toString() ?? '',
      allowOriginalDownload: downloads['allowOriginalDownload'] != false,
      updateStatus: status,
      updateMessage: message,
      storeUrl: httpsUrl(policy['storeUrl']),
      announcements: announcements,
      links: _links(json['links']),
      features: _features(json['features']),
    );
  }
}

List<NamedLink> _links(Object? value) {
  final json = _map(value);
  final links = <NamedLink>[];
  void add(String label, String? url) {
    if (url == null || links.any((item) => item.url == url)) return;
    links.add(NamedLink(label: label, url: url));
  }

  add('privacy', httpsUrl(json['privacyPolicyUrl']));
  add('terms', httpsUrl(json['termsOfServiceUrl']));
  add('website', httpsUrl(json['websiteUrl']));
  add('support', mailtoUrl(json['supportEmail']));
  final other = json['other'];
  if (other is List) {
    for (final item in other) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final label = map['label']?.toString().trim() ?? '';
      add(label.isEmpty ? 'link' : label, httpsUrl(map['url']));
    }
  }
  return links;
}

Map<String, bool> _features(Object? value) {
  if (value is! Map) return const {};
  final flags = <String, bool>{};
  value.forEach((key, flag) {
    if (key is String && flag is bool) flags[key] = flag;
  });
  return flags;
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
