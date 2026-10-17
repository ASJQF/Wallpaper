import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'shimmer_box.dart';

class NetworkArt extends StatelessWidget {
  const NetworkArt({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  final String url;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      return const SizedBox.expand(child: _ArtFallback());
    }
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      // The web engine ignores decode size and would otherwise fetch bytes with
      // XHR. That request is blocked when the media host does not send CORS.
      cacheWidth: kIsWeb ? null : cacheWidth,
      webHtmlElementStrategy: kIsWeb
          ? WebHtmlElementStrategy.prefer
          : WebHtmlElementStrategy.never,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ShimmerBox();
      },
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          debugPrint('NetworkArt failed to load $url: $error');
        }
        return const SizedBox.expand(child: _ArtFallback());
      },
    );
  }
}

class _ArtFallback extends StatelessWidget {
  const _ArtFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.brandGradient),
      child: Center(
        child: Icon(Icons.image_outlined, color: Colors.white70, size: 32),
      ),
    );
  }
}
