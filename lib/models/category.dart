import '../utils/safe_url.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    this.slug = '',
    this.description,
    this.thumbnailUrl,
    this.previewUrl,
    this.wallpaperCount = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? thumbnailUrl;
  final String? previewUrl;
  final int wallpaperCount;

  String? get coverUrl {
    final thumb = thumbnailUrl;
    if (thumb != null && thumb.isNotEmpty) return thumb;
    final preview = previewUrl;
    if (preview != null && preview.isNotEmpty) return preview;
    return null;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: _nullable(json['description']),
      thumbnailUrl: httpUrl(json['thumbnailUrl']),
      previewUrl: httpUrl(json['previewUrl']),
      wallpaperCount: (json['wallpaperCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'previewUrl': previewUrl,
      'wallpaperCount': wallpaperCount,
    };
  }
}

String? _nullable(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty || text == 'null') return null;
  return text;
}
