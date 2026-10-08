import 'package:flutter/material.dart';

import '../models/wallpaper.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/wallpaper_tile.dart';
import 'wallpaper_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final Future<List<Wallpaper>> _all;
  var _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _all = context.app.repository.getWallpapers();
    _ready = true;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text(
            'المفضلة',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Wallpaper>>(
            future: _all,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListenableBuilder(
                listenable: app,
                builder: (context, _) {
                  final liked = snapshot.data!
                      .where((w) => app.isFavorite(w.id))
                      .toList();
                  if (liked.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد خلفيات مفضلة بعد',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    );
                  }
                  return WallpaperGrid(
                    items: liked,
                    onOpen: (wallpaper) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WallpaperDetailScreen(wallpaper: wallpaper),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
