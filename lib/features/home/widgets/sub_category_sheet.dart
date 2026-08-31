// lib/features/home/widgets/sub_category_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/models/origo_category.dart';
import '../../../core/models/origo_item.dart';
import '../../../core/providers/items_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_icon_badge.dart';
import '../../../core/widgets/origo_image.dart';
import '../../add/add_item_sheet.dart';
import '../../gallery/gallery_screen.dart';

class SubCategorySheet extends StatefulWidget {
  final OrigoCategory category;

  const SubCategorySheet({super.key, required this.category});

  static Future<void> show(BuildContext context, {required OrigoCategory category}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubCategorySheet(category: category),
    );
  }

  @override
  State<SubCategorySheet> createState() => _SubCategorySheetState();
}

class _SubCategorySheetState extends State<SubCategorySheet> {
  final List<String> _customSubCategories = [];

  void _promptAddSubCategory(BuildContext context) {
    HapticFeedback.lightImpact();
    final ext = context.ext;
    final textCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: ext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'New Sub-Category',
          style: TextStyle(
            color: ext.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add a sub-category under ${widget.category.displayName} (e.g. Electric, Classics, Superbikes)',
              style: TextStyle(color: ext.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textCtrl,
              autofocus: true,
              style: TextStyle(color: ext.textPrimary),
              decoration: InputDecoration(
                hintText: 'Sub-Category Name',
                filled: true,
                fillColor: ext.bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: ext.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = textCtrl.text.trim();
              if (val.isNotEmpty) {
                HapticFeedback.mediumImpact();
                setState(() {
                  if (!_customSubCategories.contains(val)) {
                    _customSubCategories.add(val);
                  }
                });
                Navigator.pop(dialogCtx);
                // Open Add Dream sheet directly for this newly created sub-category
                AddItemSheet.show(
                  context,
                  initialCategory: widget.category.key,
                  initialSubCategory: val,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ext.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Add & Create Dream'),
          ),
        ],
      ),
    );
  }

  void _showSubCategoryActions(BuildContext context, String subName, int count) {
    HapticFeedback.mediumImpact();
    final ext = context.ext;
    final itemsProv = context.read<ItemsProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: ext.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ext.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ext.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count dreams in this sub-category',
              style: TextStyle(fontSize: 12.5, color: ext.textMuted),
            ),
            const SizedBox(height: 20),

            // Action 1: View Gallery
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: ext.bgColor,
              leading: Icon(Icons.grid_view_rounded, color: ext.accent),
              title: Text(
                'View Gallery',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ext.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GalleryScreen(
                      category: widget.category.key,
                      initialSubFilter: subName,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            // Action 2: Add Dream
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: ext.bgColor,
              leading: Icon(Icons.add_photo_alternate_rounded, color: ext.accent),
              title: Text(
                'Add Dream to $subName',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ext.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.pop(context);
                AddItemSheet.show(
                  context,
                  initialCategory: widget.category.key,
                  initialSubCategory: subName,
                );
              },
            ),
            const SizedBox(height: 8),

            // Action 3: Delete Sub-Category
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: ext.bgColor,
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text(
                'Delete Sub-Category',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
              ),
              subtitle: Text(
                'Removes $subName tag from dreams',
                style: TextStyle(fontSize: 11.5, color: ext.textMuted),
              ),
              onTap: () async {
                HapticFeedback.heavyImpact();
                Navigator.pop(sheetCtx);
                setState(() {
                  _customSubCategories.remove(subName);
                });
                await itemsProv.deleteSubCategory(widget.category.key, subName);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemsProv = context.watch<ItemsProvider>();
    final items = itemsProv.itemsByCategory(widget.category.key);

    // Extract all unique sub-categories
    final itemSubs = items
        .map((i) => i.subCategory)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet();
    final suggestedSubs = kSuggestedSubCategories[widget.category.key] ?? [];
    final allSubCategories = {
      ...itemSubs,
      ...suggestedSubs,
      ..._customSubCategories,
    }.toList();

    return Container(
      decoration: BoxDecoration(
        color: ext.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: ext.shadowDark.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ext.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header Row (Clean, no generic Add button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  ClayIconBadge(
                    icon: widget.category.icon,
                    size: 22,
                    padding: 10,
                    gradientColors: AppColors.getCategoryGradient(widget.category.key),
                    badgeColor: isDark ? const Color(0xFF1E2135) : const Color(0xFFFFFFFF),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.displayName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: ext.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${items.length} ${items.length == 1 ? 'dream' : 'dreams'} in collection',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: ext.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          backgroundColor: ext.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          title: Text(
                            'Delete ${widget.category.displayName}?',
                            style: TextStyle(
                              color: ext.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          content: Text(
                            items.isNotEmpty
                                ? 'This will remove the "${widget.category.displayName}" collection and its ${items.length} dreams.'
                                : 'Are you sure you want to remove the "${widget.category.displayName}" category?',
                            style: TextStyle(color: ext.textMuted, fontSize: 13.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx, false),
                              child: Text('Cancel', style: TextStyle(color: ext.textMuted)),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dialogCtx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        Navigator.pop(context);
                        await itemsProv.deleteCategory(widget.category.key);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ext.textMuted.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: ext.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sub-Category Cards Grid
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemCount: allSubCategories.length + 1, // Sub-categories + "+ Add Sub-Category"
              itemBuilder: (context, idx) {
                if (idx == allSubCategories.length) {
                  // "+ Add Sub-Category" Action Card
                  return _AddSubCategoryCard(
                    onTap: () => _promptAddSubCategory(context),
                  );
                }

                final subName = allSubCategories[idx];
                final subItems = items.where((i) => i.subCategory == subName).toList();
                final latestSub = subItems.isNotEmpty ? subItems.first : null;

                return _SubCategoryCard(
                  title: subName,
                  count: subItems.length,
                  latestItem: latestSub,
                  icon: widget.category.icon,
                  categoryKey: widget.category.key,
                  categoryColor: widget.category.color,
                  onLongPress: () => _showSubCategoryActions(context, subName, subItems.length),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    if (subItems.isEmpty) {
                      AddItemSheet.show(
                        context,
                        initialCategory: widget.category.key,
                        initialSubCategory: subName,
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GalleryScreen(
                            category: widget.category.key,
                            initialSubFilter: subName,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubCategoryCard extends StatefulWidget {
  final String title;
  final int count;
  final OrigoItem? latestItem;
  final IconData icon;
  final String categoryKey;
  final Color categoryColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _SubCategoryCard({
    required this.title,
    required this.count,
    required this.latestItem,
    required this.icon,
    required this.categoryKey,
    required this.categoryColor,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_SubCategoryCard> createState() => _SubCategoryCardState();
}

class _SubCategoryCardState extends State<_SubCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final hasImage = widget.latestItem != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: ext.cardSecondaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: const Color(0xFF080912).withValues(alpha: 0.5),
                      blurRadius: 12,
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
                      color: const Color(0xFF757E9E).withValues(alpha: 0.14),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      blurRadius: 6,
                      offset: Offset(-2, -2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      OrigoImage(
                        imagePath: widget.latestItem!.imagePath,
                        fit: BoxFit.cover,
                      ),
                      // Adaptive Ambient Scrim
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.adaptiveScrim(
                            null,
                            isDark,
                          ),
                        ),
                      ),
                      // Content
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.count} ${widget.count == 1 ? 'dream' : 'dreams'}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF1B1D2E),
                                const Color(0xFF131422),
                              ]
                            : [
                                const Color(0xFFFFFFFF),
                                const Color(0xFFE8EAF6),
                              ],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClayIconBadge(
                          icon: widget.icon,
                          size: 20,
                          padding: 8,
                          gradientColors: AppColors.getCategoryGradient(widget.categoryKey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: ext.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.count} dreams',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: ext.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _AddSubCategoryCard extends StatefulWidget {
  final VoidCallback onTap;

  const _AddSubCategoryCard({required this.onTap});

  @override
  State<_AddSubCategoryCard> createState() => _AddSubCategoryCardState();
}

class _AddSubCategoryCardState extends State<_AddSubCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: ext.bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ext.textMuted.withValues(alpha: 0.18),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: ext.accent,
                  size: 26,
                ),
                const SizedBox(height: 6),
                Text(
                  'New Sub-Category',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: ext.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
