import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/home_section.dart';
import '../navigation/routes.dart';
import '../state/app_controller.dart';
import '../utils/layout.dart';
import '../utils/safe_url.dart';
import 'featured_carousel.dart';
import 'network_art.dart';
import 'section_label.dart';
import 'wallpaper_card.dart';

class HomeSectionsView extends StatelessWidget {
  const HomeSectionsView({super.key, required this.sections});

  final List<HomeSection> sections;

  @override
  Widget build(BuildContext context) {
    final pad = pagePadding(MediaQuery.sizeOf(context).width);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections) ...[
          if (section.title.isNotEmpty && section.type != 'BANNERS')
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 22, pad, 12),
              child: SectionLabel(section.title),
            ),
          if (section.type == 'BANNERS')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _BannerStrip(section: section),
            )
          else if (section.isFeatured)
            FeaturedCarousel(items: section.wallpapers)
          else if (section.type == 'CATEGORIES')
            _CategoryCovers(section: section)
          else
            _WallpaperStrip(section: section),
        ],
      ],
    );
  }
}

class _WallpaperStrip extends StatelessWidget {
  const _WallpaperStrip({required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    final pad = pagePadding(MediaQuery.sizeOf(context).width);
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: pad),
        itemCount: section.wallpapers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final wallpaper = section.wallpapers[index];
          return SizedBox(
            width: 156,
            child: WallpaperCard(
              wallpaper: wallpaper,
              heroTag: 'section-${section.id}-${wallpaper.id}',
              feed: section.wallpapers,
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCovers extends StatelessWidget {
  const _CategoryCovers({required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    final pad = pagePadding(MediaQuery.sizeOf(context).width);
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: pad),
        itemCount: section.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = section.categories[index];
          final cover = category.coverUrl;
          return SizedBox(
            width: 108,
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.read<AppController>().selectCategory(category.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: cover == null
                          ? const ColoredBox(color: Color(0xFF16161F))
                          : NetworkArt(url: cover, cacheWidth: 240),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BannerStrip extends StatefulWidget {
  const _BannerStrip({required this.section});

  final HomeSection section;

  @override
  State<_BannerStrip> createState() => _BannerStripState();
}

class _BannerStripState extends State<_BannerStrip> {
  late final PageController _page = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _open(PromoBanner banner) async {
    final action = banner.action;
    final controller = context.read<AppController>();
    switch (action) {
      case BannerNone():
        return;
      case BannerOpenWallpaper(:final wallpaperId):
        final wallpaper = await controller.resolveWallpaper(wallpaperId);
        if (!mounted || wallpaper == null) return;
        openWallpaper(context, wallpaper, 'banner-${banner.id}');
      case BannerOpenCategory(:final categoryId):
        controller.selectCategory(categoryId);
      case BannerOpenUrl(:final url):
        final opened = await openExternalUrl(url);
        if (!mounted || opened) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).linkFailed)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = (width * 0.42).clamp(160.0, 240.0);
    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _page,
        itemCount: widget.section.banners.length,
        itemBuilder: (context, index) {
          final banner = widget.section.banners[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Material(
              color: const Color(0xFF16161F),
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _open(banner),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkArt(url: banner.imageUrl, cacheWidth: 900),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x22000000), Color(0xE607070C)],
                          stops: [0.4, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (banner.subtitle != null)
                            Text(
                              banner.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
