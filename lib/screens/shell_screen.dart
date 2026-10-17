import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_controller.dart';
import 'explore_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppController>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AppController>().refreshIfStale();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.select<AppController, ({int index, int saved})>(
      (controller) =>
          (index: controller.navIndex, saved: controller.favoriteCount),
    );
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: nav.index,
          children: const [HomeScreen(), ExploreScreen(), FavoritesScreen()],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SafeArea(
          top: false,
          child: Material(
            color: scheme.surface,
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            surfaceTintColor: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
              side: BorderSide(color: scheme.outline),
            ),
            child: NavigationBar(
              selectedIndex: nav.index,
              onDestinationSelected: context.read<AppController>().setNav,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: AppLocalizations.of(context).home,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.explore_outlined),
                  selectedIcon: const Icon(Icons.explore_rounded),
                  label: AppLocalizations.of(context).explore,
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: nav.saved > 0,
                    label: Text('${nav.saved}'),
                    child: const Icon(Icons.bookmark_border_rounded),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: nav.saved > 0,
                    label: Text('${nav.saved}'),
                    child: const Icon(Icons.bookmark_rounded),
                  ),
                  label: AppLocalizations.of(context).favorites,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
