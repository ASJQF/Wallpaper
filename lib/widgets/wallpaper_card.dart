import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/wallpaper.dart';
import '../navigation/routes.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/localize.dart';
import 'avatar.dart';
import 'network_art.dart';

class WallpaperCard extends StatelessWidget {
  const WallpaperCard({
    super.key,
    required this.wallpaper,
    required this.heroTag,
    this.feed,
  });

  final Wallpaper wallpaper;
  final String heroTag;
  final List<Wallpaper>? feed;

  @override
  Widget build(BuildContext context) {
    final visual = context
        .select<AppController, ({int likes, bool liked, bool saved})>(
          (controller) => (
            likes: controller.likesFor(wallpaper),
            liked: controller.isLiked(wallpaper.id),
            saved: controller.isFavorite(wallpaper.id),
          ),
        );
    final dark = Theme.of(context).brightness == Brightness.dark;
    final credit = creditLabel(
      AppLocalizations.of(context),
      wallpaper.creditName,
    );

    return Material(
      color: const Color(0xFF16161F),
      elevation: dark ? 8 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.45),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: Colors.white.withValues(alpha: dark ? 0.06 : 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openWallpaper(context, wallpaper, heroTag, feed: feed),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: heroTag,
              child: Material(
                type: MaterialType.transparency,
                child: NetworkArt(url: wallpaper.imageUrl, cacheWidth: 480),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x66000000), Color(0x00000000)],
                  stops: [0, 0.28],
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xE607070C)],
                  stops: [0.42, 1],
                ),
              ),
            ),
            PositionedDirectional(
              top: 8,
              start: 8,
              child: _BookmarkButton(
                saved: visual.saved,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<AppController>().toggleFavorite(wallpaper.id);
                },
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Avatar(url: '', name: credit, radius: 11),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          credit,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<AppController>().toggleLike(wallpaper);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            visual.liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 15,
                            color: visual.liked ? AppColors.like : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatCount(
                              visual.likes,
                              Localizations.localeOf(context).languageCode,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.saved, required this.onTap});

  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.38),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              key: ValueKey(saved),
              size: 18,
              color: saved ? AppColors.neon : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
