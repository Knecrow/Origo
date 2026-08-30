// lib/features/home/widgets/card_quick_actions_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/models/origo_category.dart';
import '../../../core/providers/items_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_icon_badge.dart';
import '../../add/add_item_sheet.dart';
import '../../gallery/gallery_screen.dart';

class CardQuickActionsSheet extends StatelessWidget {
  final OrigoCategory category;
  final int itemCount;

  const CardQuickActionsSheet({
    super.key,
    required this.category,
    required this.itemCount,
  });

  static Future<void> show(
    BuildContext context, {
    required OrigoCategory category,
    required int itemCount,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CardQuickActionsSheet(
        category: category,
        itemCount: itemCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final isBuiltin = OrigoCategory.defaultCategories
        .any((d) => d.key.toLowerCase() == category.key.toLowerCase());

    return Container(
      decoration: BoxDecoration(
        color: ext.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ext.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              ClayIconBadge(
                icon: category.icon,
                size: 20,
                padding: 10,
                iconColor: ext.textPrimary,
                badgeColor: ext.bgColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: ext.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: ext.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action 1: Add Dream
          _ActionTile(
            icon: Icons.add_photo_alternate_rounded,
            iconColor: ext.accent,
            title: 'Add Dream to ${category.displayName}',
            subtitle: 'Capture a new aspiration for this category',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              AddItemSheet.show(context, initialCategory: category.key);
            },
          ),
          const SizedBox(height: 10),

          // Action 2: View Gallery
          _ActionTile(
            icon: Icons.grid_view_rounded,
            iconColor: ext.textPrimary,
            title: 'Open Full Gallery',
            subtitle: 'Browse all dreams and visual inspirations',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GalleryScreen(category: category.key),
                ),
              );
            },
          ),

          // Action 3: Delete (if custom or user created)
          if (!isBuiltin) ...[
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.error,
              title: 'Delete Category',
              subtitle: 'Remove category and all associated assets',
              isDestructive: true,
              onTap: () async {
                HapticFeedback.mediumImpact();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: ctx.ext.cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: const Text('Delete Category',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    content: Text(
                        'Are you sure you want to delete "${category.displayName}" and all its assets?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancel',
                            style: TextStyle(color: ctx.ext.textMuted)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await context
                      .read<ItemsProvider>()
                      .deleteCategory(category.key);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ext.bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.12)
                    : ext.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDestructive ? AppColors.error : ext.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: ext.textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: ext.textMuted.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
