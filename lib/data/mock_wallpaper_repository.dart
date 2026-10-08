import '../models/folder.dart';
import '../models/wallpaper.dart';
import 'wallpaper_repository.dart';

String _img(int id, {int w = 900, int h = 1600}) =>
    'https://picsum.photos/id/$id/$w/$h';

class MockWallpaperRepository implements WallpaperRepository {
  static const _folders = [
    WallpaperFolder(
      id: 'nature',
      name: 'طبيعة',
      coverUrl: 'https://picsum.photos/id/1015/800/1000',
      wallpaperCount: 8,
    ),
    WallpaperFolder(
      id: 'cities',
      name: 'مدن',
      coverUrl: 'https://picsum.photos/id/1016/800/1000',
      wallpaperCount: 6,
    ),
    WallpaperFolder(
      id: 'abstract',
      name: 'تجريد',
      coverUrl: 'https://picsum.photos/id/1025/800/1000',
      wallpaperCount: 6,
    ),
    WallpaperFolder(
      id: 'space',
      name: 'فضاء',
      coverUrl: 'https://picsum.photos/id/1042/800/1000',
      wallpaperCount: 5,
    ),
    WallpaperFolder(
      id: 'dark',
      name: 'داكن',
      coverUrl: 'https://picsum.photos/id/1039/800/1000',
      wallpaperCount: 6,
    ),
    WallpaperFolder(
      id: 'architecture',
      name: 'عمارة',
      coverUrl: 'https://picsum.photos/id/1011/800/1000',
      wallpaperCount: 5,
    ),
  ];

