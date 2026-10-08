class Wallpaper {
  const Wallpaper({
    required this.id,
    required this.folderId,
    required this.title,
    required this.imageUrl,
    required this.thumbUrl,
  });

  final String id;
  final String folderId;
  final String title;
  final String imageUrl;
  final String thumbUrl;

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    final image = json['image_url'] as String? ?? json['imageUrl'] as String;
    return Wallpaper(
      id: json['id'].toString(),
      folderId: (json['folder_id'] ?? json['folderId']).toString(),
      title: json['title'] as String? ?? '',
      imageUrl: image,
      thumbUrl: json['thumb_url'] as String? ?? json['thumbUrl'] as String? ?? image,
    );
  }
}
