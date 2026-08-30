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
                padding: const EdgeInsets.only(bottom: 120),
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

      // ── Floating Ceramic Island Dock ──────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _FloatingCeramicDock(
        onAdd: () => AddItemSheet.show(context),
        onSettings: () => SettingsSheet.show(context),
        onToggleTheme: () => themeProv.toggle(),
        isDark: themeProv.isDark,
      ),
    );
  }
}

class _FloatingCeramicDock extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onSettings;
  final VoidCallback onToggleTheme;
  final bool isDark;

  const _FloatingCeramicDock({
    required this.onAdd,
    required this.onSettings,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF181A2A).withValues(alpha: 0.92)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(36),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 24,
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
                  color: const Color(0xFF757E9E).withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 8,
                  offset: Offset(-2, -2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Theme Toggle
          ClayIconBadge(
            icon: isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
            size: 19,
            padding: 8,
            iconColor: isDark ? const Color(0xFFFFD60A) : ext.textPrimary,
            onTap: onToggleTheme,
          ),
          const SizedBox(width: 14),

          // Central Embossed Ceramic Add Button
          _CeramicActionPill(
            onTap: onAdd,
            isDark: isDark,
          ),
          const SizedBox(width: 14),

          // Settings Button
          ClayIconBadge(
            icon: Icons.tune_rounded,
            size: 19,
            padding: 8,
            iconColor: ext.textPrimary,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _CeramicActionPill extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _CeramicActionPill({
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_CeramicActionPill> createState() => _CeramicActionPillState();
}

class _CeramicActionPillState extends State<_CeramicActionPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? [
                      const Color(0xFF8B96FF),
                      const Color(0xFF5E6BEE),
                    ]
                  : [
                      const Color(0xFF6371F8),
                      const Color(0xFF4350E0),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5360ED).withValues(alpha: 0.45),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
              const BoxShadow(
                color: Colors.white24,
                blurRadius: 4,
                offset: Offset(-1, -1),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
