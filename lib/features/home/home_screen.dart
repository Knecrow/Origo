// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/origo_item.dart';
import '../../core/providers/items_provider.dart';
import '../../core/providers/showcase_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';
import '../add/add_item_sheet.dart';
import '../gallery/gallery_screen.dart';
import 'widgets/category_card.dart';
import 'widgets/spotlight_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemsProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final themeProv = context.watch<ThemeProvider>();
    final showcaseProv = context.watch<ShowcaseProvider>();
    final itemsProv = context.watch<ItemsProvider>();

    final spotlightItems = itemsProv.spotlightItems;
    final counts = itemsProv.categoryCounts;
    final covers = itemsProv.categoryLatestCover;
    final isShowcase = showcaseProv.isActive;

    return Scaffold(
      backgroundColor: ext.bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo/Title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ORIGO',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: ext.textPrimary,
                            letterSpacing: 4,
                          ),
                        ),
                        Text(
                          'VISION BOARD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: ext.accent,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Showcase toggle
                    ClayIconBadge(
                      icon: isShowcase
                          ? Icons.visibility_off_rounded
                          : Icons.slideshow_rounded,
                      size: 20,
                      padding: 12,
                      iconColor: isShowcase
                          ? ext.accent
                          : ext.textMuted,
                      onTap: showcaseProv.toggle,
                    ),
                    const SizedBox(width: 12),
                    // Theme toggle
                    ClayIconBadge(
                      icon: themeProv.isDark
                          ? Icons.wb_sunny_rounded
                          : Icons.dark_mode_rounded,
                      size: 20,
                      padding: 12,
                      iconColor: themeProv.isDark
                          ? const Color(0xFFFFC107)
                          : const Color(0xFF5E8BB8),
                      onTap: themeProv.toggle,
                    ),
                  ],
                ),
              ),
            ),

            // Showcase banner
            if (isShowcase)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: ext.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: ext.accent.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.slideshow_rounded,
                            color: ext.accent, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'SHOWCASE MODE',
                          style: TextStyle(
                            color: ext.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tap eye icon to exit',
                          style: TextStyle(
                              color: ext.textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Spotlight Section ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    ClayIconBadge(
                      icon: Icons.auto_awesome_rounded,
                      size: 14,
                      padding: 8,
                      iconColor: const Color(0xFFFFD700),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'SPOTLIGHT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: ext.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: itemsProv.loading
                  ? const SizedBox(
                      height: 240,
                      child: Center(child: CircularProgressIndicator()))
                  : SpotlightCarousel(items: spotlightItems),
            ),

            // ── Category Section ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    ClayIconBadge(
                      icon: Icons.grid_view_rounded,
                      size: 14,
                      padding: 8,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'CATEGORIES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: ext.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cat = kCategories[index];
                    return CategoryCard(
                      category: cat,
                      itemCount: counts[cat] ?? 0,
                      latestItem: covers[cat],
                      showCount: !isShowcase,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GalleryScreen(category: cat),
                        ),
                      ),
                    );
                  },
                  childCount: kCategories.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),

      // FAB
      floatingActionButton: isShowcase
          ? null
          : _AnimatedFAB(
              onTap: () => AddItemSheet.show(context),
            ),
    );
  }
}

class _AnimatedFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedFAB({required this.onTap});

  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _controller.reverse(),
        onTapUp: (_) {
          _controller.forward();
          widget.onTap();
        },
        onTapCancel: () => _controller.forward(),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: ext.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ext.accent.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
