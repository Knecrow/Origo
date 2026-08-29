// lib/features/home/widgets/editorial_bento_grid.dart

import 'package:flutter/material.dart';
import '../../../core/models/origo_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/origo_image.dart';
import '../../gallery/gallery_screen.dart';

const Map<String, String> kCategoryDisplayNames = {
  'Home': 'HOME & ESTATE',
  'Garage': 'GARAGE & FLEET',
  'Jets': 'JETS & AVIATION',
  'Places': 'PLACES & TRAVEL',
  'Yachts': 'YACHTS & MARINE',
  'Others': 'COLLECTIONS & LUXURY',
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
          // ── Row 1: Dual Top Cards (HOME & ESTATE + GARAGE & FLEET) ───────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 172,
                  child: _BentoSquareCard(
                    categoryKey: 'Home',
                    displayTitle: kCategoryDisplayNames['Home']!,
                    itemCount: counts['Home'] ?? 0,
                    latestItem: covers['Home'],
                    showCount: !isShowcase,
                    onTap: () => _openCategory(context, 'Home'),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 172,
                  child: _BentoSquareCard(
                    categoryKey: 'Garage',
                    displayTitle: kCategoryDisplayNames['Garage']!,
                    itemCount: counts['Garage'] ?? 0,
                    latestItem: covers['Garage'],
                    showCount: !isShowcase,
                    onTap: () => _openCategory(context, 'Garage'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Row 2: Centerpiece Panoramic Hero Card (JETS & AVIATION) ───────
          SizedBox(
            height: 195,
            child: _BentoPanoramicHeroCard(
              categoryKey: 'Jets',
              displayTitle: kCategoryDisplayNames['Jets']!,
              itemCount: counts['Jets'] ?? 0,
              latestItem: covers['Jets'],
              showCount: !isShowcase,
              onTap: () => _openCategory(context, 'Jets'),
            ),
          ),
          const SizedBox(height: 14),

          // ── Row 3: Dual Cards (PLACES & TRAVEL + YACHTS & MARINE) ──────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 172,
                  child: _BentoSquareCard(
                    categoryKey: 'Places',
                    displayTitle: kCategoryDisplayNames['Places']!,
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
                  height: 172,
                  child: _BentoSquareCard(
                    categoryKey: 'Yachts',
                    displayTitle: kCategoryDisplayNames['Yachts']!,
                    itemCount: counts['Yachts'] ?? 0,
                    latestItem: covers['Yachts'],
                    showCount: !isShowcase,
                    onTap: () => _openCategory(context, 'Yachts'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Row 4: Wide Footer Card (COLLECTIONS & LUXURY) ─────────────────
          SizedBox(
            height: 154,
            child: _BentoFooterCard(
              categoryKey: 'Others',
              displayTitle: kCategoryDisplayNames['Others']!,
              itemCount: counts['Others'] ?? 0,
              latestItem: covers['Others'],
              showCount: !isShowcase,
              onTap: () => _openCategory(context, 'Others'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Square Bento Card (Rows 1 & 3) ───────────────────────────────────────────

class _BentoSquareCard extends StatefulWidget {
  final String categoryKey;
  final String displayTitle;
  final int itemCount;
  final OrigoItem? latestItem;
  final bool showCount;
  final VoidCallback onTap;

  const _BentoSquareCard({
    required this.categoryKey,
    required this.displayTitle,
    required this.itemCount,
    required this.latestItem,
    required this.showCount,
    required this.onTap,
  });

  @override
  State<_BentoSquareCard> createState() => _BentoSquareCardState();
}

class _BentoSquareCardState extends State<_BentoSquareCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final accent = AppColors.categoryColors[widget.categoryKey] ?? ext.accent;
    final hasImage = widget.latestItem != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: ext.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
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
                color: accent.withValues(alpha: 0.14),
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
                // Image or gradient fallback
                if (hasImage)
                  OrigoImage(
                    imagePath: widget.latestItem!.imagePath,
                    fit: BoxFit.cover,
                    errorWidget: _GradientFallback(color: accent),
                  )
                else
                  _GradientFallback(color: accent),

                // Smooth dark gradient overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),

                // Top-right Asset count pill
                if (widget.showCount && widget.itemCount > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _CornerPill(
                      label: '${widget.itemCount} ${widget.itemCount == 1 ? 'Asset' : 'Assets'}',
                    ),
                  ),

                // Bottom-left Category Title
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Text(
                    widget.displayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      height: 1.25,
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

// ── Centerpiece Panoramic Hero Card (Row 2 - JETS & AVIATION) ────────────────

class _BentoPanoramicHeroCard extends StatefulWidget {
  final String categoryKey;
  final String displayTitle;
  final int itemCount;
  final OrigoItem? latestItem;
  final bool showCount;
  final VoidCallback onTap;

  const _BentoPanoramicHeroCard({
    required this.categoryKey,
    required this.displayTitle,
    required this.itemCount,
    required this.latestItem,
    required this.showCount,
    required this.onTap,
  });

  @override
  State<_BentoPanoramicHeroCard> createState() =>
      _BentoPanoramicHeroCardState();
}

class _BentoPanoramicHeroCardState extends State<_BentoPanoramicHeroCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final accent = AppColors.categoryColors[widget.categoryKey] ?? ext.accent;
    final hasImage = widget.latestItem != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: ext.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
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
              BoxShadow(
                color: accent.withValues(alpha: 0.22),
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
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),

                // Top Right Pill
                if (widget.showCount && widget.itemCount > 0)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _CornerPill(
                      label: '${widget.itemCount} ${widget.itemCount == 1 ? 'Asset' : 'Assets'}',
                    ),
                  ),

                // Bottom Left Title & Sub-detail
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.displayTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.latestItem != null) ...[
                              const SizedBox(height: 3),
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
                      if (widget.showCount && widget.latestItem != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: const Color(0xFFFFD700),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Featured',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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

// ── Wide Footer Card (Row 4 - COLLECTIONS & LUXURY) ──────────────────────────

class _BentoFooterCard extends StatefulWidget {
  final String categoryKey;
  final String displayTitle;
  final int itemCount;
  final OrigoItem? latestItem;
  final bool showCount;
  final VoidCallback onTap;

  const _BentoFooterCard({
    required this.categoryKey,
    required this.displayTitle,
    required this.itemCount,
    required this.latestItem,
    required this.showCount,
    required this.onTap,
  });

  @override
  State<_BentoFooterCard> createState() => _BentoFooterCardState();
}

class _BentoFooterCardState extends State<_BentoFooterCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final accent = AppColors.categoryColors[widget.categoryKey] ?? ext.accent;
    final hasImage = widget.latestItem != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: ext.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
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
                color: accent.withValues(alpha: 0.16),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
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
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),

                // Top Right Pill
                if (widget.showCount && widget.itemCount > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _CornerPill(
                      label: '${widget.itemCount} ${widget.itemCount == 1 ? 'Asset' : 'Assets'}',
                    ),
                  ),

                // Bottom Left Title
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.displayTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 14,
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

// ── Floating Corner Frosted Pill ─────────────────────────────────────────────

class _CornerPill extends StatelessWidget {
  final String label;

  const _CornerPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
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
