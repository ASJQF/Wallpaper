class WallpaperFolder {
  const WallpaperFolder({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.wallpaperCount,
  });

  final String id;
  final String name;
  final String coverUrl;
  final int wallpaperCount;

  factory WallpaperFolder.fromJson(Map<String, dynamic> json) {
    return WallpaperFolder(
      id: json['id'].toString(),
      name: json['name'] as String,
      coverUrl: json['cover_url'] as String? ?? json['coverUrl'] as String,
      wallpaperCount: json['wallpaper_count'] as int? ??
          json['wallpaperCount'] as int? ??
          0,
    );
  }
}
