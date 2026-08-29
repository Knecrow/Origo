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
            // ── 1. Top Header & Segmented Capsule Toggle ──────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  children: [
                    // Brand row + Theme toggle
                    Row(
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
                          onTap: themeProv.toggle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Top Segmented Capsule Switcher [ SHOWCASE | ADD ]
                    _TopSegmentedCapsule(
                      isShowcase: isShowcase,
                      onToggleShowcase: () => showcaseProv.toggle(),
                      onTapAdd: () => AddItemSheet.show(context),
                    ),
                  ],
                ),
              ),
            ),

            // Showcase banner indicator
            if (isShowcase)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: ext.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ext.accent.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility_off_rounded,
                          color: ext.accent,
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SHOWCASE MODE ACTIVE',
                          style: TextStyle(
                            color: ext.accent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tap toggle to edit',
                          style: TextStyle(
                            color: ext.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── 2. Editorial Manifest Quote Card ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: FrostedGlassContainer(
                  blur: 16,
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: ext.accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.format_quote_rounded,
                          color: ext.accent,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '“Design a reality that demands you expand into your highest potential.”',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: ext.textPrimary.withValues(alpha: 0.88),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── 3. Spotlight Hero Carousel ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
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

            // ── 4. Bento Grid Header ───────────────────────────────────────
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

            // ── 5. The "2 – 1 – 2" Editorial Bento Grid ────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
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

      // FAB (Shown only when not in Showcase Mode)
      floatingActionButton: isShowcase
          ? null
          : _AnimatedFAB(
              onTap: () => AddItemSheet.show(context),
            ),
    );
  }
}

// ── Top Segmented Capsule Switcher ───────────────────────────────────────────

class _TopSegmentedCapsule extends StatelessWidget {
  final bool isShowcase;
  final VoidCallback onToggleShowcase;
  final VoidCallback onTapAdd;

  const _TopSegmentedCapsule({
    required this.isShowcase,
    required this.onToggleShowcase,
    required this.onTapAdd,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151C26) : const Color(0xFFDCE5EE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ext.shadowLight,
            offset: const Offset(-3, -3),
            blurRadius: 8,
          ),
          BoxShadow(
            color: ext.shadowDark,
            offset: const Offset(3, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // SHOWCASE Button (Toggle)
          Expanded(
            child: GestureDetector(
              onTap: onToggleShowcase,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isShowcase
                      ? (isDark ? Colors.white : ext.accent)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isShowcase
                      ? [
                          BoxShadow(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.25)
                                : ext.accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isShowcase
                            ? Icons.visibility_rounded
                            : Icons.slideshow_rounded,
                        size: 14,
                        color: isShowcase
                            ? (isDark ? const Color(0xFF0E1621) : Colors.white)
                            : ext.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SHOWCASE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: isShowcase
                              ? (isDark
                                  ? const Color(0xFF0E1621)
                                  : Colors.white)
                              : ext.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ADD Button
          Expanded(
            child: GestureDetector(
              onTap: onTapAdd,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: ext.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ADD DREAM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: ext.textMuted,
                        ),
                      ),
                    ],
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
          width: 58,
          height: 58,
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
