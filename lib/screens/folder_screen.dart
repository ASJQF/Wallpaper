import 'package:flutter/material.dart';

import '../models/folder.dart';
import '../models/wallpaper.dart';
import '../state/app_state.dart';
import '../widgets/wallpaper_tile.dart';
import 'wallpaper_detail_screen.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key, required this.folder});

  final WallpaperFolder folder;

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  late final Future<List<Wallpaper>> _items;
  var _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _items = context.app.repository.getWallpapers(folderId: widget.folder.id);
    _ready = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name)),
      body: FutureBuilder<List<Wallpaper>>(
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
    );
  }
}
