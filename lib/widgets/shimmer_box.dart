import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/layout.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: dark ? const Color(0xFF171722) : const Color(0xFFE6E2EF),
      highlightColor: dark ? const Color(0xFF32323F) : const Color(0xFFF8F6FC),
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.radius = 0});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class CarouselShimmer extends StatelessWidget {
  const CarouselShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = (width * 0.48).clamp(180.0, 250.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppShimmer(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(28)),
            ),
            child: SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class WallpaperShimmerGrid extends StatelessWidget {
  const WallpaperShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = gridColumns(MediaQuery.sizeOf(context).width);
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: columns >= 3 ? 0.72 : 0.66,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const AppShimmer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(22)),
            ),
            child: SizedBox.expand(),
          ),
        ),
        childCount: columns * 3,
      ),
    );
  }
}
