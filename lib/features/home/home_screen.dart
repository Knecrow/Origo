// lib/features/home/home_screen.dart

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
import '../detail/detail_screen.dart';
import '../gallery/gallery_screen.dart';
import '../settings/settings_sheet.dart';
import 'widgets/editorial_bento_grid.dart';
import 'widgets/spotlight_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();
  String _searchQuery = '';
  int _activeNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemsProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _activeNavIndex = index);

    switch (index) {
      case 0: // Vision (Home)
        if (_searchQuery.isNotEmpty) {
          setState(() {
            _searchQuery = '';
            _searchCtrl.clear();
          });
        }
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        }
        break;
      case 1: // Search
        _searchFocus.requestFocus();
        break;
      case 2: // Central Add Dream
        AddItemSheet.show(context);
        break;
      case 3: // Gallery / Showcase
        final categories = context.read<ItemsProvider>().categories;
        if (categories.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GalleryScreen(category: categories.first.key),
            ),
          );
        }
        break;
      case 4: // Settings
        SettingsSheet.show(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final themeProv = context.watch<ThemeProvider>();
    final itemsProv = context.watch<ItemsProvider>();

    final spotlightItems = itemsProv.spotlightItems;
    final counts = itemsProv.categoryCounts;
    final covers = itemsProv.categoryLatestCover;
    final allItems = itemsProv.items;

    // Filter items when search query is active
    final filteredItems = _searchQuery.trim().isEmpty
        ? <OrigoItem>[]
        : allItems.where((item) {
            final q = _searchQuery.toLowerCase();
            final titleMatch = item.title.toLowerCase().contains(q);
            final catMatch = item.category.toLowerCase().contains(q);
            final subMatch = item.subCategory?.toLowerCase().contains(q) ?? false;
            final noteMatch = item.motivationNotes?.toLowerCase().contains(q) ?? false;
            return titleMatch || catMatch || subMatch || noteMatch;
          }).toList();

    final isSearching = _searchQuery.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: ext.bgColor,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── 1. Top Header Island & Search Bar ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Brand Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Origo',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: ext.textPrimary,
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: ext.textMuted.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${allItems.length} Visions',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: ext.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Theme Switcher Button
                            ClayIconBadge(
                              icon: themeProv.isDark
                                  ? Icons.wb_sunny_rounded
                                  : Icons.dark_mode_rounded,
                              size: 18,
                              padding: 9,
                              iconColor: themeProv.isDark
                                  ? const Color(0xFFFFD60A)
                                  : ext.textPrimary,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                themeProv.toggle();
                              },
                            ),
                            const SizedBox(width: 8),
                            // Quick Settings Button
                            ClayIconBadge(
                              icon: Icons.tune_rounded,
                              size: 18,
                              padding: 9,
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
                    const SizedBox(height: 16),

                    // Floating Search & Filter Capsule
                    _FloatingSearchCapsule(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      isDark: themeProv.isDark,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      onClear: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                        _searchFocus.unfocus();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── 2. Content View: Search Results OR Editorial Bento ─────────
            if (isSearching) ...[
              // Search Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Results for "$_searchQuery"',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ext.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '${filteredItems.length} found',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: ext.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (filteredItems.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClayIconBadge(
                            icon: Icons.search_off_rounded,
                            size: 32,
                            padding: 18,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No visions match "$_searchQuery"',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ext.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try searching for another keyword or category',
                            style: TextStyle(fontSize: 13, color: ext.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredItems[index];
                        return _SearchResultCard(item: item);
                      },
                      childCount: filteredItems.length,
                    ),
                  ),
                ),
            ] else ...[
              // ── Featured Section (Spotlight Carousel) ─────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                  child: Text(
                    'Featured',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
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

              // ── Categories Section Header ─────────────────────────────────
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
                          fontWeight: FontWeight.w800,
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

              // ── Dynamic Editorial Bento Grid ──────────────────────────────
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
          ],
        ),
      ),

      // ── 5-Item Floating Frosted Island Navigation Dock ────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _FloatingCeramicDock(
        activeIndex: _activeNavIndex,
        onTap: _onNavTap,
        isDark: themeProv.isDark,
      ),
    );
  }
}

// ── Floating Search & Filter Capsule ─────────────────────────────────────────

class _FloatingSearchCapsule extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _FloatingSearchCapsule({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final hasText = controller.text.isNotEmpty;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D2E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
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
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 6,
                  offset: Offset(-2, -2),
                ),
              ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ext.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search visions, collections, tags...',
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: ext.textMuted.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ext.textMuted.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: ext.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 5-Item Floating Ceramic Navigation Island Dock ───────────────────────────

class _FloatingCeramicDock extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _FloatingCeramicDock({
    required this.activeIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF181A2A).withValues(alpha: 0.94)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(36),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.06),
                  blurRadius: 2,
                  offset: const Offset(-1, -1),
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFF757E9E).withValues(alpha: 0.22),
                  blurRadius: 26,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Home / Vision Grid
          _NavDockItem(
            icon: Icons.grid_view_rounded,
            isSelected: activeIndex == 0,
            isDark: isDark,
            onTap: () => onTap(0),
          ),
          const SizedBox(width: 8),

          // 2. Search / Explore
          _NavDockItem(
            icon: Icons.search_rounded,
            isSelected: activeIndex == 1,
            isDark: isDark,
            onTap: () => onTap(1),
          ),
          const SizedBox(width: 10),

          // 3. Central Elevated Ceramic Action Button
          _CeramicActionPill(
            onTap: () => onTap(2),
            isDark: isDark,
          ),
          const SizedBox(width: 10),

          // 4. Gallery / Showcase
          _NavDockItem(
            icon: Icons.photo_library_rounded,
            isSelected: activeIndex == 3,
            isDark: isDark,
            onTap: () => onTap(3),
          ),
          const SizedBox(width: 8),

          // 5. Settings / Customize
          _NavDockItem(
            icon: Icons.tune_rounded,
            isSelected: activeIndex == 4,
            isDark: isDark,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavDockItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavDockItem({
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? const Color(0xFF7582FF).withValues(alpha: 0.18)
                  : const Color(0xFF5360ED).withValues(alpha: 0.12))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? (isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED))
              : ext.textMuted,
        ),
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
          width: 48,
          height: 48,
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

// ── Search Result Card ───────────────────────────────────────────────────────

class _SearchResultCard extends StatelessWidget {
  final OrigoItem item;

  const _SearchResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: const Color(0xFF080912).withValues(alpha: 0.55),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF757E9E).withValues(alpha: 0.16),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'dream-hero-${item.id}',
                child: OrigoImage(
                  imagePath: item.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.adaptiveScrim(null, isDark),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 6,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subCategory ?? item.category,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
