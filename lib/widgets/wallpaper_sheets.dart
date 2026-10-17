import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/wallpaper.dart';
import '../state/app_controller.dart';
import '../utils/localize.dart';
import 'app_message.dart';
import 'avatar.dart';
import 'network_art.dart';

void showShareSheet(BuildContext context, Wallpaper wallpaper) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final bottom = MediaQuery.paddingOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 12 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.share,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            _ShareTile(
              icon: Icons.link_rounded,
              label: l10n.copyLink,
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: wallpaper.shareUrl),
                );
                if (!sheetContext.mounted || !context.mounted) return;
                Navigator.pop(sheetContext);
                showAppMessage(context, l10n.linkCopied, bottom: 120);
              },
            ),
            _ShareTile(
              icon: Icons.chat_rounded,
              label: l10n.whatsapp,
              onTap: () =>
                  _copyFor(context, sheetContext, wallpaper, l10n.whatsapp),
            ),
            _ShareTile(
              icon: Icons.camera_alt_outlined,
              label: l10n.instagram,
              onTap: () =>
                  _copyFor(context, sheetContext, wallpaper, l10n.instagram),
            ),
            _ShareTile(
              icon: Icons.more_horiz_rounded,
              label: l10n.more,
              onTap: () => _copyFor(context, sheetContext, wallpaper, l10n.more),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _copyFor(
  BuildContext context,
  BuildContext sheetContext,
  Wallpaper wallpaper,
  String target,
) async {
  await Clipboard.setData(ClipboardData(text: wallpaper.shareUrl));
  if (!sheetContext.mounted || !context.mounted) return;
  Navigator.pop(sheetContext);
  showAppMessage(
    context,
    AppLocalizations.of(context).copiedFor(target),
    bottom: 120,
  );
}

void showInfoSheet(
  BuildContext context,
  Wallpaper wallpaper, {
  required void Function(Wallpaper item) onOpen,
}) {
  final related = context.read<AppController>().relatedTo(wallpaper);
  final description = wallpaper.description;

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final credit = creditLabel(l10n, wallpaper.creditName);
      final bottom = MediaQuery.paddingOf(sheetContext).bottom;
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetaRow(label: l10n.resolution, value: wallpaper.resolution),
            _MetaRow(label: l10n.fileSize, value: wallpaper.fileSize),
            _MetaRow(label: l10n.category, value: credit),
            _MetaRow(label: l10n.license, value: l10n.licenseValue),
            if (description != null && description.isNotEmpty)
              _MetaRow(label: l10n.description, value: description),
            const SizedBox(height: 8),
            Text(
              l10n.category,
              style: Theme.of(
                sheetContext,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Avatar(url: '', name: credit, radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    credit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            if (related.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.moreFromCategory,
                style: TextStyle(
                  color: Theme.of(sheetContext).hintColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: related.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = related[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onOpen(item);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 64,
                          child: NetworkArt(url: item.imageUrl),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}
