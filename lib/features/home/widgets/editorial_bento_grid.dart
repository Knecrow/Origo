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
      final cycleIndex = i % 4;

      if (cycleIndex == 0) {
        // Dual Square Cards
        final first = categories[i];
        final second = (i + 1 < categories.length) ? categories[i + 1] : null;
        final count1 = counts[first.key] ?? 0;
        final count2 = second != null ? (counts[second.key] ?? 0) : 0;

        widgets.add(
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 176,
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
                    height: 176,
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
        // Panoramic Hero Card
        final current = categories[i];
        final count = counts[current.key] ?? 0;
        widgets.add(
          SizedBox(
            height: 198,
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
          widgets.add(
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 176,
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
                    height: 176,
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
              height: 156,
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
      child: Column(children: widgets),
    );
  }
}

// ── Square Bento Card (Apple Photos / Invitation Style) ──────────────────────

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
            borderRadius: BorderRadius.circular(26),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
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
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.82),
                            ],
                            stops: const [0.3, 0.65, 1.0],
                          ),
                        ),
                      ),

                      // Bottom Content
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.category.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 6,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.itemCount} ${widget.itemCount == 1 ? 'item' : 'items'}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.1,
                              ),
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
            borderRadius: BorderRadius.circular(26),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
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
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.82),
                            ],
                            stops: const [0.25, 0.6, 1.0],
                          ),
                        ),
                      ),

                      // Bottom Content
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.4,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.latestItem != null
                                        ? widget.latestItem!.title
                                        : '${widget.itemCount} items',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (widget.itemCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4.5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.itemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
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
            borderRadius: BorderRadius.circular(26),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
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
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.82),
                            ],
                            stops: const [0.3, 0.65, 1.0],
                          ),
                        ),
                      ),

                      // Bottom Content
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.category.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 6,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.itemCount} ${widget.itemCount == 1 ? 'item' : 'items'}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.72),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ],
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF242426),
                  const Color(0xFF161618),
                ]
              : [
                  const Color(0xFFFFFFFF),
                  const Color(0xFFE5E5EA),
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
            category.displayName,
            style: TextStyle(
              fontSize: isCompact ? 14.5 : 16.5,
              fontWeight: FontWeight.w700,
              color: ext.textPrimary,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            'Tap to add dream',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: ext.textMuted,
              letterSpacing: -0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
