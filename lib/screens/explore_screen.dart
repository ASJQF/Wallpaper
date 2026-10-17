import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/wallpaper.dart';
import '../state/app_controller.dart';
import '../utils/layout.dart';
import '../utils/localize.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_label.dart';
import '../widgets/wallpaper_grid.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _field = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _field.dispose();
    super.dispose();
  }

  void _apply(String value, {bool remember = false}) {
    setState(() => _query = value);
    _field.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    if (remember) {
      context.read<AppController>().addRecentSearch(value);
    }
    _scheduleSearch(value);
  }

  void _scheduleSearch(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      context.read<AppController>().clearSearch();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<AppController>().search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final recent = context.watch<AppController>().recentSearches;
    final tags = context.select<AppController, List<String>>(
      (controller) => controller.popularTags,
    );
    final popular = context.select<AppController, List<Wallpaper>>(
      (controller) => controller.popular,
    );
    final results = context.select<AppController, List<Wallpaper>>(
      (controller) => controller.searchResults,
    );
    final searching = context.select<AppController, bool>(
      (controller) => controller.isSearching,
    );
    final loadingMore = context.select<AppController, bool>(
      (controller) => controller.isLoadingMoreSearch,
    );
    final searchError = context.select<AppController, String?>(
      (controller) => controller.searchError,
    );
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    final bottom = MediaQuery.paddingOf(context).bottom + 120;
    final query = _query.trim();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (query.length >= 2 &&
            notification.metrics.pixels >
                notification.metrics.maxScrollExtent - 480) {
          context.read<AppController>().loadMoreSearch();
        }
        return false;
      },
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 8, pad, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(l10n.explore),
                  const SizedBox(height: 4),
                  Text(
                    l10n.searchFree,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _field,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      setState(() => _query = value);
                      _scheduleSearch(value);
                    },
                    onSubmitted: (value) => _apply(value, remember: true),
                    decoration: InputDecoration(
                      hintText: l10n.searchPlaceholder,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.clear,
                              onPressed: () => _apply(''),
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (query.isEmpty) ...[
            if (recent.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 4, pad, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.recentSearches,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final term in recent)
                            InputChip(
                              label: Text(term),
                              onPressed: () => _apply(term, remember: true),
                              onDeleted: () {
                                context
                                    .read<AppController>()
                                    .removeRecentSearch(term);
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.popularSearches,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in tags)
                          ActionChip(
                            label: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 13 + (tag.length % 3).toDouble(),
                              ),
                            ),
                            onPressed: () => _apply(tag, remember: true),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 6, pad, 12),
                child: SectionLabel(l10n.popularNow),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(pad, 0, pad, bottom),
              sliver: WallpaperSliverGrid(
                items: popular,
                heroPrefix: 'explore',
              ),
            ),
          ] else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 4, pad, 12),
                child: Text(
                  searching ? l10n.searching : l10n.resultCount(results.length),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            if (searching)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (searchError != null && results.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: l10n.search,
                  message: userMessage(l10n, searchError),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  pad,
                  0,
                  pad,
                  loadingMore ? 12 : bottom,
                ),
                sliver: WallpaperSliverGrid(
                  items: results,
                  heroPrefix: 'explore',
                  emptyTitle: l10n.noResults,
                  emptyMessage: l10n.noResultsHint,
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
        ],
      ),
    );
  }
}
