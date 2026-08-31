// lib/features/gallery/sub_category_view_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/origo_item.dart';
import '../../core/providers/items_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/smooth_page_route.dart';
import '../../core/widgets/origo_image.dart';
import '../add/add_item_sheet.dart';
import '../detail/detail_screen.dart';

class SubCategoryViewScreen extends StatefulWidget {
  final String category;
  final String subCategory;

  const SubCategoryViewScreen({
    super.key,
    required this.category,
    required this.subCategory,
  });

  @override
  State<SubCategoryViewScreen> createState() => _SubCategoryViewScreenState();
}

class _SubCategoryViewScreenState extends State<SubCategoryViewScreen> {
  void _promptAddPhoto() {
    HapticFeedback.lightImpact();
    AddItemSheet.show(
      context,
      initialCategory: widget.category,
      initialSubCategory: widget.subCategory,
    );
  }

  void _showItemQuickActions(BuildContext context, OrigoItem item) {
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
              item.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ext.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Action 1: Edit Dream
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: ext.cardSecondaryColor,
              leading: Icon(Icons.edit_rounded, color: ext.accent),
              title: Text('Edit Dream', style: TextStyle(fontWeight: FontWeight.w700, color: ext.textPrimary)),
              onTap: () {
                Navigator.pop(sheetCtx);
                _promptEditDream(context, item);
              },
            ),
            const SizedBox(height: 8),
            // Action 2: Toggle Spotlight
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: ext.cardSecondaryColor,
              leading: Icon(
                item.isSpotlight ? Icons.star_rounded : Icons.star_border_rounded,
                color: item.isSpotlight ? const Color(0xFFFFD700) : ext.textPrimary,
              ),
              title: Text(
                item.isSpotlight ? 'Remove from Spotlight' : 'Pin to Spotlight',
                style: TextStyle(fontWeight: FontWeight.w700, color: ext.textPrimary),
              ),
              onTap: () async {
                HapticFeedback.lightImpact();
                Navigator.pop(sheetCtx);
                await itemsProv.toggleSpotlight(item);
              },
            ),
            const SizedBox(height: 8),
            // Action 3: Delete Dream
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: ext.cardSecondaryColor,
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text('Delete Dream', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.redAccent)),
              onTap: () async {
                HapticFeedback.heavyImpact();
                Navigator.pop(sheetCtx);
                await itemsProv.deleteItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _promptEditDream(BuildContext context, OrigoItem item) {
    HapticFeedback.lightImpact();
    final ext = context.ext;
    final titleCtrl = TextEditingController(text: item.title);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: ext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Edit Dream',
          style: TextStyle(
            color: ext.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: titleCtrl,
          autofocus: true,
          style: TextStyle(color: ext.textPrimary),
          decoration: InputDecoration(
            hintText: 'Dream Title',
            filled: true,
            fillColor: ext.cardSecondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: ext.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = titleCtrl.text.trim();
              if (newTitle.isNotEmpty) {
                HapticFeedback.mediumImpact();
                final updated = item.copyWith(title: newTitle);
                await context.read<ItemsProvider>().updateItem(updated);
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ext.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Save'),
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
    final icon = itemsProv.categoryIcons[widget.category] ?? Icons.category_rounded;

    final subItems = itemsProv.items
        .where((i) =>
            i.category.toLowerCase() == widget.category.toLowerCase() &&
            i.subCategory?.toLowerCase() == widget.subCategory.toLowerCase())
        .toList();

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
                  // ── 1. Sculpted Wave Top Header Bar ───────────────────────────
                  SliverToBoxAdapter(
                    child: _SubTopWaveBar(
                      icon: icon,
                      categoryKey: widget.category,
                      onBack: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      isDark: isDark,
                    ),
                  ),

                  // ── 2. Subcategory Header Title ──────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subCategory,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: ext.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${subItems.length} ${subItems.length == 1 ? 'vision' : 'visions'} in collection',
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

                  // ── 3. Photos Grid ───────────────────────────────────────────
                  if (subItems.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.95,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = subItems[index];
                            return _SubPhotoCard(
                              item: item,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  SmoothPageRoute(child: DetailScreen(item: item)),
                                );
                              },
                              onLongPress: () => _showItemQuickActions(context, item),
                            );
                          },
                          childCount: subItems.length,
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                        child: Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _promptAddPhoto,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: ext.primaryGradient),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ext.accent.withValues(alpha: 0.4),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'No Photos in ${widget.subCategory}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: ext.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap to add your first photo to this collection',
                                style: TextStyle(fontSize: 13, color: ext.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── 4. Sculpted Bottom Wave Bar with Photo Adder Button ───────────
            _SubBottomWaveBar(
              onHome: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              onAddPhoto: _promptAddPhoto,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photo Grid Card ───────────────────────────────────────────────────────────

class _SubPhotoCard extends StatefulWidget {
  final OrigoItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _SubPhotoCard({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_SubPhotoCard> createState() => _SubPhotoCardState();
}

class _SubPhotoCardState extends State<_SubPhotoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'dream-hero-${widget.item.id}',
                  child: OrigoImage(
                    imagePath: widget.item.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),

                // Adaptive Ambient Scrim
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.adaptiveScrim(null, isDark),
                  ),
                ),

                // Spotlight Star Indicator
                if (widget.item.isSpotlight)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 20),
                  ),

                // Bottom Left Title
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Text(
                    widget.item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      height: 1.25,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2)),
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

// ── Subcategory Top Wave Bar ──────────────────────────────────────────────────

class _SubTopWaveBar extends StatelessWidget {
  final IconData icon;
  final String categoryKey;
  final VoidCallback onBack;
  final bool isDark;

  const _SubTopWaveBar({
    required this.icon,
    required this.categoryKey,
    required this.onBack,
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
          // Sculpted Custom Painted Wave Notch
          RepaintBoundary(
            child: Transform.flip(
              flipY: true,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, barHeight + 10),
                painter: _SubWaveCradlePainter(
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
              children: [
                // Back Button
                GestureDetector(
                  onTap: onBack,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  ),
                ),

                const SizedBox(width: 56),

                // Invisible spacer for balance
                const SizedBox(width: 44),
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
                child: Icon(icon, size: 26, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subcategory Bottom Wave Bar ───────────────────────────────────────────────

class _SubBottomWaveBar extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onAddPhoto;
  final bool isDark;

  const _SubBottomWaveBar({
    required this.onHome,
    required this.onAddPhoto,
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
          // Sculpted Wave Panel
          RepaintBoundary(
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, barHeight + 10),
              painter: _SubWaveCradlePainter(
                color: bgColor,
                shadowColor: shadowColor,
                highlightColor: highlightColor,
              ),
            ),
          ),

          // Action Icons
          Positioned(
            bottom: bottomPadding + 6,
            left: 36,
            right: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Home Icon
                GestureDetector(
                  onTap: onHome,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.home_rounded, size: 26, color: ext.textPrimary),
                  ),
                ),

                const SizedBox(width: 56),

                // Right: Grid Icon
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.grid_view_rounded, size: 24, color: ext.accent),
                ),
              ],
            ),
          ),

          // Center: Elevated Photo Adder Button
          Positioned(
            top: 0,
            child: _CenterAddPhotoButton(
              onTap: onAddPhoto,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterAddPhotoButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _CenterAddPhotoButton({
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_CenterAddPhotoButton> createState() => _CenterAddPhotoButtonState();
}

class _CenterAddPhotoButtonState extends State<_CenterAddPhotoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;

    return AnimatedScale(
      scale: _pressed ? 0.90 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: ext.primaryGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: ext.accent.withValues(alpha: widget.isDark ? 0.55 : 0.45),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.add_a_photo_rounded,
              size: 26,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub Wave Cradle Painter ───────────────────────────────────────────────────

class _SubWaveCradlePainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final Color highlightColor;

  _SubWaveCradlePainter({
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

    path.quadraticBezierTo(0, 10, 20, 10);
    path.lineTo(centerX - cradleRadius - 16, 10);

    path.cubicTo(
      centerX - cradleRadius - 6, 10,
      centerX - cradleRadius, 20,
      centerX - cradleRadius + 2, 28,
    );

    path.arcToPoint(
      Offset(centerX + cradleRadius - 2, 28),
      radius: const Radius.circular(cradleRadius),
      clockwise: false,
    );

    path.cubicTo(
      centerX + cradleRadius, 20,
      centerX + cradleRadius + 6, 10,
      centerX + cradleRadius + 16, 10,
    );

    path.lineTo(w - 20, 10);
    path.quadraticBezierTo(w, 10, w, 20);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawShadow(path, shadowColor, 18.0, true);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SubWaveCradlePainter oldDelegate) => false;
}
