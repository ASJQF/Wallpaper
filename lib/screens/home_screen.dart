import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/home_section.dart';
import '../models/remote_config.dart';
import '../models/wallpaper.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/layout.dart';
import '../utils/localize.dart';
import '../utils/safe_url.dart';
import '../widgets/app_logo.dart';
import '../widgets/category_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_sections.dart';
import '../widgets/section_label.dart';
import '../widgets/shimmer_box.dart';
import '../widgets/wallpaper_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booting = context.select<AppController, bool>(
      (controller) => controller.isBooting,
    );
    final categoryId = context.select<AppController, String?>(
      (controller) => controller.selectedCategoryId,
    );
    final items = context.select<AppController, List<Wallpaper>>(
      (controller) => controller.wallpapers,
    );
    final sections = context.select<AppController, List<HomeSection>>(
      (controller) => controller.homeSections,
    );
    final error = context.select<AppController, String?>(
      (controller) => controller.catalogError,
    );
    final maintenance = context.select<AppController, RemoteAppConfig>(
      (controller) => controller.remoteConfig,
    );
    final stale = context.select<AppController, bool>(
      (controller) => controller.showingCachedCatalog,
    );
    final notices = context.select<AppController, List<Announcement>>(
      (controller) => controller.announcements,
    );
    final loadingMore = context.select<AppController, bool>(
      (controller) => controller.isLoadingMore,
    );
    final categoryName = context.select<AppController, String?>(
      (controller) => controller.categoryById(categoryId)?.name,
    );
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    final bottom = MediaQuery.paddingOf(context).bottom + 120;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >
            notification.metrics.maxScrollExtent - 480) {
          context.read<AppController>().loadMoreWallpapers();
        }
        return false;
      },
      child: RefreshIndicator(
        color: AppColors.violet,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onRefresh: () => context.read<AppController>().refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 16),
                child: const _HomeHeader(),
              ),
            ),
            if (maintenance.maintenanceEnabled)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 0, pad, 12),
                  child: _Notice(
                    title: maintenance.maintenanceTitle.isEmpty
                        ? l10n.maintenance
                        : maintenance.maintenanceTitle,
                    message: maintenance.maintenanceMessage,
                  ),
                ),
              ),
            if (maintenance.updateRequired || maintenance.updateAvailable)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 0, pad, 12),
                  child: _Notice(
                    title: maintenance.updateRequired
                        ? l10n.updateRequired
                        : l10n.updateAvailable,
                    message: maintenance.updateMessage,
                    actionLabel: maintenance.storeUrl == null ? null : l10n.store,
                    onAction: maintenance.storeUrl == null
                        ? null
                        : () => openExternalUrl(maintenance.storeUrl!),
                  ),
                ),
              ),
            for (final notice in notices)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 0, pad, 12),
                  child: _Notice(
                    title: notice.title,
                    message: notice.message,
                    actionLabel: notice.actionUrl == null ? null : l10n.open,
                    onAction: notice.actionUrl == null
                        ? null
                        : () => openExternalUrl(notice.actionUrl!),
                    onDismiss: notice.dismissible
                        ? () => context
                              .read<AppController>()
                              .dismissAnnouncement(notice.id)
                        : null,
                  ),
                ),
              ),
            if (stale && error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 0, pad, 12),
                  child: _Notice(
                    title: l10n.offline,
                    message: userMessage(l10n, error),
                  ),
                ),
              ),
            if (error != null && items.isEmpty && sections.isEmpty && !booting)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: l10n.refreshFailed,
                  message: userMessage(l10n, error),
                  actionLabel: l10n.retry,
                  onAction: () => context.read<AppController>().refresh(),
                ),
              ),
            const SliverToBoxAdapter(child: CategoryBar()),
            if (booting && sections.isEmpty)
              const SliverToBoxAdapter(child: CarouselShimmer()),
            if (!booting && categoryId == null && sections.isNotEmpty)
              SliverToBoxAdapter(child: HomeSectionsView(sections: sections)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 22, pad, 12),
                child: SectionLabel(
                  categoryName ??
                      (sections.isEmpty ? l10n.forYou : l10n.allWallpapers),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                pad,
                0,
                pad,
                loadingMore ? 12 : bottom,
              ),
              sliver: booting
                  ? const WallpaperShimmerGrid()
                  : error != null && items.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : WallpaperSliverGrid(
                      items: items,
                      heroPrefix: 'home',
                      emptyTitle: l10n.emptyWallpapers,
                      emptyMessage: l10n.emptyPublished,
                    ),
            ),
            if (loadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 120),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLogo(size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.brandGradient.createShader(bounds),
                child: Text(
                  AppLocalizations.of(context).appTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
              Text(
                AppLocalizations.of(context).homeSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
        _RoundButton(
          icon: Icons.search_rounded,
          tooltip: AppLocalizations.of(context).search,
          onTap: () => context.read<AppController>().setNav(1),
        ),
        const SizedBox(width: 8),
        _RoundButton(
          icon: Icons.person_rounded,
          tooltip: AppLocalizations.of(context).account,
          onTap: () => context.read<AppController>().setNav(2),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title.isEmpty ? AppLocalizations.of(context).notice : title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    tooltip: AppLocalizations.of(context).dismiss,
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
            if (message.isNotEmpty) Text(message),
            if (actionLabel != null && onAction != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(tooltip: tooltip, onPressed: onTap, icon: Icon(icon)),
    );
  }
}
