import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../ads/ad_service.dart';
import '../ads/banner_ad_view.dart';
import '../l10n/app_localizations.dart';
import '../models/wallpaper.dart';
import '../navigation/routes.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_message.dart';
import '../widgets/aura_glass.dart';
import '../widgets/network_art.dart';
import '../widgets/wallpaper_sheets.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.feed,
    required this.initialIndex,
    required this.heroTag,
  });

  final List<Wallpaper> feed;
  final int initialIndex;
  final String heroTag;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final PageController _pages;
  late int _index;
  var _zoomed = false;
  var _showChrome = true;
  final Map<String, List<Wallpaper>> _related = {};
  final Set<String> _loadingRelated = {};

  Wallpaper get _current => widget.feed[_index];

  @override
  void initState() {
    super.initState();
    final last = widget.feed.length - 1;
    _index = widget.initialIndex.clamp(0, last < 0 ? 0 : last);
    _pages = PageController(initialPage: _index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.feed.isEmpty) return;
      context.read<AppController>().openWallpaper(_current);
      _loadRelated(_current);
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _loadRelated(Wallpaper wallpaper) async {
    if (_related.containsKey(wallpaper.id) ||
        !_loadingRelated.add(wallpaper.id)) {
      return;
    }
    if (mounted) setState(() {});
    try {
      final items = await context.read<AppController>().relatedWallpapers(
        wallpaper.id,
      );
      if (!mounted) return;
      setState(() => _related[wallpaper.id] = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _related[wallpaper.id] = const []);
    } finally {
      _loadingRelated.remove(wallpaper.id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wallpaper = _current;
    final related = _related[wallpaper.id];
    final loading = _loadingRelated.contains(wallpaper.id) && related == null;
    final screen = MediaQuery.sizeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CustomScrollView(
          physics: _zoomed
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: screen.height,
                width: screen.width,
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            controller: _pages,
                            itemCount: widget.feed.length,
                            physics: _zoomed
                                ? const NeverScrollableScrollPhysics()
                                : const PageScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() => _index = index);
                              final item = widget.feed[index];
                              context.read<AppController>().openWallpaper(item);
                              _loadRelated(item);
                            },
                            itemBuilder: (context, index) {
                              final item = widget.feed[index];
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    setState(() => _showChrome = !_showChrome),
                                child: _ZoomableImage(
                                  wallpaper: item,
                                  heroTag: index == widget.initialIndex
                                      ? widget.heroTag
                                      : null,
                                  onZoomChanged: (zoomed) {
                                    if (_zoomed == zoomed) return;
                                    setState(() => _zoomed = zoomed);
                                  },
                                ),
                              );
                            },
                          ),
                          if (_showChrome) ...[
                            const IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x66000000),
                                      Color(0x00000000),
                                    ],
                                    stops: [0, 0.22],
                                  ),
                                ),
                              ),
                            ),
                            PositionedDirectional(
                              top: MediaQuery.paddingOf(context).top + 8,
                              start: 12,
                              child: _OverlayButton(
                                icon: Icons.arrow_back_rounded,
                                tooltip: l10n.back,
                                onTap: () => Navigator.of(context).maybePop(),
                              ),
                            ),
                            PositionedDirectional(
                              top: MediaQuery.paddingOf(context).top + 18,
                              end: 16,
                              child: Text(
                                l10n.position(_index + 1, widget.feed.length),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_showChrome)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: AuraGlass(
                              width: double.infinity,
                              height: 76,
                              borderRadius: 26,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Row(
                                  children: [
                                    _FavoriteAction(wallpaperId: wallpaper.id),
                                    const SizedBox(width: 6),
                                    _BarButton(
                                      tooltip: l10n.share,
                                      onTap: () =>
                                          showShareSheet(context, wallpaper),
                                      child: const Icon(
                                        Icons.share_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    _BarButton(
                                      tooltip: l10n.info,
                                      onTap: () => showInfoSheet(
                                        context,
                                        wallpaper,
                                        onOpen: (item) => openWallpaper(
                                          context,
                                          item,
                                          'info-${item.id}',
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.info_outline_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _DownloadButton(
                                        wallpaperId: wallpaper.id,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const BannerAdView(background: Colors.black),
                          SizedBox(
                            height: MediaQuery.paddingOf(context).bottom,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: Text(
                  l10n.relatedWallpapers,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (loading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.loadingRelated,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else if (related == null || related.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Text(
                    l10n.noRelated,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
                sliver: SliverToBoxAdapter(
                  child: _RelatedMasonry(
                    items: related,
                    onOpen: (item) => openWallpaper(
                      context,
                      item,
                      'related-${item.id}',
                      feed: related,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RelatedMasonry extends StatelessWidget {
  const _RelatedMasonry({required this.items, required this.onOpen});

  final List<Wallpaper> items;
  final ValueChanged<Wallpaper> onOpen;

  @override
  Widget build(BuildContext context) {
    final left = <Wallpaper>[];
    final right = <Wallpaper>[];
    for (var i = 0; i < items.length; i++) {
      (i.isEven ? left : right).add(items[i]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(children: [for (final item in left) _tile(item)]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(children: [for (final item in right) _tile(item)]),
        ),
      ],
    );
  }

  Widget _tile(Wallpaper item) {
    final ratio = item.width > 0 && item.height > 0
        ? item.width / item.height
        : 0.72;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AspectRatio(
        aspectRatio: ratio.clamp(0.5, 1.35),
        child: Material(
          color: const Color(0xFF16161F),
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onOpen(item),
            child: NetworkArt(url: item.imageUrl, cacheWidth: 480),
          ),
        ),
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({
    required this.wallpaper,
    required this.onZoomChanged,
    this.heroTag,
  });

  final Wallpaper wallpaper;
  final ValueChanged<bool> onZoomChanged;
  final String? heroTag;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _transform = TransformationController();

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransform);
  }

  @override
  void dispose() {
    _transform.removeListener(_onTransform);
    _transform.dispose();
    super.dispose();
  }

  void _onTransform() {
    widget.onZoomChanged(_transform.value.getMaxScaleOnAxis() > 1.02);
  }

  @override
  Widget build(BuildContext context) {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.02;
    final image = NetworkArt(
      url: widget.wallpaper.previewUrl.isNotEmpty
          ? widget.wallpaper.previewUrl
          : widget.wallpaper.imageUrl,
      fit: BoxFit.contain,
      cacheWidth: 1600,
    );
    return ColoredBox(
      color: Colors.black,
      child: InteractiveViewer(
        transformationController: _transform,
        alignment: Alignment.center,
        panEnabled: zoomed,
        minScale: 1,
        maxScale: 4,
        child: widget.heroTag == null
            ? image
            : Hero(
                tag: widget.heroTag!,
                child: Material(type: MaterialType.transparency, child: image),
              ),
      ),
    );
  }
}

class _FavoriteAction extends StatelessWidget {
  const _FavoriteAction({required this.wallpaperId});

  final String wallpaperId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saved = context.select<AppController, bool>(
      (controller) => controller.isFavorite(wallpaperId),
    );
    return _BarButton(
      tooltip: saved ? l10n.removeFavorite : l10n.save,
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<AppController>().toggleFavorite(wallpaperId);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          key: ValueKey(saved),
          color: saved ? AppColors.neon : Colors.white,
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(width: 42, height: 42, child: Center(child: child)),
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.wallpaperId});

  final String wallpaperId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = context.select<AppController, double?>(
      (controller) => controller.downloadProgressOf(wallpaperId),
    );
    final busy = progress != null;

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: busy
            ? null
            : () async {
                final adClosed = AdService.instance.showForDownload();
                final result = await context.read<AppController>().download(
                  wallpaperId,
                );
                await adClosed;
                if (!context.mounted || result == DownloadResult.busy) return;
                final message = switch (result) {
                  DownloadResult.saved => l10n.downloadSaved,
                  DownloadResult.alreadySaved => l10n.downloadSaved,
                  DownloadResult.disabled => () {
                    final message = context
                        .read<AppController>()
                        .downloadsDisabledMessage;
                    return message.isEmpty ? l10n.downloadsDisabled : message;
                  }(),
                  DownloadResult.permission => l10n.galleryPermission,
                  DownloadResult.failed => l10n.downloadFailed,
                  DownloadResult.busy => '',
                };
                if (message.isEmpty || !context.mounted) return;
                showAppMessage(
                  context,
                  message,
                  bottom: MediaQuery.paddingOf(context).bottom + 200,
                );
              },
        child: Ink(
          height: 48,
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (progress != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: progress.clamp(0.04, 1),
                    heightFactor: 1,
                    child: const ColoredBox(color: Color(0x33FFFFFF)),
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          busy
                              ? Icons.downloading_rounded
                              : Icons.download_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          busy ? '${(progress * 100).round()}%' : l10n.download,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
