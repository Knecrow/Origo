// lib/features/home/widgets/category_card.dart

import 'package:flutter/material.dart';
import '../../../core/models/origo_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_icon_badge.dart';
import '../../../core/widgets/origo_image.dart';

const Map<String, IconData> kCategoryIcons = {
  'Home': Icons.home_rounded,
  'Places': Icons.explore_rounded,
  'Garage': Icons.directions_car_rounded,
  'Jets': Icons.flight_rounded,
  'Yachts': Icons.directions_boat_rounded,
  'Others': Icons.category_rounded,
};

class CategoryCard extends StatelessWidget {
  final String category;
  final int itemCount;
  final OrigoItem? latestItem;
  final VoidCallback? onTap;
  final bool showCount;

  const CategoryCard({
    super.key,
    required this.category,
    required this.itemCount,
    this.latestItem,
    this.onTap,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final accentColor =
        AppColors.categoryColors[category] ?? ext.accent;
    final icon = kCategoryIcons[category] ?? Icons.category_rounded;
    final hasImage = latestItem != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ext.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ext.shadowLight,
              offset: const Offset(-5, -5),
              blurRadius: 12,
            ),
            BoxShadow(
              color: ext.shadowDark,
              offset: const Offset(5, 5),
              blurRadius: 12,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image or gradient
              Positioned.fill(
                child: hasImage
                    ? OrigoImage(
                        imagePath: latestItem!.imagePath,
                        fit: BoxFit.cover,
                        errorWidget: _GradientBg(color: accentColor),
                      )
                    : _GradientBg(color: accentColor),
              ),
              // Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: hasImage ? 0.3 : 0.1),
                        Colors.black.withValues(alpha: hasImage ? 0.6 : 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClayIconBadge(
                          icon: icon,
                          size: 20,
                          padding: 10,
                          iconColor: Colors.white,
                          badgeColor: accentColor.withValues(alpha: 0.7),
                        ),
                        if (showCount && itemCount > 0)
                          _CountBadge(count: itemCount),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      itemCount == 0
                          ? 'No items'
                          : '$itemCount item${itemCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBg extends StatelessWidget {
  final Color color;
  const _GradientBg({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.7),
            color.withValues(alpha: 0.4),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30, width: 1),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
