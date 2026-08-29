// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/items_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';
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
    final itemsProv = context.watch<ItemsProvider>();

    final spotlightItems = itemsProv.spotlightItems;
    final counts = itemsProv.categoryCounts;
    final covers = itemsProv.categoryLatestCover;

    return Scaffold(
      backgroundColor: ext.bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── 1. Top Brand Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ORIGO',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: ext.textPrimary,
                            letterSpacing: 4,
                          ),
                        ),
                        Text(
                          'DREAM PORTFOLIO',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: ext.accent,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                    // Theme Switcher Button
                    ClayIconBadge(
                      icon: themeProv.isDark
                          ? Icons.wb_sunny_rounded
                          : Icons.dark_mode_rounded,
                      size: 18,
                      padding: 10,
                      iconColor: themeProv.isDark
                          ? const Color(0xFFFFC107)
                          : const Color(0xFF5E8BB8),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        themeProv.toggle();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── 2. Spotlight Hero Carousel ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Row(
                  children: [
                    const ClayIconBadge(
                      icon: Icons.auto_awesome_rounded,
                      size: 13,
                      padding: 7,
                      iconColor: Color(0xFFFFD700),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'FEATURED SPOTLIGHT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: ext.textMuted,
                        letterSpacing: 1.8,
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

            // ── 3. Bento Grid Header ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    const ClayIconBadge(
                      icon: Icons.dashboard_customize_rounded,
                      size: 13,
                      padding: 7,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'VISION PORTFOLIO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: ext.textMuted,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${itemsProv.categories.length} CATEGORIES',
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

            // ── 4. The Dynamic Editorial Bento Grid ────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: EditorialBentoGrid(
                  categories: itemsProv.categories,
                  counts: counts,
                  covers: covers,
                ),
              ),
            ),
          ],
        ),
      ),

      // FAB
      floatingActionButton: _AnimatedFAB(
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
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        onTapCancel: () => _controller.forward(),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: ext.accent,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
