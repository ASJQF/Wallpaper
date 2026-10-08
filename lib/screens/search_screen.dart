import 'package:flutter/material.dart';

import '../models/wallpaper.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/wallpaper_tile.dart';
import 'wallpaper_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Wallpaper> _results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    final items = await context.app.repository.getWallpapers(query: query);
    if (!mounted) return;
    setState(() {
      _results = items;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          onChanged: (value) {
            if (value.trim().isEmpty) {
              setState(() => _results = []);
            }
          },
          decoration: const InputDecoration(
            hintText: 'ابحث عن خلفية...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.muted),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? const Center(
                  child: Text(
                    'اكتب اسم الخلفية ثم اضغط بحث',
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              : WallpaperGrid(
                  items: _results,
                  onOpen: (wallpaper) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WallpaperDetailScreen(wallpaper: wallpaper),
                      ),
                    );
                  },
                ),
    );
  }
}
