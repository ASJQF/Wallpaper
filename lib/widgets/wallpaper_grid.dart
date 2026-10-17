import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/wallpaper.dart';
import '../utils/layout.dart';
import 'empty_state.dart';
import 'wallpaper_card.dart';

class WallpaperSliverGrid extends StatelessWidget {
  const WallpaperSliverGrid({
    super.key,
    required this.items,
    required this.heroPrefix,
    this.emptyTitle,
    this.emptyMessage,
  });

  final List<Wallpaper> items;
  final String heroPrefix;
  final String? emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.image_search_rounded,
          title: emptyTitle ?? l10n.emptyWallpapers,
          message: emptyMessage ?? l10n.emptyHint,
        ),
      );
    }

    final columns = gridColumns(MediaQuery.sizeOf(context).width);
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: columns >= 3 ? 0.72 : 0.66,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = items[index];
        return WallpaperCard(
          wallpaper: item,
          heroTag: '$heroPrefix-${item.id}',
          feed: items,
        );
      }, childCount: items.length),
    );
  }
}
