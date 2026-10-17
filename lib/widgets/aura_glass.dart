import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class AuraGlass extends StatelessWidget {
  const AuraGlass({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.borderRadius = 24,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return GlassmorphicContainer(
      width: width,
      height: height,
      borderRadius: borderRadius,
      blur: 18,
      alignment: Alignment.center,
      border: 1.2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: dark ? 0.18 : 0.62),
          Colors.white.withValues(alpha: dark ? 0.05 : 0.28),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.6),
          Colors.white.withValues(alpha: 0.08),
        ],
      ),
      child: child,
    );
  }
}
