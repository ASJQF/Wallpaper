import 'package:flutter/material.dart';

import '../models/wallpaper.dart';
import '../screens/detail_screen.dart';

void openWallpaper(
  BuildContext context,
  Wallpaper wallpaper,
  String heroTag, {
  List<Wallpaper>? feed,
}) {
  final items = feed == null || feed.isEmpty
      ? <Wallpaper>[wallpaper]
      : List<Wallpaper>.from(feed);
  var index = items.indexWhere((item) => item.id == wallpaper.id);
  if (index < 0) {
    items.insert(0, wallpaper);
    index = 0;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => DetailScreen(
        feed: items,
        initialIndex: index,
        heroTag: heroTag,
      ),
    ),
  );
}
