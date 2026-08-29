// lib/core/widgets/clay_card.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ClayCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double shadowBlur;
  final double shadowOffset;
  final VoidCallback? onTap;
  final Color? color;

  const ClayCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.shadowBlur = 12,
    this.shadowOffset = 5,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final cardColor = color ?? ext.cardColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            // Light highlight – top-left
            BoxShadow(
              color: ext.shadowLight,
              offset: Offset(-shadowOffset, -shadowOffset),
              blurRadius: shadowBlur,
            ),
            // Depth shadow – bottom-right
            BoxShadow(
              color: ext.shadowDark,
              offset: Offset(shadowOffset, shadowOffset),
              blurRadius: shadowBlur,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
