import '../utils/safe_url.dart';

class Wallpaper {
  const Wallpaper({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
    required this.previewUrl,
    required this.likes,
    required this.resolution,
    required this.fileSize,
    required this.tags,
    this.slug = '',
    this.downloadUrl,
    this.description,
    this.isFeatured = false,
    this.photographerId = '',
    this.width = 0,
    this.height = 0,
    this.orientation = '',
  });

  final String id;
  final String title;
  final String slug;
  final String categoryId;
  final String categoryName;
  final String imageUrl;
  final String previewUrl;
  final String? downloadUrl;
  final String? description;
  final String photographerId;
  final int likes;
  final String resolution;
  final String fileSize;
  final List<String> tags;
  final bool isFeatured;
  final int width;
  final int height;
  final String orientation;

  String get creditName => categoryName;

  String get shareUrl {
    final download = downloadUrl;
    if (download != null && download.isNotEmpty) return download;
    if (previewUrl.isNotEmpty) return previewUrl;
    return imageUrl;
  }

  factory Wallpaper.fromSummary(
    Map<String, dynamic> json, {
    String? categoryId,
    String? categoryName,
  }) {
    final categories = json['categories'];
    var resolvedId = categoryId ?? '';
    var resolvedName = categoryName ?? '';
    if (categories is List && categories.isNotEmpty && categories.first is Map) {
      final first = Map<String, dynamic>.from(categories.first as Map);
      resolvedId = first['id']?.toString() ?? resolvedId;
      resolvedName = first['name']?.toString() ?? resolvedName;
    }
    final width = (json['width'] as num?)?.toInt() ?? 0;
    final height = (json['height'] as num?)?.toInt() ?? 0;
    final thumbnail = httpUrl(json['thumbnailUrl']) ?? '';
    final preview = httpUrl(json['previewUrl']) ?? '';
    final id = json['id']?.toString() ?? '';
    return Wallpaper(
      id: id,
      title: _text(json['title']),
      slug: _text(json['slug']),
      categoryId: resolvedId,
      categoryName: resolvedName,
      imageUrl: thumbnail.isNotEmpty ? thumbnail : preview,
      previewUrl: preview.isNotEmpty ? preview : thumbnail,
      downloadUrl: httpUrl(json['downloadUrl']),
      description: _optional(json['description']),
      photographerId: resolvedId.isEmpty ? id : resolvedId,
      likes: 0,
      resolution: width > 0 && height > 0 ? '$width×$height' : '—',
      fileSize: '—',
      tags: _tags(json['tags']),
      isFeatured: json['isFeatured'] == true,
      width: width,
      height: height,
      orientation: _text(json['orientation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'thumbnailUrl': imageUrl,
      'previewUrl': previewUrl,
      'downloadUrl': downloadUrl,
      'description': description,
      'width': width,
      'height': height,
      'orientation': orientation,
      'isFeatured': isFeatured,
      'tags': tags,
      if (categoryId.isNotEmpty)
        'categories': [
          {'id': categoryId, 'name': categoryName},
        ],
    };
  }

  /// Fills gaps from a newer copy without dropping detail already loaded.
  Wallpaper overlay(Wallpaper next) {
    return Wallpaper(
      id: id,
      title: next.title.isEmpty ? title : next.title,
      slug: next.slug.isEmpty ? slug : next.slug,
      categoryId: next.categoryId.isEmpty ? categoryId : next.categoryId,
      categoryName: next.categoryName.isEmpty ? categoryName : next.categoryName,
      imageUrl: next.imageUrl.isEmpty ? imageUrl : next.imageUrl,
      previewUrl: next.previewUrl.isEmpty ? previewUrl : next.previewUrl,
      downloadUrl: next.downloadUrl ?? downloadUrl,
      description: next.description ?? description,
      photographerId: next.photographerId.isEmpty
          ? photographerId
          : next.photographerId,
      likes: likes,
      resolution: next.resolution == '—' ? resolution : next.resolution,
      fileSize: fileSize,
      tags: next.tags.isEmpty ? tags : next.tags,
      isFeatured: next.isFeatured,
      width: next.width > 0 ? next.width : width,
      height: next.height > 0 ? next.height : height,
      orientation: next.orientation.isEmpty ? orientation : next.orientation,
    );
  }
}

String _text(Object? value) => value?.toString() ?? '';

String? _optional(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty || text == 'null') return null;
  return text;
}

List<String> _tags(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList();
}
