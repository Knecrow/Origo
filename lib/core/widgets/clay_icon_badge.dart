// lib/core/widgets/clay_icon_badge.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ClayIconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? iconColor;
  final Color? badgeColor;
  final double padding;
  final String? label;
  final VoidCallback? onTap;

  const ClayIconBadge({
    super.key,
    required this.icon,
    this.size = 24,
    this.iconColor,
    this.badgeColor,
    this.padding = 12,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final bg = badgeColor ?? ext.cardColor;
    final iconCol = iconColor ?? ext.accent;
    final containerSize = size + padding * 2;

    Widget badge = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(containerSize / 2.5),
      ),
      child: Icon(icon, size: size, color: iconCol),
    );

    if (label != null || onTap != null) {
      badge = GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            badge,
            if (label != null) ...[
              const SizedBox(height: 6),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: ext.textMuted,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return badge;
  }
}
