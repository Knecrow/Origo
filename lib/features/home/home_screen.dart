// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/items_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';
import '../add/add_item_sheet.dart';
import '../settings/settings_sheet.dart';
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
            // ── 1. Top Navigation Bar (Apple Large Title) ───────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Origo',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: ext.textPrimary,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    ),
                    Row(
                      children: [
                        // Theme Switcher Button
                        ClayIconBadge(
                          icon: themeProv.isDark
                              ? Icons.wb_sunny_rounded
                              : Icons.dark_mode_rounded,
                          size: 18,
                          padding: 10,
                          iconColor: themeProv.isDark
                              ? const Color(0xFFFFD60A)
                              : ext.textPrimary,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            themeProv.toggle();
                          },
                        ),
                        const SizedBox(width: 8),
                        // Settings Button
                        ClayIconBadge(
                          icon: Icons.tune_rounded,
                          size: 18,
                          padding: 10,
                          iconColor: ext.textPrimary,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            SettingsSheet.show(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── 2. Featured Section (Apple Photos Spotlight) ───────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Featured',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ext.textPrimary,
                    letterSpacing: -0.4,
                  ),
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

            // ── 3. Categories Section Header ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ext.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      '${itemsProv.categories.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ext.textMuted,
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

      // Floating Action Button
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
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ext.accent,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
