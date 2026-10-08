import 'package:flutter/material.dart';

import '../models/wallpaper.dart';
import '../state/app_state.dart';
import '../widgets/wallpaper_tile.dart';
import 'wallpaper_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final Future<List<Wallpaper>> _items;
  var _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _items = context.app.repository.getWallpapers();
    _ready = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text(
            'استكشف',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Wallpaper>>(
            future: _items,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return WallpaperGrid(
                items: snapshot.data!,
                onOpen: (wallpaper) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WallpaperDetailScreen(wallpaper: wallpaper),
                    ),
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
