// lib/features/home/widgets/editorial_bento_grid.dart

import 'package:flutter/material.dart';
import '../../../core/models/origo_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_icon_badge.dart';
import '../../../core/widgets/frosted_glass_container.dart';
import '../../../core/widgets/origo_image.dart';
import '../../gallery/gallery_screen.dart';
import 'category_card.dart';

const Map<String, String> kCategorySubtitles = {
  'Home': 'SANCTUARY & LIVING',
  'Garage': 'PRECISION MOBILITY',
  'Jets': 'PRIVATE AVIATION',
  'Yachts': 'MARITIME FLEET',
  'Places': 'GLOBAL HORIZONS',
  'Others': 'BESPOKE ACQUISITIONS',
};

const Map<String, String> kCategoryNumbers = {
  'Home': '01',
  'Garage': '02',
  'Jets': '03',
  'Yachts': '04',
  'Places': '05',
  'Others': '06',
};

class EditorialBentoGrid extends StatelessWidget {
  final Map<String, int> counts;
  final Map<String, OrigoItem?> covers;
  final bool isShowcase;

  const EditorialBentoGrid({
    super.key,
    required this.counts,
    required this.covers,
    required this.isShowcase,
  });

  void _openCategory(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GalleryScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // ── 1. Full-Width Panoramic Bento Hero Card (HOME) ───────────
          _BentoHeroCard(
            category: 'Home',
            itemCount: counts['Home'] ?? 0,
            latestItem: covers['Home'],
            showCount: !isShowcase,
            onTap: () => _openCategory(context, 'Home'),
          ),
          const SizedBox(height: 14),

          // ── 2. Asymmetric Middle Tier: Tall Portrait (GARAGE) + Stacked Dual (JETS, YACHTS) ─
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Tall Portrait Feature (Garage)
              Expanded(
                flex: 11,
                child: SizedBox(
                  height: 254,
                  child: _BentoPortraitCard(
                    category: 'Garage',
                    itemCount: counts['Garage'] ?? 0,
                    latestItem: covers['Garage'],
                    showCount: !isShowcase,
                    onTap: () => _openCategory(context, 'Garage'),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Right: Stacked Dual Compact Cards (Jets & Yachts)
              Expanded(
                flex: 12,
                child: SizedBox(
                  height: 254,
                  child: Column(
                    children: [
                      Expanded(
                        child: _BentoCompactCard(
                          category: 'Jets',
                          itemCount: counts['Jets'] ?? 0,
                          latestItem: covers['Jets'],
                          showCount: !isShowcase,
                          onTap: () => _openCategory(context, 'Jets'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: _BentoCompactCard(
                          category: 'Yachts',
                          itemCount: counts['Yachts'] ?? 0,
                          latestItem: covers['Yachts'],
                          showCount: !isShowcase,
                          onTap: () => _openCategory(context, 'Yachts'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── 3. Bottom Tier: Balanced Landscape Pair (PLACES & OTHERS) ─
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 156,
                  child: _BentoLandscapeCard(
                    category: 'Places',
                    itemCount: counts['Places'] ?? 0,
                    latestItem: covers['Places'],
                    showCount: !isShowcase,
                    onTap: () => _openCategory(context, 'Places'),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 156,
                  child: _BentoLandscapeCard(
                    category: 'Others',
                    itemCount: counts['Others'] ?? 0,
                    latestItem: covers['Others'],
                    showCount: !isShowcase,
                    onTap: () => _openCategory(context, 'Others'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 1. Hero Panoramic Card ───────────────────────────────────────────────────

class _BentoHeroCard extends StatefulWidget {
  final String category;
  final int itemCount;
  final OrigoItem? latestItem;
  final bool showCount;
  final VoidCallback onTap;

  const _BentoHeroCard({
    required this.category,
    required this.itemCount,
    required this.latestItem,
    required this.showCount,
    required this.onTap,
  });

  @override
  State<_BentoHeroCard> createState() => _BentoHeroCardState();
}

class _BentoHeroCardState extends State<_BentoHeroCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final accent = AppColors.categoryColors[widget.category] ?? ext.accent;
    final icon = kCategoryIcons[widget.category] ?? Icons.home_rounded;
    final hasImage = widget.latestItem != null;
    final numStr = kCategoryNumbers[widget.category] ?? '01';
    final subtitle = kCategorySubtitles[widget.category] ?? 'VISION';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: ext.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ext.shadowLight,
                offset: const Offset(-6, -6),
                blurRadius: 16,
              ),
              BoxShadow(
                color: ext.shadowDark,
                offset: const Offset(6, 6),
                blurRadius: 16,
              ),
              // Subtle ambient accent halo
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image / Gradient
                if (hasImage)
                  OrigoImage(
                    imagePath: widget.latestItem!.imagePath,
                    fit: BoxFit.cover,
                    errorWidget: _GradientFallback(color: accent),
                  )
                else
                  _GradientFallback(color: accent),

                // Editorial gradient scrim
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.25),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.2, 1.0],
                    ),
                  ),
                ),

                // Top row: Number Badge & Category Icon + Count
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Editorial index tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$numStr // FEATURED HABITAT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      // Clay Icon badge
                      ClayIconBadge(
                        icon: icon,
                        size: 18,
                        padding: 8,
                        iconColor: Colors.white,
                        badgeColor: accent.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),

                // Bottom Content with Frosted Glass Label
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: FrostedGlassContainer(
                    blur: 14,
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    tint: Colors.black.withValues(alpha: 0.35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: accent.withValues(alpha: 0.9),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (widget.latestItem != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.latestItem!.title,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (widget.showCount)
                          _BentoCountPill(
                            count: widget.itemCount,
                            accentColor: accent,
                          ),
                      ],
                    ),
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

// ── 2. Portrait Card (Tall 250px) ───────────────────────────────────────────

class _BentoPortraitCard extends StatefulWidget {
  final String category;
  final int itemCount;
  final OrigoItem? latestItem;
  final bool showCount;
  final VoidCallback onTap;

  const _BentoPortraitCard({
    required this.category,
    required this.itemCount,
    required this.latestItem,
    required this.showCount,
    required this.onTap,
  });

  @override
  State<_BentoPortraitCard> createState() => _BentoPortraitCardState();
}

class _BentoPortraitCardState extends State<_BentoPortraitCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final accent = AppColors.categoryColors[widget.category] ?? ext.accent;
    final icon = kCategoryIcons[widget.category] ?? Icons.directions_car_rounded;
    final hasImage = widget.latestItem != null;
    final numStr = kCategoryNumbers[widget.category] ?? '02';
    final subtitle = kCategorySubtitles[widget.category] ?? 'MOBILITY';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: ext.cardColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: ext.shadowLight,
                offset: const Offset(-5, -5),
                blurRadius: 14,
              ),
              BoxShadow(
                color: ext.shadowDark,
                offset: const Offset(5, 5),
                blurRadius: 14,
              ),
              BoxShadow(
                color: accent.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  OrigoImage(
                    imagePath: widget.latestItem!.imagePath,
                    fit: BoxFit.cover,
                    errorWidget: _GradientFallback(color: accent),
                  )
                else
                  _GradientFallback(color: accent),

                // Gradient scrim
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),

                // Top row
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        numStr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      ClayIconBadge(
                        icon: icon,
                        size: 16,
                        padding: 7,
                        iconColor: Colors.white,
                        badgeColor: accent.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),

                // Bottom details
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.95),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (widget.showCount)
                        _BentoCountPill(
                          count: widget.itemCount,
                          accentColor: accent,
                        ),
                    ],
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

// ── 3. Compact Stacked Card (Jets & Yachts) ──────────────────────────────────

class _BentoCompactCard extends StatefulWidget {
  final String category;
  final int itemCount;
  final OrigoItem? latestItem;
  final bool showCount;
  final VoidCallback onTap;

  const _BentoCompactCard({
    required this.category,
    required this.itemCount,
    required this.latestItem,
    required this.showCount,
    required this.onTap,
  });

  @override
  State<_BentoCompactCard> createState() => _BentoCompactCardState();
}

class _BentoCompactCardState extends State<_BentoCompactCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final accent = AppColors.categoryColors[widget.category] ?? ext.accent;
    final icon = kCategoryIcons[widget.category] ?? Icons.flight_rounded;
    final hasImage = widget.latestItem != null;
    final numStr = kCategoryNumbers[widget.category] ?? '03';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: ext.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ext.shadowLight,
                offset: const Offset(-4, -4),
                blurRadius: 12,
              ),
              BoxShadow(
                color: ext.shadowDark,
                offset: const Offset(4, 4),
                blurRadius: 12,
              ),
              BoxShadow(
                color: accent.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  OrigoImage(
                    imagePath: widget.latestItem!.imagePath,
                    fit: BoxFit.cover,
                    errorWidget: _GradientFallback(color: accent),
                  )
                else
                  _GradientFallback(color: accent),

                // Subtle dark gradient
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClayIconBadge(
                            icon: icon,
                            size: 15,
                            padding: 6,
                            iconColor: Colors.white,
                            badgeColor: accent.withValues(alpha: 0.8),
                          ),
                          Text(
                            numStr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (widget.showCount)
                            _BentoCountPill(
                              count: widget.itemCount,
                              accentColor: accent,
                              compact: true,
                            ),
                        ],
                      ),
                    ],
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

// ── 4. Balanced Landscape Card (Places & Others) ─────────────────────────────

class _BentoLandscapeCard extends StatefulWidget {
  final String category;
  final int itemCount;
  final OrigoItem? latestItem;
  final bool showCount;
  final VoidCallback onTap;

  const _BentoLandscapeCard({
    required this.category,
    required this.itemCount,
    required this.latestItem,
    required this.showCount,
    required this.onTap,
  });

  @override
  State<_BentoLandscapeCard> createState() => _BentoLandscapeCardState();
}

class _BentoLandscapeCardState extends State<_BentoLandscapeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final accent = AppColors.categoryColors[widget.category] ?? ext.accent;
    final icon = kCategoryIcons[widget.category] ?? Icons.explore_rounded;
    final hasImage = widget.latestItem != null;
    final numStr = kCategoryNumbers[widget.category] ?? '05';
    final subtitle = kCategorySubtitles[widget.category] ?? 'EXPEDITIONS';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: ext.cardColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: ext.shadowLight,
                offset: const Offset(-5, -5),
                blurRadius: 14,
              ),
              BoxShadow(
                color: ext.shadowDark,
                offset: const Offset(5, 5),
                blurRadius: 14,
              ),
              BoxShadow(
                color: accent.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  OrigoImage(
                    imagePath: widget.latestItem!.imagePath,
                    fit: BoxFit.cover,
                    errorWidget: _GradientFallback(color: accent),
                  )
                else
                  _GradientFallback(color: accent),

                // Scrim
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClayIconBadge(
                            icon: icon,
                            size: 16,
                            padding: 7,
                            iconColor: Colors.white,
                            badgeColor: accent.withValues(alpha: 0.8),
                          ),
                          Text(
                            numStr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.95),
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (widget.showCount)
                                _BentoCountPill(
                                  count: widget.itemCount,
                                  accentColor: accent,
                                  compact: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
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

// ── Shared Bento Helpers ─────────────────────────────────────────────────────

class _BentoCountPill extends StatelessWidget {
  final int count;
  final Color accentColor;
  final bool compact;

  const _BentoCountPill({
    required this.count,
    required this.accentColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Text(
        count == 0 ? '0' : (compact ? '$count' : '$count dreams'),
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _GradientFallback extends StatelessWidget {
  final Color color;
  const _GradientFallback({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.85),
            color.withValues(alpha: 0.45),
          ],
        ),
      ),
    );
  }
}
