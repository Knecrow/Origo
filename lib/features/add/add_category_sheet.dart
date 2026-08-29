// lib/features/add/add_category_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/items_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';

const List<IconData> kAvailableCategoryIcons = [
  Icons.watch_rounded,
  Icons.diamond_rounded,
  Icons.castle_rounded,
  Icons.villa_rounded,
  Icons.landscape_rounded,
  Icons.brush_rounded,
  Icons.palette_rounded,
  Icons.wine_bar_rounded,
  Icons.military_tech_rounded,
  Icons.shield_rounded,
  Icons.sports_esports_rounded,
  Icons.sports_golf_rounded,
  Icons.piano_rounded,
  Icons.camera_alt_rounded,
  Icons.key_rounded,
  Icons.star_rounded,
  Icons.bolt_rounded,
  Icons.workspace_premium_rounded,
  Icons.fitness_center_rounded,
  Icons.auto_stories_rounded,
];

const List<Color> kAvailableCategoryColors = [
  Color(0xFF7B9EC2), // Platinum Slate
  Color(0xFF5CAE97), // Monaco Emerald
  Color(0xFFC4936B), // Cognac Amber
  Color(0xFF8B7BC2), // Royal Violet
  Color(0xFF55A4B5), // Côte d'Azur
  Color(0xFFB5708E), // Rose Champagne
  Color(0xFFC25C68), // Imperial Crimson
  Color(0xFFD4A853), // Tuscan Gold
  Color(0xFF5AB5C2), // Arctic Cyan
  Color(0xFF6B87A6), // Deep Slate
];

class AddCategorySheet extends StatefulWidget {
  const AddCategorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const AddCategorySheet(),
    );
  }

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _displayCtrl = TextEditingController();

  IconData _selectedIcon = kAvailableCategoryIcons.first;
  Color _selectedColor = kAvailableCategoryColors.first;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _displayCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final name = _nameCtrl.text.trim();
      final display = _displayCtrl.text.trim().isNotEmpty
          ? _displayCtrl.text.trim().toUpperCase()
          : name.toUpperCase();

      if (!mounted) return;
      await context.read<ItemsProvider>().addCategory(
            name: name,
            displayName: display,
            icon: _selectedIcon,
            color: _selectedColor,
          );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add category. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: ext.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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

              // Title
              Text(
                'NEW VISION CATEGORY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: ext.accent,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Category Name Input
              Text(
                'CATEGORY NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: ext.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                style: TextStyle(color: ext.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g. Watches, Real Estate, Island...',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Category name is required';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Display Subtitle / Tagline
              Text(
                'EDITORIAL TAGLINE (OPTIONAL)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: ext.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _displayCtrl,
                style: TextStyle(color: ext.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g. HOROLOGY & CRAFT, PRIVATE SANCTUARY...',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Color Palette Picker
              Text(
                'ACCENT COLOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: ext.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kAvailableCategoryColors.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final col = kAvailableCategoryColors[idx];
                    final isSelected = col == _selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = col),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: col,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: col.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Icon Selector
              Text(
                'SELECT ICON',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: ext.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kAvailableCategoryIcons.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final icon = kAvailableCategoryIcons[idx];
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: ClayIconBadge(
                        icon: icon,
                        size: 18,
                        padding: 10,
                        iconColor: isSelected ? Colors.white : ext.textMuted,
                        badgeColor: isSelected
                            ? _selectedColor.withValues(alpha: 0.85)
                            : ext.cardColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Live Preview Card
              Text(
                'LIVE PREVIEW',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: ext.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 74,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: ext.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedColor.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClayIconBadge(
                      icon: _selectedIcon,
                      size: 18,
                      padding: 8,
                      iconColor: Colors.white,
                      badgeColor: _selectedColor.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayCtrl.text.trim().isNotEmpty
                                ? _displayCtrl.text.trim().toUpperCase()
                                : (_nameCtrl.text.trim().isNotEmpty
                                    ? _nameCtrl.text.trim().toUpperCase()
                                    : 'NEW CATEGORY'),
                            style: TextStyle(
                              color: _selectedColor.withValues(alpha: 0.9),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _nameCtrl.text.trim().isNotEmpty
                                ? _nameCtrl.text.trim()
                                : 'Category Name',
                            style: TextStyle(
                              color: ext.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _selectedColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '0 Assets',
                        style: TextStyle(
                          color: _selectedColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Create Category Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _saving
                    ? Center(
                        child: CircularProgressIndicator(color: ext.accent),
                      )
                    : ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ext.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'CREATE CATEGORY',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
