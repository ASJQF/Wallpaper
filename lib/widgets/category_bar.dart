import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/layout.dart';
import 'network_art.dart';

const _icons = <String, IconData>{
  'photo': Icons.photo_camera_rounded,
  'art': Icons.palette_rounded,
  'architecture': Icons.apartment_rounded,
  'nature': Icons.park_rounded,
  'minimal': Icons.crop_square_rounded,
  'render': Icons.view_in_ar_rounded,
};

IconData _iconFor(String slug) {
  final value = slug.toLowerCase();
  for (final entry in _icons.entries) {
    if (value.contains(entry.key)) return entry.value;
  }
  return Icons.wallpaper_rounded;
}

class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.select<AppController, String?>(
      (controller) => controller.selectedCategoryId,
    );
    final categories = context.select<AppController, List<Category>>(
      (controller) => controller.categories,
    );
    final pad = pagePadding(MediaQuery.sizeOf(context).width);

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: pad),
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = index == 0 ? null : categories[index - 1];
          final label = category?.name ?? AppLocalizations.of(context).all;
          return Align(
            alignment: Alignment.center,
            child: _CategoryChip(
              label: label,
              icon: category == null ? null : _iconFor(category.slug),
              coverUrl: category?.coverUrl,
              selected: selected == category?.id,
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<AppController>().selectCategory(category?.id);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.coverUrl,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            gradient: selected ? AppColors.brandGradient : null,
            color: selected ? null : scheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: selected ? null : Border.all(color: scheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (coverUrl != null) ...[
                  ClipOval(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: NetworkArt(url: coverUrl!, cacheWidth: 64),
                    ),
                  ),
                  const SizedBox(width: 6),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: selected
                        ? Colors.white
                        : Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
