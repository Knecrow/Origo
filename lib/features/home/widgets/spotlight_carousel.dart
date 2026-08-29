// lib/features/home/widgets/spotlight_carousel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/origo_item.dart';
import '../../../core/providers/items_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/frosted_glass_container.dart';
import '../../../core/widgets/origo_image.dart';
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: ext.cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              OrigoImage(
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
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      stops: const [0.4, 1.0],
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
}

class _CategoryPill extends StatelessWidget {
  final String category;
  const _CategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final itemsProv = context.watch<ItemsProvider>();
    final displayName =
        itemsProv.categoryDisplayNames[category] ?? category.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ext.accent.withValues(alpha: 0.85),
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
