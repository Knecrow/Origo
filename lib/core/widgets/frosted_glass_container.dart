// lib/core/widgets/frosted_glass_container.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedGlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? tint;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const FrostedGlassContainer({
    super.key,
    required this.child,
    this.blur = 12,
    this.tint,
    this.borderRadius = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final defaultTint = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.4);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: tint ?? defaultTint,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
