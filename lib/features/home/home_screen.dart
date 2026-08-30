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
      case 2: // Central Elevated Button (Add Dream)
        AddItemSheet.show(context);
        break;
      case 3: // Clock / History / Gallery
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
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── 1. Sculpted Wave Cradle Top Header Bar ──────────────────
                  SliverToBoxAdapter(
                    child: _SculptedWaveTopBar(
                      onToggleTheme: () => themeProv.toggle(),
                      onOpenSettings: () => SettingsSheet.show(context),
                      isDark: themeProv.isDark,
                    ),
                  ),

                  // ── 2. Content View: Search Results OR Bento Grid ─────────────
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
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
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
                    // ── Featured Section (Spotlight Carousel) ─────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
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

                    // ── Categories Section Header ─────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
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

                    // ── Dynamic Editorial Bento Grid ──────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
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

            // ── 3. Sculpted Organic Wave Cradle Notch Bottom Bar ──────────────
            _SculptedWaveBottomBar(
              activeIndex: _activeNavIndex,
              onTap: _onNavTap,
              isDark: themeProv.isDark,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sculpted Organic Wave Cradle Notch Top Bar ────────────────────────────────

class _SculptedWaveTopBar extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenSettings;
  final bool isDark;

  const _SculptedWaveTopBar({
    required this.onToggleTheme,
    required this.onOpenSettings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF141624) : const Color(0xFFFFFFFF);
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.55) : const Color(0xFF757E9E).withValues(alpha: 0.2);
    final highlightColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    const barHeight = 64.0;

    return SizedBox(
      height: barHeight + 20,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Sculpted Custom Painted Wave Panel with Center Cradle Notch
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, barHeight + 10),
            painter: _TopWaveCradlePainter(
              color: bgColor,
              shadowColor: shadowColor,
              highlightColor: highlightColor,
            ),
          ),

          // Top Bar Action Icons (Cloud & Menu)
          Positioned(
            top: 10,
            left: 36,
            right: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: Cloud / Theme Toggle Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onToggleTheme();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      isDark ? Icons.wb_sunny_rounded : Icons.cloud_outlined,
                      size: 24,
                      color: isDark ? const Color(0xFFFFD60A) : (isDark ? Colors.white70 : const Color(0xFF5360ED)),
                    ),
                  ),
                ),

                const SizedBox(width: 56), // Gap for the center cradle

                // Right: Menu Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onOpenSettings();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.menu_rounded,
                      size: 24,
                      color: isDark ? Colors.white70 : const Color(0xFF2C324A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center: Elevated Avatar Circle Button sitting directly inside the Wave Cradle Notch
          Positioned(
            top: 18,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E2135) : Colors.white,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF2B2F4C),
                          const Color(0xFF171828),
                        ]
                      : [
                          const Color(0xFFFFFFFF),
                          const Color(0xFFEFF1FA),
                        ],
                ),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color(0xFF7582FF).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFF757E9E).withValues(alpha: 0.24),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          blurRadius: 6,
                          offset: Offset(-2, -2),
                        ),
                      ],
              ),
              child: Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 24,
                  color: isDark
                      ? const Color(0xFF7582FF)
                      : const Color(0xFF5360ED),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Top Wave Cradle Painter ────────────────────────────────────────────

class _TopWaveCradlePainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final Color highlightColor;

  _TopWaveCradlePainter({
    required this.color,
    required this.shadowColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final centerX = w / 2;
    const cradleRadius = 36.0;
    const baselineY = 54.0;

    final path = Path();
    // Start at top-left
    path.moveTo(0, 0);
    path.lineTo(w, 0);

    // Right side line down to baseline
    path.lineTo(w, baselineY - 10);
    path.quadraticBezierTo(w, baselineY, w - 20, baselineY);

    // Flat line towards right edge of cradle
    path.lineTo(centerX + cradleRadius + 16, baselineY);

    // Sculpted organic curve dropping into cradle
    path.cubicTo(
      centerX + cradleRadius + 6, baselineY,
      centerX + cradleRadius, baselineY + 10,
      centerX + cradleRadius - 2, baselineY + 18,
    );

    // Deep smooth cradle basin
    path.arcToPoint(
      Offset(centerX - cradleRadius + 2, baselineY + 18),
      radius: const Radius.circular(cradleRadius),
      clockwise: false,
    );

    // Sculpted organic curve rising out of cradle
    path.cubicTo(
      centerX - cradleRadius, baselineY + 10,
      centerX - cradleRadius - 6, baselineY,
      centerX - cradleRadius - 16, baselineY,
    );

    // Flat line towards left shoulder
    path.lineTo(20, baselineY);

    // Bottom-left rounded shoulder
    path.quadraticBezierTo(0, baselineY, 0, baselineY - 10);

    // Close to top-left
    path.close();

    // Draw ambient drop shadow
    canvas.drawShadow(path, shadowColor, 18.0, true);

    // Draw base fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw subtle bottom-rim highlight
    final strokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _TopWaveCradlePainter oldDelegate) =>
      color != oldDelegate.color ||
      shadowColor != oldDelegate.shadowColor ||
      highlightColor != oldDelegate.highlightColor;
}

