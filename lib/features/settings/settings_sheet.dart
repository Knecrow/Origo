// lib/features/settings/settings_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/origo_category.dart';
import '../../core/providers/items_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';
import '../add/add_category_sheet.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final themeProv = context.watch<ThemeProvider>();
    final itemsProv = context.watch<ItemsProvider>();

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
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 18),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: ext.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ext.cardSecondaryColor,
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
            const SizedBox(height: 24),

            // ── Section 1: Appearance ─────────────────────────────────────────
            _SectionHeader(title: 'APPEARANCE'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: ext.cardSecondaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClayIconBadge(
                        icon: themeProv.isDark
                            ? Icons.dark_mode_rounded
                            : Icons.wb_sunny_rounded,
                        size: 18,
                        padding: 8,
                        iconColor: themeProv.isDark
                            ? const Color(0xFFFFD60A)
                            : ext.textPrimary,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: ext.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            themeProv.isDark ? 'OLED True Black' : 'Porcelain White',
                            style: TextStyle(
                              fontSize: 12,
                              color: ext.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: themeProv.isDark,
                    activeTrackColor: ext.accent,
                    onChanged: (_) {
                      HapticFeedback.selectionClick();
                      themeProv.toggle();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 2: Categories & Vision ──────────────────────────────
            _SectionHeader(title: 'ORGANIZATION'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: ext.cardSecondaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _SettingsActionTile(
                    icon: Icons.tune_rounded,
                    title: 'Manage & Delete Categories',
                    subtitle: 'View, add, or delete any collection',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showManageCategoriesModal(context, itemsProv);
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 52,
                    color: ext.textMuted.withValues(alpha: 0.1),
                  ),
                  _SettingsActionTile(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Add Custom Category',
                    subtitle: 'Create bespoke category with custom icon',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      AddCategorySheet.show(context);
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 52,
                    color: ext.textMuted.withValues(alpha: 0.1),
                  ),
                  _SettingsInfoTile(
                    icon: Icons.dashboard_customize_rounded,
                    title: 'Total Active Categories',
                    value: '${itemsProv.categories.length}',
                  ),
                  Divider(
                    height: 1,
                    indent: 52,
                    color: ext.textMuted.withValues(alpha: 0.1),
                  ),
                  _SettingsInfoTile(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Total Dreams Collected',
                    value: '${itemsProv.items.length}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 3: Data Management ──────────────────────────────────
            _SectionHeader(title: 'DATA & STORAGE'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: ext.cardSecondaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _SettingsActionTile(
                    icon: Icons.restart_alt_rounded,
                    iconColor: ext.accent,
                    title: 'Reset to Curated Showcase',
                    subtitle: 'Restore default sample dreams and categories',
                    onTap: () => _confirmResetToDefaults(context, itemsProv),
                  ),
                  Divider(
                    height: 1,
                    indent: 52,
                    color: ext.textMuted.withValues(alpha: 0.1),
                  ),
                  _SettingsActionTile(
                    icon: Icons.delete_sweep_rounded,
                    iconColor: AppColors.error,
                    title: 'Clear All Dreams',
                    subtitle: 'Erase all aspirations and start fresh with blank canvas',
                    isDestructive: true,
                    onTap: () => _confirmClearAll(context, itemsProv),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 4: About ─────────────────────────────────────────────
            _SectionHeader(title: 'ABOUT'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: ext.bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _SettingsInfoTile(
                    icon: Icons.info_outline_rounded,
                    title: 'App Name',
                    value: 'Origo',
                  ),
                  Divider(
                    height: 1,
                    indent: 52,
                    color: ext.textMuted.withValues(alpha: 0.1),
                  ),
                  _SettingsInfoTile(
                    icon: Icons.verified_rounded,
                    title: 'Version',
                    value: '1.0.0 (Release)',
                  ),
                  Divider(
                    height: 1,
                    indent: 52,
                    color: ext.textMuted.withValues(alpha: 0.1),
                  ),
                  _SettingsInfoTile(
                    icon: Icons.code_rounded,
                    title: 'Architecture',
                    value: 'Offline SQLite & Web',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageCategoriesModal(BuildContext context, ItemsProvider itemsProv) {
    final ext = context.ext;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final categories = itemsProv.categories;

            return Container(
              decoration: BoxDecoration(
                color: ext.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 24,
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
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Manage Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: ext.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetCtx),
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
                  const SizedBox(height: 16),

                  // Categories List
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final cat = categories[idx];
                        final count = itemsProv.itemsByCategory(cat.key).length;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: ext.bgColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClayIconBadge(
                                icon: cat.icon,
                                size: 18,
                                padding: 8,
                                gradientColors: AppColors.getCategoryGradient(cat.key),
                                badgeColor: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E2135)
                                    : const Color(0xFFFFFFFF),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.displayName,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: ext.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '$count ${count == 1 ? 'dream' : 'dreams'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: ext.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _confirmDeleteCategory(
                                    context,
                                    cat,
                                    count,
                                    itemsProv,
                                    onDeleted: () => setModalState(() {}),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add New Category Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        Navigator.pop(context);
                        AddCategorySheet.show(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ext.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Add New Category',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCategory(
    BuildContext context,
    OrigoCategory category,
    int count,
    ItemsProvider itemsProv, {
    required VoidCallback onDeleted,
  }) {
    HapticFeedback.mediumImpact();
    final ext = context.ext;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: ext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete ${category.displayName}?',
          style: TextStyle(color: ext.textPrimary, fontWeight: FontWeight.w800),
        ),
        content: Text(
          count > 0
              ? 'This will remove the "${category.displayName}" collection and its $count dreams.'
              : 'Are you sure you want to remove the "${category.displayName}" category?',
          style: TextStyle(color: ext.textMuted, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: ext.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: () async {
              HapticFeedback.heavyImpact();
              Navigator.pop(dialogCtx);
              await itemsProv.deleteCategory(category.key);
              onDeleted();
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmResetToDefaults(BuildContext context, ItemsProvider prov) {
    HapticFeedback.mediumImpact();
    final ext = context.ext;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Reset Showcase',
          style: TextStyle(
            color: ext.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          'This will restore default curated dreams and categories. Your current customizations will be replaced.',
          style: TextStyle(color: ext.textMuted, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ext.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ext.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              Navigator.pop(ctx);
              await prov.resetToDefaults();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Showcase dreams restored successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Reset',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, ItemsProvider prov) {
    HapticFeedback.heavyImpact();
    final ext = context.ext;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Clear All Dreams?',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          'This action will permanently delete all your dreams and reset your canvas. This cannot be undone.',
          style: TextStyle(color: ext.textMuted, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ext.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              Navigator.pop(ctx);
              await prov.clearAllItems();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All dreams have been cleared.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Clear All',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: ext.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClayIconBadge(
        icon: icon,
        size: 18,
        padding: 8,
        iconColor: iconColor ?? (isDestructive ? AppColors.error : ext.textPrimary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: isDestructive ? AppColors.error : ext.textPrimary,
          letterSpacing: -0.2,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: ext.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: ext.textMuted.withValues(alpha: 0.5),
      ),
    );
  }
}

class _SettingsInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SettingsInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClayIconBadge(
        icon: icon,
        size: 18,
        padding: 8,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: ext.textPrimary,
          letterSpacing: -0.2,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: ext.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: ext.accent,
          ),
        ),
      ),
    );
  }
}
