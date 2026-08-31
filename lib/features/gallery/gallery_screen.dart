// lib/features/gallery/gallery_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/origo_item.dart';
import '../../core/providers/items_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';
import '../../core/widgets/origo_image.dart';
import '../add/add_item_sheet.dart';
import '../home/widgets/spotlight_carousel.dart';

class GalleryScreen extends StatefulWidget {
  final String category;
  final String? initialSubFilter;

  const GalleryScreen({
    super.key,
    required this.category,
    this.initialSubFilter,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<String> _customSubCategories = [];

  void _promptAddSubCategory(BuildContext context, String displayName) {
    HapticFeedback.lightImpact();
    final ext = context.ext;
    final textCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: ext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'New Sub-Category',
          style: TextStyle(
            color: ext.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add a sub-category under $displayName (e.g. Villas, Penthouses, Estates)',
              style: TextStyle(color: ext.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textCtrl,
              autofocus: true,
              style: TextStyle(color: ext.textPrimary),
              decoration: InputDecoration(
                hintText: 'Sub-Category Name',
                filled: true,
                fillColor: ext.cardSecondaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: ext.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = textCtrl.text.trim();
              if (val.isNotEmpty) {
                HapticFeedback.mediumImpact();
                setState(() {
                  if (!_customSubCategories.contains(val)) {
                    _customSubCategories.add(val);
                  }
                });
                Navigator.pop(dialogCtx);
                AddItemSheet.show(
                  context,
                  initialCategory: widget.category,
                  initialSubCategory: val,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ext.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Add Sub-Category'),
          ),
        ],
      ),
    );
  }

  void _showSubCategoryActions(BuildContext context, String subName, int count) {
    HapticFeedback.mediumImpact();
    final ext = context.ext;
    final itemsProv = context.read<ItemsProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: ext.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: ext.shadowDark.withValues(alpha: 0.25),
              blurRadius: 28,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ext.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ext.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // Action 1: Add Dream
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: ext.cardSecondaryColor,
              leading: Icon(Icons.add_photo_alternate_rounded, color: ext.accent),
              title: Text(
                'Add Dream to $subName',
                style: TextStyle(fontWeight: FontWeight.w700, color: ext.textPrimary),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                AddItemSheet.show(
                  context,
                  initialCategory: widget.category,
                  initialSubCategory: subName,
                );
              },
            ),
            const SizedBox(height: 8),
            // Action 2: Delete Sub-Category
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: ext.cardSecondaryColor,
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text(
                'Delete Sub-Category',
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.redAccent),
              ),
              subtitle: Text(
                'Removes $subName tag from dreams',
                style: TextStyle(fontSize: 11.5, color: ext.textMuted),
              ),
              onTap: () async {
                HapticFeedback.heavyImpact();
                Navigator.pop(sheetCtx);
                setState(() {
                  _customSubCategories.remove(subName);
                });
                await itemsProv.deleteSubCategory(widget.category, subName);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, String displayName, int count) {
    HapticFeedback.mediumImpact();
    final ext = context.ext;
    final itemsProv = context.read<ItemsProvider>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: ext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete $displayName?',
          style: TextStyle(
            color: ext.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          count > 0
              ? 'This will remove the "$displayName" collection and its $count dreams.'
              : 'Are you sure you want to remove the "$displayName" category?',
          style: TextStyle(color: ext.textMuted, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: ext.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              Navigator.pop(context);
              await itemsProv.deleteCategory(widget.category);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final themeProv = context.watch<ThemeProvider>();
    final isDark = themeProv.isDark;
    final itemsProv = context.watch<ItemsProvider>();
    final items = itemsProv.itemsByCategory(widget.category);
    final icon =
        itemsProv.categoryIcons[widget.category] ?? Icons.category_rounded;
    final displayName =
        itemsProv.categoryDisplayNames[widget.category] ?? widget.category.toUpperCase();

    // Extract subcategories from items and suggestions
    final itemSubs = items
        .map((i) => i.subCategory)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet();
    final suggestedSubs = kSuggestedSubCategories[widget.category] ?? [];
    final allSubCategories = {
      ...itemSubs,
      ...suggestedSubs,
      ..._customSubCategories,
    }.toList();

    return Scaffold(
      backgroundColor: ext.bgColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── 1. Sculpted Wave Cradle Top Header Bar ──────────────────
                  SliverToBoxAdapter(
                    child: _CategoryTopWaveBar(
                      icon: icon,
                      categoryKey: widget.category,
                      onBack: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      onDelete: () => _confirmDeleteCategory(context, displayName, items.length),
                      isDark: isDark,
                    ),
                  ),

                  // ── 2. Category Title Header ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: ext.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${items.length} ${items.length == 1 ? 'vision' : 'visions'} in collection',
                            style: TextStyle(
                              fontSize: 13,
                              color: ext.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 3. Featured Section (Category Spotlight) ─────────────────
                  if (items.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                        child: Text(
                          'Featured in $displayName',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: ext.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SpotlightCarousel(
                        items: items.where((i) => i.isSpotlight).isNotEmpty
                            ? items.where((i) => i.isSpotlight).toList()
                            : items.take(4).toList(),
                      ),
                    ),
                  ],

                  // ── 4. Sub-Categories Section (Editorial Bento Grid) ─────────
                  if (allSubCategories.isNotEmpty) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),

                    // Subcategory Bento Grid (Exact EditorialBentoGrid Cards)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, idx) {
                            final subName = allSubCategories[idx];
                            final subItems = items.where((i) => i.subCategory == subName).toList();
                            final latestSub = subItems.isNotEmpty ? subItems.first : null;

                            return _BentoSubCategoryCard(
                              title: subName,
                              itemCount: subItems.length,
                              latestItem: latestSub,
                              onLongPress: () => _showSubCategoryActions(context, subName, subItems.length),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                AddItemSheet.show(
                                  context,
                                  initialCategory: widget.category,
                                  initialSubCategory: subName,
                                );
                              },
                            );
                          },
                          childCount: allSubCategories.length,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 36)),
                  ] else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                        child: Center(
                          child: Column(
                            children: [
                              ClayIconBadge(
                                icon: icon,
                                size: 32,
                                padding: 18,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Sub-Categories in $displayName',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: ext.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap the + button below to create your first sub-category',
                                style: TextStyle(fontSize: 13, color: ext.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── 5. Sculpted Organic Wave Cradle Notch Bottom Bar ──────────────
            _CategoryBottomWaveBar(
              onHome: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              onAddSub: () => _promptAddSubCategory(context, displayName),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Exact Home Page Bento Square Card for Subcategories ───────────────────────

class _BentoSubCategoryCard extends StatefulWidget {
  final String title;
  final int itemCount;
  final OrigoItem? latestItem;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _BentoSubCategoryCard({
    required this.title,
    required this.itemCount,
    required this.latestItem,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_BentoSubCategoryCard> createState() => _BentoSubCategoryCardState();
}

class _BentoSubCategoryCardState extends State<_BentoSubCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            borderRadius: BorderRadius.circular(24),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: const Color(0xFF080912).withValues(alpha: 0.6),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.04),
                      blurRadius: 2,
                      offset: const Offset(-1, -1),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF757E9E).withValues(alpha: 0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      blurRadius: 6,
                      offset: Offset(-2, -2),
                    ),
                  ],
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
                        errorWidget: _EmptySubInvitationContent(
                          title: widget.title,
                        ),
                      ),

                      // Adaptive Ambient Scrim
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.adaptiveScrim(
                            null,
                            isDark,
                          ),
                        ),
                      ),

                      // Top right corner pill
                      if (widget.itemCount > 0)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${widget.itemCount} ${widget.itemCount == 1 ? 'Asset' : 'Assets'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),

                      // Bottom left title
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 14,
                        child: Text(
                          widget.title,
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
                : _EmptySubInvitationContent(
                    title: widget.title,
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Empty Subcategory Bento Invitation Content ────────────────────────────────

class _EmptySubInvitationContent extends StatelessWidget {
  final String title;

  const _EmptySubInvitationContent({
    required this.title,
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
                  const Color(0xFF1B1D2E),
                  const Color(0xFF131422),
                ]
              : [
                  const Color(0xFFFFFFFF),
                  const Color(0xFFE8EAF6),
                ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: ext.textPrimary,
            letterSpacing: 0.6,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── Category Top Wave Bar ─────────────────────────────────────────────────────

class _CategoryTopWaveBar extends StatelessWidget {
  final IconData icon;
  final String categoryKey;
  final VoidCallback onBack;
  final VoidCallback onDelete;
  final bool isDark;

  const _CategoryTopWaveBar({
    required this.icon,
    required this.categoryKey,
    required this.onBack,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final bgColor = ext.cardColor;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : ext.shadowDark.withValues(alpha: 0.18);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white;
    const barHeight = 64.0;

    return SizedBox(
      height: barHeight + 20,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Sculpted Custom Painted Wave Notch (Flipped for Top)
          RepaintBoundary(
            child: Transform.flip(
              flipY: true,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, barHeight + 10),
                painter: _CategoryWaveCradlePainter(
                  color: bgColor,
                  shadowColor: shadowColor,
                  highlightColor: highlightColor,
                ),
              ),
            ),
          ),

          // Top Action Buttons
          Positioned(
            top: 10,
            left: 36,
            right: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back Button (←)
                GestureDetector(
                  onTap: onBack,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 56), // Center cradle notch gap

                // Delete Category Trash Button (🗑️)
                GestureDetector(
                  onTap: onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 22,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center: Category Icon Badge
          Positioned(
            bottom: 0,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.getCategoryGradient(categoryKey),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ext.accent.withValues(alpha: isDark ? 0.5 : 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Bottom Wave Bar ──────────────────────────────────────────────────

class _CategoryBottomWaveBar extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onAddSub;
  final bool isDark;

  const _CategoryBottomWaveBar({
    required this.onHome,
    required this.onAddSub,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final bgColor = ext.cardColor;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.5)
        : ext.shadowDark.withValues(alpha: 0.22);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final barHeight = 64.0 + bottomPadding;

    return SizedBox(
      height: barHeight + 20,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Sculpted Custom Painted Wave Panel
          RepaintBoundary(
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, barHeight + 10),
              painter: _CategoryWaveCradlePainter(
                color: bgColor,
                shadowColor: shadowColor,
                highlightColor: highlightColor,
              ),
            ),
          ),

          // Bottom Action Icons
          Positioned(
            bottom: bottomPadding + 6,
            left: 36,
            right: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: Home Icon (🏠)
                GestureDetector(
                  onTap: onHome,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.home_rounded,
                      size: 26,
                      color: ext.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(width: 56), // Gap for center cradle

                // Right: Balance Spacer / Icon
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.grid_view_rounded,
                    size: 24,
                    color: ext.accent,
                  ),
                ),
              ],
            ),
          ),

          // Center: Elevated Radiant Add Sub-Category Button
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onAddSub,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: ext.primaryGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ext.accent.withValues(alpha: isDark ? 0.55 : 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Wave Cradle Painter ──────────────────────────────────────────────

class _CategoryWaveCradlePainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final Color highlightColor;

  _CategoryWaveCradlePainter({
    required this.color,
    required this.shadowColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;
    const cradleRadius = 36.0;

    final path = Path();
    path.moveTo(0, 20);

    // Top-left rounded shoulder
    path.quadraticBezierTo(0, 10, 20, 10);

    // Flat line towards left of cradle
    path.lineTo(centerX - cradleRadius - 16, 10);

    // Sculpted organic curve dropping into cradle
    path.cubicTo(
      centerX - cradleRadius - 6, 10,
      centerX - cradleRadius, 20,
      centerX - cradleRadius + 2, 28,
    );

    // Deep smooth cradle basin
    path.arcToPoint(
      Offset(centerX + cradleRadius - 2, 28),
      radius: const Radius.circular(cradleRadius),
      clockwise: false,
    );

    // Sculpted organic curve rising out of cradle
    path.cubicTo(
      centerX + cradleRadius, 20,
      centerX + cradleRadius + 6, 10,
      centerX + cradleRadius + 16, 10,
    );

    // Flat line towards right shoulder
    path.lineTo(w - 20, 10);

    // Top-right rounded shoulder
    path.quadraticBezierTo(w, 10, w, 20);

    // Down to bottom corners
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    // Draw ambient drop shadow
    canvas.drawShadow(path, shadowColor, 18.0, true);

    // Draw base fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw subtle top-rim highlight
    final strokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _CategoryWaveCradlePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.highlightColor != highlightColor;
  }
}
