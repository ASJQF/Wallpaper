import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/collection.dart';
import '../models/wallpaper.dart';
import '../navigation/routes.dart';
import '../state/app_controller.dart';
import '../utils/localize.dart';
import 'network_art.dart';

class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({super.key, this.items});

  final List<Wallpaper>? items;

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  late final PageController _page;
  Timer? _timer;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _page = PageController(viewportFraction: 0.88);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_page.hasClients) return;
      final count = widget.items?.length ??
          context.read<AppController>().collections.length;
      if (count == 0) return;
      final next = (_index + 1) % count;
      _page.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collections = widget.items == null
        ? context.watch<AppController>().collections
        : [
            for (final wallpaper in widget.items!)
              FeaturedCollection(
                id: wallpaper.id,
                title: wallpaper.title,
                subtitle: wallpaper.creditName,
                badge: 'featured',
                wallpaperId: wallpaper.id,
              ),
          ];
    if (collections.isEmpty) return const SizedBox.shrink();
    final width = MediaQuery.sizeOf(context).width;
    final height = (width * 0.5).clamp(190.0, 280.0);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _page,
            itemCount: collections.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _page,
                builder: (context, child) {
                  var scale = 1.0;
                  if (_page.hasClients && _page.position.haveDimensions) {
                    final page = _page.page ?? _index.toDouble();
                    scale = (1 - (page - index).abs() * 0.06).clamp(0.94, 1.0);
                  }
                  return Transform.scale(scale: scale, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: _CollectionCard(collection: collections[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < collections.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).hintColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection});

  final FeaturedCollection collection;

  @override
  Widget build(BuildContext context) {
    final wallpaper = context.read<AppController>().wallpaperById(
      collection.wallpaperId,
    );
    if (wallpaper == null) return const SizedBox.shrink();

    return Material(
      color: const Color(0xFF16161F),
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            openWallpaper(
              context,
              wallpaper,
              'featured-${collection.id}',
              feed: context.read<AppController>().featured,
            ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'featured-${collection.id}',
              child: Material(
                type: MaterialType.transparency,
                child: NetworkArt(
                  url: wallpaper.previewUrl,
                  cacheWidth: 900,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x22000000), Color(0xE607070C)],
                  stops: [0.35, 1],
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      AppLocalizations.of(context).featured,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    creditLabel(
                      AppLocalizations.of(context),
                      collection.subtitle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
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
