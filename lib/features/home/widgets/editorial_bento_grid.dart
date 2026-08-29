// lib/features/home/widgets/editorial_bento_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/origo_category.dart';
import '../../../core/models/origo_item.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/origo_image.dart';
import '../../add/add_item_sheet.dart';
import '../../gallery/gallery_screen.dart';
import 'card_quick_actions_sheet.dart';

class EditorialBentoGrid extends StatelessWidget {
  final List<OrigoCategory> categories;
  final Map<String, int> counts;
  final Map<String, OrigoItem?> covers;

  const EditorialBentoGrid({
    super.key,
    required this.categories,
    required this.counts,
    required this.covers,
  });

  void _handleCardTap(BuildContext context, OrigoCategory category, int count) {
    HapticFeedback.lightImpact();
    if (count == 0) {
      AddItemSheet.show(context, initialCategory: category.key);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GalleryScreen(category: category.key),
        ),
      );
    }
  }

  void _showQuickActions(BuildContext context, OrigoCategory category) {
    CardQuickActionsSheet.show(
      context,
      category: category,
      itemCount: counts[category.key] ?? 0,
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
        final count1 = counts[first.key] ?? 0;
        final count2 = second != null ? (counts[second.key] ?? 0) : 0;

        widgets.add(
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 172,
                  child: _BentoSquareCard(
                    category: first,
                    itemCount: count1,
                    latestItem: covers[first.key],
                    onTap: () => _handleCardTap(context, first, count1),
                    onLongPress: () => _showQuickActions(context, first),
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
                      itemCount: count2,
                      latestItem: covers[second.key],
                      onTap: () => _handleCardTap(context, second, count2),
                      onLongPress: () => _showQuickActions(context, second),
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
        final count = counts[current.key] ?? 0;
        widgets.add(
          SizedBox(
            width: double.infinity,
            height: 195,
            child: _BentoPanoramicHeroCard(
              category: current,
              itemCount: count,
              latestItem: covers[current.key],
              onTap: () => _handleCardTap(context, current, count),
              onLongPress: () => _showQuickActions(context, current),
            ),
          ),
        );
        widgets.add(const SizedBox(height: 14));
        i += 1;
      } else {
        // Wide or Dual Row
        final first = categories[i];
        final second = (i + 1 < categories.length) ? categories[i + 1] : null;
        final count1 = counts[first.key] ?? 0;
        final count2 = second != null ? (counts[second.key] ?? 0) : 0;

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
                      itemCount: count1,
                      latestItem: covers[first.key],
                      onTap: () => _handleCardTap(context, first, count1),
                      onLongPress: () => _showQuickActions(context, first),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 172,
                    child: _BentoSquareCard(
                      category: second,
                      itemCount: count2,
                      latestItem: covers[second.key],
                      onTap: () => _handleCardTap(context, second, count2),
                      onLongPress: () => _showQuickActions(context, second),
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
              width: double.infinity,
              height: 154,
              child: _BentoFooterCard(
                category: first,
                itemCount: count1,
                latestItem: covers[first.key],
                onTap: () => _handleCardTap(context, first, count1),
                onLongPress: () => _showQuickActions(context, first),
              ),
            ),
          );
          widgets.add(const SizedBox(height: 14));
          i += 1;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgets,
      ),
    );
  }
}

// ── Square Bento Card ────────────────────────────────────────────────────────

class _BentoSquareCard extends StatefulWidget {
  final OrigoCategory category;
  final int itemCount;
  final OrigoItem? latestItem;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _BentoSquareCard({
    required this.category,
    required this.itemCount,
    required this.latestItem,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_BentoSquareCard> createState() => _BentoSquareCardState();
}

class _BentoSquareCardState extends State<_BentoSquareCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final hasImage = widget.latestItem != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: ext.cardColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      OrigoImage(
                        imagePath: widget.latestItem!.imagePath,
                        fit: BoxFit.cover,
                        errorWidget: _EmptyInvitationContent(
                          category: widget.category,
                          isCompact: true,
                        ),
                      ),

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
                      if (widget.itemCount > 0)
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
                  )
                : _EmptyInvitationContent(
                    category: widget.category,
                    isCompact: true,
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
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _BentoPanoramicHeroCard({
    required this.category,
    required this.itemCount,
    required this.latestItem,
    required this.onTap,
    this.onLongPress,
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
    final hasImage = widget.latestItem != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: ext.cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      OrigoImage(
                        imagePath: widget.latestItem!.imagePath,
                        fit: BoxFit.cover,
                        errorWidget: _EmptyInvitationContent(
                          category: widget.category,
                        ),
                      ),

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

                      // Top right pill
                      if (widget.itemCount > 0)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _CornerPill(
                            label:
                                '${widget.itemCount} ${widget.itemCount == 1 ? 'Asset' : 'Assets'}',
                          ),
                        ),

                      // Bottom left title & subtitle
                      Positioned(
                        left: 18,
                        right: 18,
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
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
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
                            if (widget.latestItem != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFD700),
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
                  )
                : _EmptyInvitationContent(
                    category: widget.category,
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
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _BentoFooterCard({
    required this.category,
    required this.itemCount,
    required this.latestItem,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_BentoFooterCard> createState() => _BentoFooterCardState();
}

class _BentoFooterCardState extends State<_BentoFooterCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final hasImage = widget.latestItem != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: ext.cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      OrigoImage(
                        imagePath: widget.latestItem!.imagePath,
                        fit: BoxFit.cover,
                        errorWidget: _EmptyInvitationContent(
                          category: widget.category,
                          isCompact: true,
                        ),
                      ),

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
                      if (widget.itemCount > 0)
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
                  )
                : _EmptyInvitationContent(
                    category: widget.category,
                    isCompact: true,
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Shared Corner Pill (Clean & Borderless) ──────────────────────────────────

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

// ── Interactive "Add Dream" Invitation Content ───────────────────────────────

class _EmptyInvitationContent extends StatelessWidget {
  final OrigoCategory category;
  final bool isCompact;

  const _EmptyInvitationContent({
    required this.category,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF263344),
                  const Color(0xFF19222E),
                ]
              : [
                  const Color(0xFFFFFFFF),
                  const Color(0xFFDDE7F0),
                ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isCompact ? 42 : 48,
            height: isCompact ? 42 : 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ext.accent.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.add_rounded,
              color: ext.accent,
              size: isCompact ? 24 : 28,
            ),
          ),
          SizedBox(height: isCompact ? 8 : 10),
          Text(
            widgetDisplayName(category),
            style: TextStyle(
              fontSize: isCompact ? 14 : 16,
              fontWeight: FontWeight.w800,
              color: ext.textPrimary,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String widgetDisplayName(OrigoCategory category) {
    return category.displayName;
  }
}
