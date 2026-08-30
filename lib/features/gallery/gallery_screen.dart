// lib/features/gallery/gallery_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/origo_item.dart';
import '../../core/providers/items_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';
import '../../core/widgets/origo_image.dart';
import '../add/add_item_sheet.dart';
import '../detail/detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  final String category;
  final String? initialSubFilter;

  const GalleryScreen({super.key, required this.category, this.initialSubFilter});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _columns = 2;
  String? _selectedSubFilter;

  @override
  void initState() {
    super.initState();
    _selectedSubFilter = widget.initialSubFilter;
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final itemsProv = context.watch<ItemsProvider>();
    final items = itemsProv.itemsByCategory(widget.category);
    final icon =
        itemsProv.categoryIcons[widget.category] ?? Icons.category_rounded;
    final displayName =
        itemsProv.categoryDisplayNames[widget.category] ?? widget.category.toUpperCase();

    // Extract subcategories from items and suggestions
    final itemSubs = items
        .map((i) => i.subCategory)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet();
    final suggestedSubs = kSuggestedSubCategories[widget.category] ?? [];
    final allSubCategories = {...itemSubs, ...suggestedSubs}.toList();

    // Filter items by subcategory if selected
    final filteredItems = _selectedSubFilter == null
        ? items
        : items.where((i) => i.subCategory == _selectedSubFilter).toList();

    return Scaffold(
      backgroundColor: ext.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: ext.bgColor,
            leading: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: ClayIconBadge(
                  icon: Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  padding: 10,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClayIconBadge(
                  icon: _columns == 1
                      ? Icons.grid_view_rounded
                      : Icons.view_agenda_rounded,
                  size: 18,
                  padding: 10,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _columns = _columns == 1 ? 2 : 1);
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                children: [
                  ClayIconBadge(
                    icon: icon,
                    size: 18,
                    padding: 8,
                    gradientColors: AppColors.getCategoryGradient(widget.category),
                    badgeColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E2135)
                        : const Color(0xFFFFFFFF),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    displayName,
                    style: TextStyle(
                      color: ext.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sub-Category Filter Capsule Strip
          if (allSubCategories.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // All Chip
                      _SubCategoryPill(
                        label: 'All (${items.length})',
                        isSelected: _selectedSubFilter == null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedSubFilter = null);
                        },
                      ),
                      for (final sub in allSubCategories) ...[
                        const SizedBox(width: 8),
                        _SubCategoryPill(
                          label:
                              '$sub (${items.where((i) => i.subCategory == sub).length})',
                          isSelected: _selectedSubFilter == sub,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedSubFilter =
                                  (_selectedSubFilter == sub) ? null : sub;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          if (filteredItems.isEmpty)
            SliverFillRemaining(
              child: _EmptyGallery(
                category: widget.category,
                icon: icon,
                subFilter: _selectedSubFilter,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredItems[index];
                    return _GalleryTile(item: item);
                  },
                  childCount: filteredItems.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: _columns == 1 ? 16 / 9 : 3 / 4,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          AddItemSheet.show(context, initialCategory: widget.category);
        },
        backgroundColor: ext.textPrimary,
        icon: Icon(Icons.add_rounded, color: ext.bgColor),
        label: Text(
          'Add Dream',
          style: TextStyle(
            color: ext.bgColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SubCategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED))
              : ext.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF757E9E).withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : ext.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final OrigoItem item;

  const _GalleryTile({required this.item});

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
          borderRadius: BorderRadius.circular(22),
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
          borderRadius: BorderRadius.circular(22),
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
              // Adaptive Cinematic Ambient Scrim
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.adaptiveScrim(
                    null,
                    isDark,
                  ),
                ),
              ),

            // Top Left SubCategory Badge
            if (item.subCategory != null && item.subCategory!.isNotEmpty)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.subCategory!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

            // Spotlight Star Icon
            if (item.isSpotlight)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFD700),
                  size: 18,
                ),
              ),

            // Title & Timeframe
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
                      letterSpacing: -0.2,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.targetTimeframe != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.targetTimeframe!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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

class _EmptyGallery extends StatelessWidget {
  final String category;
  final IconData icon;
  final String? subFilter;

  const _EmptyGallery({
    required this.category,
    required this.icon,
    this.subFilter,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClayIconBadge(
            icon: icon,
            size: 42,
            padding: 22,
            gradientColors: AppColors.getCategoryGradient(category),
            badgeColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E2135)
                : const Color(0xFFFFFFFF),
          ),
          const SizedBox(height: 20),
          Text(
            subFilter != null
                ? 'No $subFilter dreams yet'
                : 'No $category dreams yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ext.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first vision',
            style: TextStyle(fontSize: 13, color: ext.textMuted),
          ),
        ],
      ),
    );
  }
}
