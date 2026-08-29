// lib/features/add/add_category_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/origo_category.dart';
import '../../core/providers/items_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_icon_badge.dart';

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

  IconData _selectedIcon = kAllSupportedCategoryIcons.first;
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
      final ext = context.ext;

      await context.read<ItemsProvider>().addCategory(
            name: name,
            displayName: display,
            icon: _selectedIcon,
            color: ext.accent,
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
                  itemCount: kAllSupportedCategoryIcons.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final icon = kAllSupportedCategoryIcons[idx];
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: ClayIconBadge(
                        icon: icon,
                        size: 18,
                        padding: 10,
                        iconColor: isSelected ? Colors.white : ext.textMuted,
                        badgeColor: isSelected
                            ? ext.accent.withValues(alpha: 0.85)
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
                  boxShadow: [
                    BoxShadow(
                      color: ext.shadowLight,
                      offset: const Offset(-3, -3),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: ext.shadowDark,
                      offset: const Offset(3, 3),
                      blurRadius: 8,
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
                      badgeColor: ext.accent.withValues(alpha: 0.85),
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
                              color: ext.accent.withValues(alpha: 0.9),
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
                        color: ext.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '0 Assets',
                        style: TextStyle(
                          color: ext.accent,
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
