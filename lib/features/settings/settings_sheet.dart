// lib/features/settings/settings_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
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
            const SizedBox(height: 24),

            // ── Section 1: Appearance ─────────────────────────────────────────
            _SectionHeader(title: 'APPEARANCE'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: ext.bgColor,
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
                color: ext.bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
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
                color: ext.bgColor,
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
                    icon: Icons.delete_sweep_outlined,
                    iconColor: AppColors.error,
                    title: 'Clear All Dreams',
                    subtitle: 'Erase all dream items (keeps categories)',
                    isDestructive: true,
                    onTap: () => _confirmClearAll(context, itemsProv),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 4: About ────────────────────────────────────────────
            _SectionHeader(title: 'ABOUT ORIGO'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ext.bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Origo Vision Board',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: ext.textPrimary,
                        ),
                      ),
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ext.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A borderless, distraction-free visual portfolio designed for your life\'s highest aspirations.',
                    style: TextStyle(
                      fontSize: 12,
                      color: ext.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetToDefaults(BuildContext context, ItemsProvider prov) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.ext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset to Showcase?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'This will restore the curated showcase dreams (Villa, Porsche GT3, Alps, etc.) and default categories.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ctx.ext.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ctx.ext.accent,
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
                    content: Text('Showcase dreams restored successfully!'),
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
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.ext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Dreams?',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.error)),
        content: const Text(
            'This will permanently delete all aspirations in your vision board. Categories will remain intact.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ctx.ext.textMuted)),
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
