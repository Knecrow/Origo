// lib/features/home/widgets/spotlight_carousel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/models/origo_item.dart';
import '../../../core/providers/items_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/frosted_glass_container.dart';
import '../../../core/widgets/origo_image.dart';
import '../../../core/utils/smooth_page_route.dart';
import '../../detail/detail_screen.dart';

class SpotlightCarousel extends StatefulWidget {
  final List<OrigoItem> items;

  const SpotlightCarousel({super.key, required this.items});

  @override
  State<SpotlightCarousel> createState() => _SpotlightCarouselState();
}

class _SpotlightCarouselState extends State<SpotlightCarousel> {
  late final PageController _controller;
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (widget.items.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_current + 1) % widget.items.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return _EmptySpotlight();
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return _SpotlightCard(item: item);
            },
          ),
        ),
        if (widget.items.length > 1) ...[
          const SizedBox(height: 12),
          _Dots(count: widget.items.length, current: _current),
        ],
      ],
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  final OrigoItem item;
  const _SpotlightCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          SmoothPageRoute(child: DetailScreen(item: item)),
        );
      },
      onLongPress: () => _showSpotlightQuickActions(context, item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: ext.cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? [
                  BoxShadow(
                    color: const Color(0xFF080912).withValues(alpha: 0.65),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(-1, -1),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF757E9E).withValues(alpha: 0.20),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 8,
                    offset: Offset(-2, -2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'dream-hero-${item.id}',
                child: OrigoImage(
                  imagePath: item.imagePath,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    color: ext.cardColor,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: ext.textMuted,
                      size: 40,
                    ),
                  ),
                ),
              ),
              // Adaptive Cinematic Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.adaptiveScrim(
                      null,
                      Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                ),
              ),
              // Labels
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: FrostedGlassContainer(
                  blur: 10,
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CategoryPill(category: item.category),
                    ],
                  ),
                ),
              ),
              // Spotlight star
              const Positioned(
                top: 12,
                right: 12,
                child: Icon(Icons.star_rounded,
                    color: Color(0xFFFFD700), size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpotlightQuickActions(BuildContext context, OrigoItem item) {
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
              title: Text(
                'Edit Dream',
                style: TextStyle(fontWeight: FontWeight.w700, color: ext.textPrimary),
              ),
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
              title: const Text(
                'Delete Dream',
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.redAccent),
              ),
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
    final subCtrl = TextEditingController(text: item.subCategory ?? '');

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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: true,
              style: TextStyle(color: ext.textPrimary),
              decoration: InputDecoration(
                labelText: 'Dream Title',
                labelStyle: TextStyle(color: ext.textMuted),
                filled: true,
                fillColor: ext.cardSecondaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subCtrl,
              style: TextStyle(color: ext.textPrimary),
              decoration: InputDecoration(
                labelText: 'Sub-Category (Optional)',
                labelStyle: TextStyle(color: ext.textMuted),
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
            onPressed: () async {
              final newTitle = titleCtrl.text.trim();
              if (newTitle.isNotEmpty) {
                HapticFeedback.mediumImpact();
                final updated = item.copyWith(
                  title: newTitle,
                  subCategory: subCtrl.text.trim(),
                );
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
}

class _CategoryPill extends StatelessWidget {
  final String category;
  const _CategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    final itemsProv = context.watch<ItemsProvider>();
    final displayName =
        itemsProv.categoryDisplayNames[category] ?? category.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int current;
  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? ext.accent : ext.textMuted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _EmptySpotlight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: ext.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, color: ext.accent, size: 36),
            const SizedBox(height: 10),
            Text(
              'No spotlight items yet',
              style: TextStyle(color: ext.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Mark items as spotlight to see them here',
              style: TextStyle(
                  color: ext.textMuted.withValues(alpha: 0.6), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
