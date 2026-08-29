// lib/features/add/add_item_sheet.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/models/origo_category.dart';
import '../../core/providers/items_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/clay_icon_badge.dart';
import '../../core/widgets/origo_image.dart';
import 'add_category_sheet.dart';

class AddItemSheet extends StatefulWidget {
  final String? initialCategory;
  const AddItemSheet({super.key, this.initialCategory});

  static Future<void> show(BuildContext context, {String? initialCategory}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddItemSheet(initialCategory: initialCategory),
    );
  }

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _timeframeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedCategory;
  String? _pickedImagePath;
  bool _isSpotlight = false;
  bool _saving = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _timeframeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (result != null) {
        HapticFeedback.lightImpact();
        if (kIsWeb) {
          final bytes = await result.readAsBytes();
          final mime = result.mimeType ?? 'image/jpeg';
          final base64String = 'data:$mime;base64,${base64Encode(bytes)}';
          setState(() => _pickedImagePath = base64String);
        } else {
          setState(() => _pickedImagePath = result.path);
        }
      }
    } catch (e) {
      _showError('Could not open image picker');
    }
  }

  Future<void> _openAddCategory() async {
    HapticFeedback.lightImpact();
    await AddCategorySheet.show(context);
    if (!mounted) return;
    final latestCats = context.read<ItemsProvider>().categories;
    if (latestCats.isNotEmpty) {
      setState(() => _selectedCategory = latestCats.last.key);
    }
  }

  Future<void> _save() async {
    if (_pickedImagePath == null) {
      _showError('Please select an image');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final categories = context.read<ItemsProvider>().categories;
    final cat = _selectedCategory ??
        (categories.isNotEmpty ? categories.first.key : 'Home');

    setState(() => _saving = true);
    try {
      await context.read<ItemsProvider>().addItem(
            title: _titleCtrl.text.trim(),
            category: cat,
            imagePath: _pickedImagePath!,
            targetTimeframe: _timeframeCtrl.text,
            motivationNotes: _notesCtrl.text,
            isSpotlight: _isSpotlight,
          );
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      _showError('Failed to save item. Please try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final itemsProv = context.watch<ItemsProvider>();
    final categories = itemsProv.categories;

    final activeCategory = _selectedCategory ??
        (categories.isNotEmpty ? categories.first.key : 'Home');

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
              const SizedBox(height: 20),

              // Title
              Text(
                'New Aspiration',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ext.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 18),

              // Image Picker
              _ImagePickerWidget(
                imagePath: _pickedImagePath,
                onTap: _pickImage,
              ),
              const SizedBox(height: 20),

              // Category Header with Add Circle Popup on the Left
              Row(
                children: [
                  GestureDetector(
                    onTap: _openAddCategory,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: ext.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 15,
                        color: ext.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ext.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _CategorySelector(
                categories: categories,
                selected: activeCategory,
                onChanged: (c) => setState(() => _selectedCategory = c),
              ),
              const SizedBox(height: 20),

              // Title Field
              Text(
                'Title',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ext.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                style: TextStyle(color: ext.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g. Villa in Como, Porsche 911 GT3',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Timeframe
              Text(
                'Target Date / Timeframe',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ext.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _timeframeCtrl,
                style: TextStyle(color: ext.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g. By Age 30, Q4 2027, In 3 Years',
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              Text(
                'Motivation & Notes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ext.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                style: TextStyle(color: ext.textPrimary),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Why does this matter to you?',
                ),
              ),
              const SizedBox(height: 20),

              // Spotlight toggle
              ClayCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: _isSpotlight
                          ? const Color(0xFFFFD700)
                          : ext.textMuted,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add to Spotlight',
                            style: TextStyle(
                              color: ext.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Feature in hero carousel',
                            style: TextStyle(
                              color: ext.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isSpotlight,
                      onChanged: (v) => setState(() => _isSpotlight = v),
                      activeThumbColor: ext.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 54,
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
                          'Add to Portfolio',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
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

// ── Image Picker Widget ────────────────────────────────────────────────────────

class _ImagePickerWidget extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const _ImagePickerWidget({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ext.bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    OrigoImage(imagePath: imagePath!, fit: BoxFit.cover),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_rounded,
                                color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('Change',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClayIconBadge(
                    icon: Icons.add_photo_alternate_rounded,
                    size: 32,
                    padding: 16,
                    iconColor: ext.accent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to select image',
                    style: TextStyle(
                      color: ext.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'From your gallery or files',
                    style: TextStyle(
                      color: ext.textMuted.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Dynamic Category Selector ──────────────────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  final List<OrigoCategory> categories;
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategorySelector({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((cat) {
        final isSelected = cat.key == selected;
        final color = ext.accent;
        final icon = cat.icon;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(cat.key);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.85)
                  : ext.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : ext.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  cat.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : ext.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
