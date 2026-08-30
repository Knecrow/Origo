// lib/core/widgets/clay_icon_badge.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class ClayIconBadge extends StatefulWidget {
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
    this.size = 22,
    this.iconColor,
    this.badgeColor,
    this.padding = 12,
    this.label,
    this.onTap,
  });

  @override
  State<ClayIconBadge> createState() => _ClayIconBadgeState();
}

class _ClayIconBadgeState extends State<ClayIconBadge> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerSize = widget.size + widget.padding * 2;
    final borderRadius = BorderRadius.circular(containerSize * 0.42);

    final bg = widget.badgeColor ?? (isDark ? const Color(0xFF1E2135) : const Color(0xFFFFFFFF));
    final iconCol = widget.iconColor ?? (isDark ? Colors.white : ext.textPrimary);

    Widget badge = AnimatedScale(
      scale: _pressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    bg.withValues(alpha: 1.0),
                    bg.withValues(alpha: 0.75),
                  ]
                : [
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF3F4FB),
                  ],
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(-1, -1),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF767F9E).withValues(alpha: 0.16),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 8,
                    offset: Offset(-2, -2),
                  ),
                ],
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: widget.size,
            color: iconCol,
          ),
        ),
      ),
    );

    if (widget.label != null || widget.onTap != null) {
      badge = GestureDetector(
        onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
        onTapUp: widget.onTap != null
            ? (_) {
                setState(() => _pressed = false);
                HapticFeedback.selectionClick();
                widget.onTap!();
              }
            : null,
        onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            badge,
            if (widget.label != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.label!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ext.textMuted,
                  letterSpacing: 0.2,
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
