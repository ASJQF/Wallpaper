import '../models/folder.dart';
import '../models/wallpaper.dart';

/// Replace [MockWallpaperRepository] with your API later.
/// Keep these method names so the UI does not need to change.
abstract class WallpaperRepository {
  Future<List<WallpaperFolder>> getFolders();

  Future<List<Wallpaper>> getWallpapers({String? folderId, String? query});

  Future<List<Wallpaper>> getFeatured();
}
