import 'package:url_launcher/url_launcher.dart';

/// Absolute http(s) URL with a host. Used for media returned by the API.
String? httpUrl(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') return null;
  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.isEmpty) return null;
  if (uri.scheme != 'https' && uri.scheme != 'http') return null;
  return uri.toString();
}

/// Public links and banner actions are https-only, matching the backend.
String? httpsUrl(Object? value) {
  final text = httpUrl(value);
  if (text == null) return null;
  return Uri.parse(text).scheme == 'https' ? text : null;
}

String? mailtoUrl(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  if (text.contains(' ') || !text.contains('@')) return null;
  final uri = Uri.tryParse('mailto:$text');
  if (uri == null) return null;
  return uri.toString();
}

Future<bool> openExternalUrl(String raw) async {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null) return false;
  final https = uri.scheme == 'https' && uri.host.isNotEmpty;
  final mail = uri.scheme == 'mailto' && uri.path.isNotEmpty;
  if (!https && !mail) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

String fileExtensionForUrl(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
  if (path.endsWith('.png')) return 'png';
  if (path.endsWith('.webp')) return 'webp';
  if (path.endsWith('.jpeg') || path.endsWith('.jpg')) return 'jpg';
  return 'jpg';
}