// ── Sculpted Organic Wave Cradle Notch Bottom Bar ─────────────────────────────

class _SculptedWaveBottomBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _SculptedWaveBottomBar({
    required this.activeIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF141624) : const Color(0xFFFFFFFF);
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.55) : const Color(0xFF757E9E).withValues(alpha: 0.2);
    final highlightColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final barHeight = 64.0 + bottomPadding;

    return SizedBox(
      height: barHeight + 20,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Sculpted Custom Painted Wave Panel with Center Cradle Notch
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, barHeight + 10),
            painter: _WaveCradlePainter(
              color: bgColor,
              shadowColor: shadowColor,
              highlightColor: highlightColor,
            ),
          ),

          // Bottom Bar Action Icons
          Positioned(
            bottom: bottomPadding + 6,
            left: 36,
            right: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: Home Icon (🏠)
                GestureDetector(
                  onTap: () => onTap(0),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.home_rounded,
                      size: 26,
                      color: activeIndex == 0
                          ? (isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED))
                          : (isDark ? Colors.white38 : const Color(0xFF8E93A6)),
                    ),
                  ),
                ),

                const SizedBox(width: 56), // Gap for the center cradle

                // Right: History / Clock Icon (⏰)
                GestureDetector(
                  onTap: () => onTap(3),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.access_time_rounded,
                      size: 24,
                      color: activeIndex == 3
                          ? (isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED))
                          : (isDark ? Colors.white38 : const Color(0xFF8E93A6)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center: Elevated Circular Button sitting directly inside the Sculpted Cradle Notch
          Positioned(
            top: 0,
            child: _CenterReferenceCircleButton(
              onTap: () => onTap(2),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Wave Cradle Painter with Sculpted Notch Path ──────────────────────

class _WaveCradlePainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final Color highlightColor;

  _WaveCradlePainter({
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

    // Top-left rounded shoulder
    path.quadraticBezierTo(0, 10, 20, 10);

    // Flat line towards left of cradle
    path.lineTo(centerX - cradleRadius - 16, 10);

    // Sculpted organic curve dropping into cradle
    path.cubicTo(
      centerX - cradleRadius - 6, 10,
      centerX - cradleRadius, 20,
      centerX - cradleRadius + 2, 28,
    );

    // Deep smooth cradle basin
    path.arcToPoint(
      Offset(centerX + cradleRadius - 2, 28),
      radius: const Radius.circular(cradleRadius),
      clockwise: false,
    );

    // Sculpted organic curve rising out of cradle
    path.cubicTo(
      centerX + cradleRadius, 20,
      centerX + cradleRadius + 6, 10,
      centerX + cradleRadius + 16, 10,
    );

    // Flat line towards right shoulder
    path.lineTo(w - 20, 10);

    // Top-right rounded shoulder
    path.quadraticBezierTo(w, 10, w, 20);

    // Down to bottom corners
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    // Draw ambient drop shadow
    canvas.drawShadow(path, shadowColor, 18.0, true);

    // Draw base fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw subtle top-rim highlight
    final strokePaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _WaveCradlePainter oldDelegate) =>
      color != oldDelegate.color ||
      shadowColor != oldDelegate.shadowColor ||
      highlightColor != oldDelegate.highlightColor;
}

class _CenterReferenceCircleButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _CenterReferenceCircleButton({
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_CenterReferenceCircleButton> createState() =>
      _CenterReferenceCircleButtonState();
}

class _CenterReferenceCircleButtonState
    extends State<_CenterReferenceCircleButton> {
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
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isDark ? const Color(0xFF1E2135) : Colors.white,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? [
                      const Color(0xFF2B2F4C),
                      const Color(0xFF171828),
                    ]
                  : [
                      const Color(0xFFFFFFFF),
                      const Color(0xFFEFF1FA),
                    ],
            ),
            boxShadow: widget.isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFF7582FF).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF757E9E).withValues(alpha: 0.24),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      blurRadius: 6,
                      offset: Offset(-2, -2),
                    ),
                  ],
          ),
          child: Center(
            child: Icon(
              Icons.sync_rounded,
              size: 26,
              color: widget.isDark
                  ? const Color(0xFF7582FF)
                  : const Color(0xFF5360ED),
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
