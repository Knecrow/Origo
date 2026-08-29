// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/items_provider.dart';
import '../../core/providers/showcase_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';
import '../../core/widgets/frosted_glass_container.dart';
import '../add/add_item_sheet.dart';
import 'widgets/editorial_bento_grid.dart';
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
            // ── 1. Header ──────────────────────────────────────────────────
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
                          'VISION PORTFOLIO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
                          'Tap eye to exit',
                          style: TextStyle(
                              color: ext.textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── 2. Editorial Manifest Quote Card ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                child: FrostedGlassContainer(
                  blur: 16,
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ext.accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.format_quote_rounded,
                          color: ext.accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DAILY MANIFEST',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: ext.accent,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '“Design a reality that demands you expand into your highest potential.”',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                                color: ext.textPrimary.withValues(alpha: 0.9),
                                height: 1.35,
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

            // ── 3. Spotlight Section ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                child: Row(
                  children: [
                    const ClayIconBadge(
                      icon: Icons.auto_awesome_rounded,
                      size: 14,
                      padding: 8,
                      iconColor: Color(0xFFFFD700),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'CURATED SPOTLIGHT',
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

            // ── 4. Editorial Bento Grid Section ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
                child: Row(
                  children: [
                    const ClayIconBadge(
                      icon: Icons.dashboard_customize_rounded,
                      size: 14,
                      padding: 8,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'COLLECTIONS BENTO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: ext.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '6 CATEGORIES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: ext.textMuted.withValues(alpha: 0.6),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Asymmetric Bento Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 110),
                child: EditorialBentoGrid(
                  counts: counts,
                  covers: covers,
                  isShowcase: isShowcase,
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
