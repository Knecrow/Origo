// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/items_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';
import '../../core/widgets/origo_image.dart';
import '../settings/settings_sheet.dart';
import 'first_time_setup_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<IconData> _avatarIcons = [
    Icons.person_rounded,
    Icons.auto_awesome_rounded,
    Icons.military_tech_rounded,
    Icons.account_balance_rounded,
    Icons.diamond_rounded,
    Icons.shield_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final themeProv = context.watch<ThemeProvider>();
    final profileProv = context.watch<ProfileProvider>();
    final itemsProv = context.watch<ItemsProvider>();
    final isDark = themeProv.isDark;

    final categories = itemsProv.categories;
    final counts = itemsProv.categoryCounts;
    final totalVisions = itemsProv.items.length;

    return Scaffold(
      backgroundColor: ext.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Header Bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  ClayIconBadge(
                    icon: Icons.arrow_back_rounded,
                    size: 20,
                    padding: 10,
                    iconColor: ext.textPrimary,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                  ),

                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: ext.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // Theme Toggle
                  ClayIconBadge(
                    icon: isDark ? Icons.wb_sunny_rounded : Icons.cloud_outlined,
                    size: 20,
                    padding: 10,
                    iconColor: isDark ? const Color(0xFFFFD60A) : const Color(0xFF5360ED),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      themeProv.toggle();
                    },
                  ),
                ],
              ),
            ),

            // ── 2. Scrollable Body Content ────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Identity Hero Card ────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B1D2E) : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF22253B),
                                  const Color(0xFF161726),
                                ]
                              : [
                                  const Color(0xFFFFFFFF),
                                  const Color(0xFFF3F4FB),
                                ],
                        ),
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: const Color(0xFF757E9E).withValues(alpha: 0.18),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          // Avatar Circle
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF1B1D2E) : Colors.white,
                              boxShadow: isDark
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF7582FF).withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 0),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFF757E9E).withValues(alpha: 0.24),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                            ),
                            child: ClipOval(
                              child: profileProv.avatarPath != null
                                  ? OrigoImage(
                                      imagePath: profileProv.avatarPath!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Icon(
                                        _avatarIcons[profileProv.avatarIndex.clamp(0, _avatarIcons.length - 1)],
                                        size: 44,
                                        color: isDark ? const Color(0xFF8B96FF) : const Color(0xFF5360ED),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Name
                          Text(
                            profileProv.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: ext.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Motto / Vision Statement
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '"${profileProv.motto}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                color: ext.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Edit Profile Button
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              FirstTimeSetupSheet.show(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF282C46) : const Color(0xFFECEFFC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_rounded,
                                    size: 15,
                                    color: isDark ? const Color(0xFF8B96FF) : const Color(0xFF5360ED),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? const Color(0xFF8B96FF) : const Color(0xFF5360ED),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── 3. Vault Overview Stats ───────────────────────────
                    Text(
                      'VAULT OVERVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: ext.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // Total Visions Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B1D2E) : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: isDark
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFF757E9E).withValues(alpha: 0.14),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$totalVisions',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: ext.textPrimary,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Total Visions',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ext.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Active Collections Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B1D2E) : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: isDark
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFF757E9E).withValues(alpha: 0.14),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${categories.length}',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: ext.textPrimary,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Collections',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ext.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── 4. Collection Breakdown ───────────────────────────
                    Text(
                      'COLLECTIONS BREAKDOWN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: ext.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B1D2E) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: const Color(0xFF757E9E).withValues(alpha: 0.14),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < categories.length; i++) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  ClayIconBadge(
                                    icon: categories[i].icon,
                                    size: 18,
                                    padding: 10,
                                    gradientColors: AppColors.getCategoryGradient(categories[i].key),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      categories[i].displayName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: ext.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF24273E)
                                          : const Color(0xFFEFF1FA),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${counts[categories[i].key] ?? 0} visions',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: ext.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (i < categories.length - 1)
                              Divider(
                                height: 1,
                                indent: 64,
                                endIndent: 16,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : const Color(0xFFE8EAF4),
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── 5. Vault Management Quick Actions ────────────────
                    Text(
                      'PREFERENCES & MANAGEMENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: ext.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        SettingsSheet.show(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B1D2E) : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: isDark
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF757E9E).withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF282C46) : const Color(0xFFEFF1FA),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.category_rounded,
                                size: 18,
                                color: isDark ? const Color(0xFF7582FF) : const Color(0xFF5360ED),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manage Categories & Subcategories',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: ext.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Create, organize, or delete collections',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: ext.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: ext.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
