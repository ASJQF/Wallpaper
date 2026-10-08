import '../models/folder.dart';
import '../models/wallpaper.dart';
import 'wallpaper_repository.dart';

/// Plug your backend here later.
/// Expected JSON shapes:
/// Folders: { id, name, cover_url, wallpaper_count }
/// Wallpapers: { id, folder_id, title, image_url, thumb_url }
class ApiWallpaperRepository implements WallpaperRepository {
  ApiWallpaperRepository({required this.baseUrl});

  final String baseUrl;

  @override
  Future<List<WallpaperFolder>> getFolders() async {
    throw UnimplementedError('Connect GET $baseUrl/folders');
  }

  @override
  Future<List<Wallpaper>> getFeatured() async {
    throw UnimplementedError('Connect GET $baseUrl/wallpapers/featured');
  }

  @override
  Future<List<Wallpaper>> getWallpapers({String? folderId, String? query}) async {
    throw UnimplementedError(
      'Connect GET $baseUrl/wallpapers?folder_id=$folderId&q=$query',
    );
  }
}
