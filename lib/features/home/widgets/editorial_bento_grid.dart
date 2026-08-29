// lib/features/home/widgets/editorial_bento_grid.dart

import 'package:flutter/material.dart';
import '../../../core/models/origo_category.dart';
import '../../../core/models/origo_item.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/origo_image.dart';
import '../../add/add_category_sheet.dart';
import '../../gallery/gallery_screen.dart';

class EditorialBentoGrid extends StatelessWidget {
  final List<OrigoCategory> categories;
  final Map<String, int> counts;
  final Map<String, OrigoItem?> covers;
  final bool isShowcase;

  const EditorialBentoGrid({
    super.key,
    required this.categories,
    required this.counts,
    required this.covers,
    required this.isShowcase,
  });

  void _openCategory(BuildContext context, String categoryKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GalleryScreen(category: categoryKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    int i = 0;

    while (i < categories.length) {
      // Pattern cycle: Dual (2) -> Panoramic Hero (1) -> Dual (2) -> Wide (1) ...
      final cycleIndex = i % 4;

      if (cycleIndex == 0) {
        // Dual Square Cards (Take up to 2 items)
        final first = categories[i];
        final second = (i + 1 < categories.length) ? categories[i + 1] : null;

        widgets.add(
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 172,
                  child: _BentoSquareCard(
                    category: first,
                    itemCount: counts[first.key] ?? 0,
                    latestItem: covers[first.key],
                    showCount: !isShowcase,
                    onTap: () => _openCategory(context, first.key),
                  ),
                ),
              ),
              if (second != null) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 172,
                    child: _BentoSquareCard(
                      category: second,
                      itemCount: counts[second.key] ?? 0,
                      latestItem: covers[second.key],
                      showCount: !isShowcase,
                      onTap: () => _openCategory(context, second.key),
                    ),
                  ),
                ),
              ] else
                const Spacer(),
            ],
          ),
        );
        widgets.add(const SizedBox(height: 14));
        i += (second != null ? 2 : 1);
      } else if (cycleIndex == 2 || (cycleIndex == 1 && i % 3 == 2)) {
        // Panoramic Hero Card (1 item)
        final current = categories[i];
        widgets.add(
          SizedBox(
            height: 195,
            child: _BentoPanoramicHeroCard(
              category: current,
              itemCount: counts[current.key] ?? 0,
              latestItem: covers[current.key],
              showCount: !isShowcase,
              onTap: () => _openCategory(context, current.key),
            ),
          ),
        );
        widgets.add(const SizedBox(height: 14));
        i += 1;
      } else {
        // Wide or Dual Row
        final first = categories[i];
        final second = (i + 1 < categories.length) ? categories[i + 1] : null;

        if (second != null && i + 2 == categories.length) {
          // If 2 remaining, show dual
          widgets.add(
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 172,
                    child: _BentoSquareCard(
                      category: first,
                      itemCount: counts[first.key] ?? 0,
                      latestItem: covers[first.key],
                      showCount: !isShowcase,
                      onTap: () => _openCategory(context, first.key),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 172,
                    child: _BentoSquareCard(
                      category: second,
                      itemCount: counts[second.key] ?? 0,
                      latestItem: covers[second.key],
                      showCount: !isShowcase,
                      onTap: () => _openCategory(context, second.key),
                    ),
                  ),
                ),
              ],
            ),
          );
          widgets.add(const SizedBox(height: 14));
          i += 2;
        } else {
          // Wide Footer Card
          widgets.add(
            SizedBox(
              height: 154,
              child: _BentoFooterCard(
                category: first,
                itemCount: counts[first.key] ?? 0,
                latestItem: covers[first.key],
                showCount: !isShowcase,
                onTap: () => _openCategory(context, first.key),
              ),
            ),
          );
          widgets.add(const SizedBox(height: 14));
          i += 1;
        }
      }
    }

    // Add New Category Card (hidden during showcase mode)
    if (!isShowcase) {
      widgets.add(
        _AddNewCategoryBentoCard(
          onTap: () => AddCategorySheet.show(context),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: widgets),
    );
  }
}

// ── Square Bento Card ────────────────────────────────────────────────────────

class _BentoSquareCard extends StatefulWidget {
  final OrigoCategory category;
  final int itemCount;
  final OrigoItem? latestItem;
  final bool showCount;
  final VoidCallback onTap;

  const _BentoSquareCard({
    required this.category,
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
    final accent = widget.category.color;
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
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),

                // Top right pill
                if (widget.showCount && widget.itemCount > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _CornerPill(
                      label:
                          '${widget.itemCount} ${widget.itemCount == 1 ? 'Asset' : 'Assets'}',
                    ),
                  ),

                // Bottom left title
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Text(
                    widget.category.displayName,
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

// ── Centerpiece Panoramic Hero Card ──────────────────────────────────────────

class _BentoPanoramicHeroCard extends StatefulWidget {
  final OrigoCategory category;
  final int itemCount;
  final OrigoItem? latestItem;
  final bool showCount;
  final VoidCallback onTap;

  const _BentoPanoramicHeroCard({
    required this.category,
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
    final accent = widget.category.color;
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
                      label:
                          '${widget.itemCount} ${widget.itemCount == 1 ? 'Asset' : 'Assets'}',
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
                              widget.category.displayName,
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

// ── Wide Footer Card ─────────────────────────────────────────────────────────

class _BentoFooterCard extends StatefulWidget {
  final OrigoCategory category;
  final int itemCount;
  final OrigoItem? latestItem;
  final bool showCount;
  final VoidCallback onTap;

  const _BentoFooterCard({
    required this.category,
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
    final accent = widget.category.color;
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
                      label:
                          '${widget.itemCount} ${widget.itemCount == 1 ? 'Asset' : 'Assets'}',
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
                        widget.category.displayName,
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

// ── Add New Category Card ────────────────────────────────────────────────────

class _AddNewCategoryBentoCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNewCategoryBentoCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          color: ext.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ext.accent.withValues(alpha: 0.35),
            width: 1.2,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: ext.shadowLight,
              offset: const Offset(-3, -3),
              blurRadius: 8,
            ),
            BoxShadow(
              color: ext.shadowDark,
              offset: const Offset(3, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ext.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: ext.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'CREATE CUSTOM CATEGORY',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: ext.accent,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared Corner Pill ───────────────────────────────────────────────────────

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