  static final _wallpapers = <Wallpaper>[
    Wallpaper(id: 'n1', folderId: 'nature', title: 'جبل ضبابي', imageUrl: _img(1015), thumbUrl: _img(1015, w: 400, h: 700)),
    Wallpaper(id: 'n2', folderId: 'nature', title: 'غابة', imageUrl: _img(1018), thumbUrl: _img(1018, w: 400, h: 700)),
    Wallpaper(id: 'n3', folderId: 'nature', title: 'شلال', imageUrl: _img(1016), thumbUrl: _img(1016, w: 400, h: 700)),
    Wallpaper(id: 'n4', folderId: 'nature', title: 'بحيرة', imageUrl: _img(1036), thumbUrl: _img(1036, w: 400, h: 700)),
    Wallpaper(id: 'n5', folderId: 'nature', title: 'صحراء', imageUrl: _img(1019), thumbUrl: _img(1019, w: 400, h: 700)),
    Wallpaper(id: 'n6', folderId: 'nature', title: 'أفق', imageUrl: _img(1043), thumbUrl: _img(1043, w: 400, h: 700)),
    Wallpaper(id: 'n7', folderId: 'nature', title: 'صخور', imageUrl: _img(1050), thumbUrl: _img(1050, w: 400, h: 700)),
    Wallpaper(id: 'n8', folderId: 'nature', title: 'غروب', imageUrl: _img(1069), thumbUrl: _img(1069, w: 400, h: 700)),
    Wallpaper(id: 'c1', folderId: 'cities', title: 'ليل المدينة', imageUrl: _img(1015, w: 900, h: 1400), thumbUrl: _img(1015, w: 400, h: 620)),
    Wallpaper(id: 'c2', folderId: 'cities', title: 'شوارع', imageUrl: _img(122), thumbUrl: _img(122, w: 400, h: 700)),
    Wallpaper(id: 'c3', folderId: 'cities', title: 'أبراج', imageUrl: _img(164), thumbUrl: _img(164, w: 400, h: 700)),
    Wallpaper(id: 'c4', folderId: 'cities', title: 'جسر', imageUrl: _img(238), thumbUrl: _img(238, w: 400, h: 700)),
    Wallpaper(id: 'c5', folderId: 'cities', title: 'نيون', imageUrl: _img(250), thumbUrl: _img(250, w: 400, h: 700)),
    Wallpaper(id: 'c6', folderId: 'cities', title: 'مطر', imageUrl: _img(299), thumbUrl: _img(299, w: 400, h: 700)),
    Wallpaper(id: 'a1', folderId: 'abstract', title: 'ألوان', imageUrl: _img(1061), thumbUrl: _img(1061, w: 400, h: 700)),
    Wallpaper(id: 'a2', folderId: 'abstract', title: 'موجات', imageUrl: _img(1062), thumbUrl: _img(1062, w: 400, h: 700)),
    Wallpaper(id: 'a3', folderId: 'abstract', title: 'ملمس', imageUrl: _img(1074), thumbUrl: _img(1074, w: 400, h: 700)),
    Wallpaper(id: 'a4', folderId: 'abstract', title: 'تدرجات', imageUrl: _img(1084), thumbUrl: _img(1084, w: 400, h: 700)),
    Wallpaper(id: 'a5', folderId: 'abstract', title: 'هندسة', imageUrl: _img(110), thumbUrl: _img(110, w: 400, h: 700)),
    Wallpaper(id: 'a6', folderId: 'abstract', title: 'ضوء', imageUrl: _img(119), thumbUrl: _img(119, w: 400, h: 700)),
    Wallpaper(id: 's1', folderId: 'space', title: 'درب التبانة', imageUrl: _img(1042), thumbUrl: _img(1042, w: 400, h: 700)),
    Wallpaper(id: 's2', folderId: 'space', title: 'نجوم', imageUrl: _img(1022), thumbUrl: _img(1022, w: 400, h: 700)),
    Wallpaper(id: 's3', folderId: 'space', title: 'ليل', imageUrl: _img(1012), thumbUrl: _img(1012, w: 400, h: 700)),
    Wallpaper(id: 's4', folderId: 'space', title: 'قمر', imageUrl: _img(1002), thumbUrl: _img(1002, w: 400, h: 700)),
    Wallpaper(id: 's5', folderId: 'space', title: 'سماء', imageUrl: _img(1005), thumbUrl: _img(1005, w: 400, h: 700)),
    Wallpaper(id: 'd1', folderId: 'dark', title: 'ظل', imageUrl: _img(1039), thumbUrl: _img(1039, w: 400, h: 700)),
    Wallpaper(id: 'd2', folderId: 'dark', title: 'أسود', imageUrl: _img(1037), thumbUrl: _img(1037, w: 400, h: 700)),
    Wallpaper(id: 'd3', folderId: 'dark', title: 'ضباب', imageUrl: _img(1035), thumbUrl: _img(1035, w: 400, h: 700)),
    Wallpaper(id: 'd4', folderId: 'dark', title: 'غيم', imageUrl: _img(1033), thumbUrl: _img(1033, w: 400, h: 700)),
    Wallpaper(id: 'd5', folderId: 'dark', title: 'ليل هادئ', imageUrl: _img(1029), thumbUrl: _img(1029, w: 400, h: 700)),
    Wallpaper(id: 'd6', folderId: 'dark', title: 'عمق', imageUrl: _img(1027), thumbUrl: _img(1027, w: 400, h: 700)),
    Wallpaper(id: 'r1', folderId: 'architecture', title: 'واجهات', imageUrl: _img(1011), thumbUrl: _img(1011, w: 400, h: 700)),
    Wallpaper(id: 'r2', folderId: 'architecture', title: 'أقواس', imageUrl: _img(1013), thumbUrl: _img(1013, w: 400, h: 700)),
    Wallpaper(id: 'r3', folderId: 'architecture', title: 'خطوط', imageUrl: _img(1014), thumbUrl: _img(1014, w: 400, h: 700)),
    Wallpaper(id: 'r4', folderId: 'architecture', title: 'مبنى', imageUrl: _img(1020), thumbUrl: _img(1020, w: 400, h: 700)),
    Wallpaper(id: 'r5', folderId: 'architecture', title: 'تفاصيل', imageUrl: _img(1024), thumbUrl: _img(1024, w: 400, h: 700)),
  ];

  Future<T> _delay<T>(T value) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return value;
  }

  @override
  Future<List<WallpaperFolder>> getFolders() => _delay(_folders);

  @override
  Future<List<Wallpaper>> getFeatured() =>
      _delay(_wallpapers.take(10).toList());

  @override
  Future<List<Wallpaper>> getWallpapers({String? folderId, String? query}) {
    var items = _wallpapers.toList();
    if (folderId != null) {
      items = items.where((w) => w.folderId == folderId).toList();
    }
    final q = query?.trim();
    if (q != null && q.isNotEmpty) {
      items = items
          .where((w) => w.title.contains(q) || w.folderId.contains(q))
          .toList();
    }
    return _delay(items);
  }
}
