// lib/features/add/add_category_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      HapticFeedback.mediumImpact();

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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: ext.shadowDark.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
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
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Collection',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: ext.textPrimary,
                      letterSpacing: -0.4,
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
              const SizedBox(height: 16),

              // Category Name
              Text(
                'COLLECTION NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: ext.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                style: TextStyle(color: ext.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'e.g. Watches, Real Estate, Art',
                  filled: true,
                  fillColor: ext.cardSecondaryColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),

              // Display Header Subtitle (Optional)
              Text(
                'DISPLAY TITLE (OPTIONAL)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: ext.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _displayCtrl,
                style: TextStyle(color: ext.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'e.g. HOROLOGY & TIMEPIECES',
                  filled: true,
                  fillColor: ext.cardSecondaryColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),

              // Select Icon
              Text(
                'SELECT ICON',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: ext.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kAllSupportedCategoryIcons.length,
                  separatorBuilder: (context, _) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final icon = kAllSupportedCategoryIcons[idx];
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedIcon = icon);
                      },
                      child: ClayIconBadge(
                        icon: icon,
                        size: 18,
                        padding: 10,
                        iconColor: isSelected ? Colors.white : ext.textMuted,
                        badgeColor: isSelected
                            ? ext.accent
                            : ext.cardSecondaryColor,
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
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: ext.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 74,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: ext.cardSecondaryColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    ClayIconBadge(
                      icon: _selectedIcon,
                      size: 18,
                      padding: 8,
                      iconColor: ext.accent,
                      badgeColor: ext.cardColor,
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
                                    : 'NEW COLLECTION'),
                            style: TextStyle(
                              color: ext.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _nameCtrl.text.trim().isNotEmpty
                                ? _nameCtrl.text.trim()
                                : 'Collection Name',
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
                        color: ext.textMuted.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '0 Visions',
                        style: TextStyle(
                          color: ext.textPrimary,
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
              GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: LinearGradient(
                      colors: ext.primaryGradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ext.accent.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Create Collection',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
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
