// lib/features/gallery/gallery_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/origo_item.dart';
import '../../core/providers/items_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';
import '../../core/widgets/origo_image.dart';
import '../add/add_item_sheet.dart';
import '../detail/detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  final String category;

  const GalleryScreen({super.key, required this.category});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _columns = 2;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final itemsProv = context.watch<ItemsProvider>();
    final items = itemsProv.itemsByCategory(widget.category);
    final accentColor = ext.accent;
    final icon =
        itemsProv.categoryIcons[widget.category] ?? Icons.category_rounded;
    final displayName =
        itemsProv.categoryDisplayNames[widget.category] ?? widget.category.toUpperCase();

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
                    size: 16,
                    padding: 8,
                    iconColor: Colors.white,
                    badgeColor: accentColor,
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

          if (items.isEmpty)
            SliverFillRemaining(
              child: _EmptyGallery(
                category: widget.category,
                icon: icon,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return _GalleryTile(item: item);
                  },
                  childCount: items.length,
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
        backgroundColor: accentColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Dream',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700),
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
    final ext = context.ext;

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
          color: ext.cardColor,
          borderRadius: BorderRadius.circular(20),
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
                  errorWidget: Container(
                    color: ext.cardColor,
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: ext.textMuted,
                    ),
                  ),
                ),
              ),
              // Gradient
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
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Spotlight star
              if (item.isSpotlight)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.star_rounded,
                      color: Color(0xFFFFD700), size: 18),
                ),
              // Title
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

  const _EmptyGallery({
    required this.category,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClayIconBadge(icon: icon, size: 40, padding: 20, iconColor: ext.accent),
          const SizedBox(height: 20),
          Text(
            'No $category items yet',
            style:
                TextStyle(color: ext.textPrimary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first dream',
            style: TextStyle(color: ext.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
