import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../screens/onboarding_screen.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/layout.dart';
import '../utils/localize.dart';
import '../utils/safe_url.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_label.dart';
import '../widgets/wallpaper_grid.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final l10n = AppLocalizations.of(context);
    final saved = app.favorites;
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    final bottom = MediaQuery.paddingOf(context).bottom + 120;
    final scheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.brandGradient,
                      ),
                      child: Text(
                        l10n.guestName.isEmpty ? '?' : l10n.guestName.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.guestName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            l10n.guestSubtitle,
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Stat(value: '${saved.length}', label: l10n.savedStat),
                    const SizedBox(width: 8),
                    _Stat(value: '${app.downloadCount}', label: l10n.downloadsStat),
                    const SizedBox(width: 8),
                    _Stat(value: '${app.likeCount}', label: l10n.likesStat),
                  ],
                ),
                const SizedBox(height: 22),
                SectionLabel(l10n.settings),
                const SizedBox(height: 10),
                Material(
                  color: scheme.surface,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(color: scheme.outline),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        secondary: const Icon(Icons.dark_mode_rounded),
                        title: Text(AppLocalizations.of(context).darkMode),
                        subtitle: Text(
                          AppLocalizations.of(context).darkModeHint,
                        ),
                        value: app.isDark,
                        onChanged: (value) {
                          context.read<AppController>().setDarkMode(value);
                        },
                      ),
                      Divider(height: 1, color: scheme.outline),
                      ListTile(
                        leading: const Icon(Icons.language_rounded),
                        title: Text(AppLocalizations.of(context).language),
                        subtitle: Text(
                          languageName(l10n, app.languageOverride),
                        ),
                        onTap: () => _pickLanguage(context, app),
                      ),
                      Divider(height: 1, color: scheme.outline),
                      ListTile(
                        leading: const Icon(Icons.replay_rounded),
                        title: Text(
                          AppLocalizations.of(context).replayOnboarding,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context).replayOnboardingHint,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const OnboardingScreen(replay: true),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: scheme.outline),
                      ListTile(
                        leading: const Icon(Icons.cached_rounded),
                        title: Text(AppLocalizations.of(context).clearCache),
                        subtitle: Text(
                          AppLocalizations.of(context).clearCacheHint,
                        ),
                        onTap: () => _confirmClear(context),
                      ),
                      Divider(height: 1, color: scheme.outline),
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded),
                        title: Text(l10n.about),
                        subtitle: Text(l10n.versionLabel(ApiConfig.appVersion)),
                        onTap: () => _about(context),
                      ),
                    ],
                  ),
                ),
                if (app.remoteConfig.links.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  SectionLabel(l10n.links),
                  const SizedBox(height: 10),
                  Material(
                    color: scheme.surface,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: BorderSide(color: scheme.outline),
                    ),
                    child: Column(
                      children: [
                        for (final link in app.remoteConfig.links)
                          ListTile(
                            leading: const Icon(Icons.link_rounded),
                            title: Text(linkLabel(l10n, link.label)),
                            onTap: () => openExternalUrl(link.url),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                SectionLabel(l10n.savedSection),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (saved.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: l10n.emptySavedTitle,
              message: l10n.emptySavedMessage,
              actionLabel: l10n.exploreImages,
              onAction: () => context.read<AppController>().setNav(0),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(pad, 0, pad, bottom),
            sliver: WallpaperSliverGrid(items: saved, heroPrefix: 'saved'),
          ),
        if (saved.isEmpty) SliverToBoxAdapter(child: SizedBox(height: bottom)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outline),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _pickLanguage(BuildContext context, AppController app) async {
  final l10n = AppLocalizations.of(context);
  final selected = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return SimpleDialog(
        title: Text(l10n.language),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'system'),
            child: Text(l10n.languageSystem),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'ar'),
            child: const Text('العربية'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'tr'),
            child: const Text('Türkçe'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'en'),
            child: const Text('English'),
          ),
        ],
      );
    },
  );
  if (selected == null || !context.mounted) return;
  await app.setLanguage(selected == 'system' ? null : selected);
}

Future<void> _confirmClear(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final approved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.clearCacheTitle),
        content: Text(l10n.clearCacheBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.confirm),
          ),
        ],
      );
    },
  );
  if (approved != true || !context.mounted) return;
  context.read<AppController>().clearCache();
}

void _about(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(AppLocalizations.of(dialogContext).about),
        content: Text(
          '${AppLocalizations.of(dialogContext).aboutBody}\n${AppLocalizations.of(dialogContext).versionLabel(ApiConfig.appVersion)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(dialogContext).ok),
          ),
        ],
      );
    },
  );
}
