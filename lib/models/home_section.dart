import '../utils/safe_url.dart';
import 'category.dart';
import 'wallpaper.dart';

const homeSectionTypes = {
  'BANNERS',
  'FEATURED_WALLPAPERS',
  'POPULAR_WALLPAPERS',
  'LATEST_WALLPAPERS',
  'CATEGORY_WALLPAPERS',
  'CUSTOM_WALLPAPERS',
  'CATEGORIES',
};

class HomeFeed {
  const HomeFeed(this.sections);

  final List<HomeSection> sections;

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    final raw = json['sections'];
    if (raw is! List) return const HomeFeed([]);
    final sections = <HomeSection>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final section = HomeSection.tryParse(Map<String, dynamic>.from(item));
      if (section != null) sections.add(section);
    }
    return HomeFeed(sections);
  }

  Map<String, dynamic> toJson() {
    return {
      'sections': [for (final section in sections) section.toJson()],
    };
  }
}

class HomeSection {
  const HomeSection({
    required this.id,
    required this.title,
    required this.type,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.wallpapers = const [],
    this.categories = const [],
    this.banners = const [],
  });

  final String id;
  final String title;
  final String type;
  final String? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final List<Wallpaper> wallpapers;
  final List<Category> categories;
  final List<PromoBanner> banners;

  bool get isFeatured => type == 'FEATURED_WALLPAPERS';

  static HomeSection? tryParse(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? '';
    if (!homeSectionTypes.contains(type)) return null;
    final id = json['id']?.toString() ?? '';
    if (id.isEmpty) return null;
    final title = json['title']?.toString() ?? '';
    final category = json['category'];
    String? categoryId;
    String? categoryName;
    String? categorySlug;
    if (category is Map) {
      final map = Map<String, dynamic>.from(category);
      categoryId = map['id']?.toString();
      categoryName = map['name']?.toString();
      categorySlug = map['slug']?.toString();
    }
    final items = json['items'];
    final list = items is List ? items : const [];
    if (type == 'CATEGORIES') {
      final categories = [
        for (final item in list)
          if (item is Map)
            Category.fromJson(Map<String, dynamic>.from(item)),
      ].where((item) => item.id.isNotEmpty && item.name.isNotEmpty).toList();
      if (categories.isEmpty) return null;
      return HomeSection(
        id: id,
        title: title,
        type: type,
        categories: categories,
      );
    }
    if (type == 'BANNERS') {
      final banners = [
        for (final item in list)
          if (item is Map)
            PromoBanner.tryParse(Map<String, dynamic>.from(item)),
      ].whereType<PromoBanner>().toList();
      if (banners.isEmpty) return null;
      return HomeSection(id: id, title: title, type: type, banners: banners);
    }
    final wallpapers = [
      for (final item in list)
        if (item is Map)
          Wallpaper.fromSummary(
            Map<String, dynamic>.from(item),
            categoryId: categoryId,
            categoryName: categoryName,
          ),
    ].where((item) => item.id.isNotEmpty && item.imageUrl.isNotEmpty).toList();
    if (wallpapers.isEmpty) return null;
    return HomeSection(
      id: id,
      title: title,
      type: type,
      categoryId: categoryId,
      categoryName: categoryName,
      categorySlug: categorySlug,
      wallpapers: wallpapers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      if (categoryId != null)
        'category': {
          'id': categoryId,
          'name': categoryName,
          'slug': categorySlug,
        },
      'items': [
        if (type == 'CATEGORIES')
          for (final category in categories) category.toJson()
        else if (type == 'BANNERS')
          for (final banner in banners) banner.toJson()
        else
          for (final wallpaper in wallpapers) wallpaper.toJson(),
      ],
    };
  }
}

class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.subtitle,
    this.thumbnailUrl,
    required this.action,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? thumbnailUrl;
  final BannerAction action;

  static PromoBanner? tryParse(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final image = httpUrl(json['imageUrl']) ?? httpUrl(json['thumbnailUrl']);
    final action = BannerAction.tryParse(json['action']);
    if (id.isEmpty || image == null || action == null) return null;
    return PromoBanner(
      id: id,
      title: json['title']?.toString() ?? '',
      subtitle: _blankToNull(json['subtitle']),
      imageUrl: image,
      thumbnailUrl: httpUrl(json['thumbnailUrl']),
      action: action,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'action': action.toJson(),
    };
  }
}

sealed class BannerAction {
  const BannerAction();

  static BannerAction? tryParse(Object? value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    switch (json['type']?.toString()) {
      case 'NONE':
        return const BannerNone();
      case 'OPEN_WALLPAPER':
        final id = json['wallpaperId']?.toString() ?? '';
        if (id.isEmpty) return null;
        return BannerOpenWallpaper(id);
      case 'OPEN_CATEGORY':
        final id = json['categoryId']?.toString() ?? '';
        final slug = json['categorySlug']?.toString() ?? '';
        if (id.isEmpty || slug.isEmpty) return null;
        return BannerOpenCategory(id, slug);
      case 'OPEN_URL':
        final url = httpsUrl(json['url']);
        if (url == null) return null;
        return BannerOpenUrl(url);
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return switch (this) {
      BannerNone() => {'type': 'NONE'},
      BannerOpenWallpaper(:final wallpaperId) => {
        'type': 'OPEN_WALLPAPER',
        'wallpaperId': wallpaperId,
      },
      BannerOpenCategory(:final categoryId, :final categorySlug) => {
        'type': 'OPEN_CATEGORY',
        'categoryId': categoryId,
        'categorySlug': categorySlug,
      },
      BannerOpenUrl(:final url) => {'type': 'OPEN_URL', 'url': url},
    };
  }
}

class BannerNone extends BannerAction {
  const BannerNone();
}

class BannerOpenWallpaper extends BannerAction {
  const BannerOpenWallpaper(this.wallpaperId);
  final String wallpaperId;
}

class BannerOpenCategory extends BannerAction {
  const BannerOpenCategory(this.categoryId, this.categorySlug);
  final String categoryId;
  final String categorySlug;
}

class BannerOpenUrl extends BannerAction {
  const BannerOpenUrl(this.url);
  final String url;
}

String? _blankToNull(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty || text == 'null') return null;
  return text;
}
