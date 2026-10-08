import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NetworkArt extends StatelessWidget {
  const NetworkArt({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surfaceHigh,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stack) {
        return Container(
          color: AppColors.surfaceHigh,
          alignment: Alignment.center,
          child: const Icon(Icons.image_outlined, color: AppColors.muted),
        );
      },
    );
  }
}
