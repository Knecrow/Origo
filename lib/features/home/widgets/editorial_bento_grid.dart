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
    int cycle = 0;

    while (i < categories.length) {
      final remaining = categories.length - i;
      final cycleType = cycle % 3;

      if (cycleType == 0 && remaining >= 3) {
        // ── 1. Asymmetric Split A: Tall Hero on LEFT + 2 Stacked on RIGHT ──
        final tallCat = categories[i];
        final topCat = categories[i + 1];
        final bottomCat = categories[i + 2];

        final tallCount = counts[tallCat.key] ?? 0;
        final topCount = counts[topCat.key] ?? 0;
        final bottomCount = counts[bottomCat.key] ?? 0;

        widgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Tall Portrait Hero Card
              Expanded(
                child: SizedBox(
                  height: 366,
                  child: _BentoTallHeroCard(
                    category: tallCat,
                    itemCount: tallCount,
                    latestItem: covers[tallCat.key],
                    onTap: () => _handleCardTap(context, tallCat, tallCount),
                    onLongPress: () => _showQuickActions(context, tallCat),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Right: 2 Stacked Square Cards (176 + 14 + 176 = 366)
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 176,
                      child: _BentoSquareCard(
                        category: topCat,
                        itemCount: topCount,
                        latestItem: covers[topCat.key],
                        onTap: () => _handleCardTap(context, topCat, topCount),
                        onLongPress: () => _showQuickActions(context, topCat),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 176,
                      child: _BentoSquareCard(
                        category: bottomCat,
                        itemCount: bottomCount,
                        latestItem: covers[bottomCat.key],
                        onTap: () => _handleCardTap(context, bottomCat, bottomCount),
                        onLongPress: () => _showQuickActions(context, bottomCat),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        widgets.add(const SizedBox(height: 14));
        i += 3;
      } else if (cycleType == 1 && remaining >= 1) {
        // ── 2. Full-Width Panoramic Centerpiece ─────────────────────────────
        final panoCat = categories[i];
        final panoCount = counts[panoCat.key] ?? 0;

        widgets.add(
          SizedBox(
            height: 198,
            child: _BentoPanoramicHeroCard(
              category: panoCat,
              itemCount: panoCount,
              latestItem: covers[panoCat.key],
              onTap: () => _handleCardTap(context, panoCat, panoCount),
              onLongPress: () => _showQuickActions(context, panoCat),
            ),
          ),
        );
        widgets.add(const SizedBox(height: 14));
        i += 1;
      } else if (cycleType == 2 && remaining >= 3) {
        // ── 3. Asymmetric Split B: 2 Stacked on LEFT + Tall Hero on RIGHT ──
        final topCat = categories[i];
        final bottomCat = categories[i + 1];
        final tallCat = categories[i + 2];

        final topCount = counts[topCat.key] ?? 0;
        final bottomCount = counts[bottomCat.key] ?? 0;
        final tallCount = counts[tallCat.key] ?? 0;

        widgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: 2 Stacked Square Cards (176 + 14 + 176 = 366)
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 176,
                      child: _BentoSquareCard(
                        category: topCat,
                        itemCount: topCount,
                        latestItem: covers[topCat.key],
                        onTap: () => _handleCardTap(context, topCat, topCount),
                        onLongPress: () => _showQuickActions(context, topCat),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 176,
                      child: _BentoSquareCard(
                        category: bottomCat,
                        itemCount: bottomCount,
                        latestItem: covers[bottomCat.key],
                        onTap: () => _handleCardTap(context, bottomCat, bottomCount),
                        onLongPress: () => _showQuickActions(context, bottomCat),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Right: Tall Portrait Hero Card
              Expanded(
                child: SizedBox(
                  height: 366,
                  child: _BentoTallHeroCard(
                    category: tallCat,
                    itemCount: tallCount,
                    latestItem: covers[tallCat.key],
                    onTap: () => _handleCardTap(context, tallCat, tallCount),
                    onLongPress: () => _showQuickActions(context, tallCat),
                  ),
                ),
              ),
            ],
          ),
        );
        widgets.add(const SizedBox(height: 14));
        i += 3;
      } else {
        // ── Fallback for 1 or 2 remainder categories ────────────────────────
        if (remaining == 2) {
          final first = categories[i];
          final second = categories[i + 1];
          final count1 = counts[first.key] ?? 0;
          final count2 = counts[second.key] ?? 0;

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
          final first = categories[i];
          final count1 = counts[first.key] ?? 0;

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
      cycle++;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: widgets),
    );
  }
}

// ── Tall Portrait Hero Card (1:1 Asymmetric Height = 366px) ──────────────────

class _BentoTallHeroCard extends StatefulWidget {
  final OrigoCategory category;
  final int itemCount;
  final OrigoItem? latestItem;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _BentoTallHeroCard({
    required this.category,
    required this.itemCount,
    required this.latestItem,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_BentoTallHeroCard> createState() => _BentoTallHeroCardState();
}

class _BentoTallHeroCardState extends State<_BentoTallHeroCard> {
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
                          isTall: true,
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
                              Colors.black.withValues(alpha: 0.35),
                              Colors.black.withValues(alpha: 0.85),
                            ],
                            stops: const [0.35, 0.65, 1.0],
                          ),
                        ),
                      ),

                      // Top Featured Pill
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.category.icon,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${widget.itemCount} ${widget.itemCount == 1 ? 'item' : 'items'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Content
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.category.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 6,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.latestItem != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                widget.latestItem!.title,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : _EmptyInvitationContent(
                    category: widget.category,
                    isTall: true,
                  ),
          ),
        ),
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
  final bool isTall;

  const _EmptyInvitationContent({
    required this.category,
    this.isCompact = false,
    this.isTall = false,
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
            width: isTall ? 54 : (isCompact ? 42 : 48),
            height: isTall ? 54 : (isCompact ? 42 : 48),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ext.accent.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.add_rounded,
              color: ext.accent,
              size: isTall ? 32 : (isCompact ? 24 : 28),
            ),
          ),
          SizedBox(height: isTall ? 14 : (isCompact ? 8 : 10)),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: isTall ? 18 : (isCompact ? 14.5 : 16.5),
              fontWeight: FontWeight.w700,
              color: ext.textPrimary,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            'Tap to add dream',
            style: TextStyle(
              fontSize: isTall ? 13 : 11.5,
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
