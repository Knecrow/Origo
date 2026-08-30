// lib/features/add/add_item_sheet.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/models/origo_category.dart';
import '../../core/models/origo_item.dart';
import '../../core/providers/items_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/origo_image.dart';
import 'add_category_sheet.dart';

class AddItemSheet extends StatefulWidget {
  final String? initialCategory;
  final String? initialSubCategory;

  const AddItemSheet({
    super.key,
    this.initialCategory,
    this.initialSubCategory,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialCategory,
    String? initialSubCategory,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddItemSheet(
        initialCategory: initialCategory,
        initialSubCategory: initialSubCategory,
      ),
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
  String? _selectedSubCategory;
  String? _pickedImagePath;
  bool _isSpotlight = false;
  bool _showMoreDetails = false;
  bool _saving = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedSubCategory = widget.initialSubCategory;
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
      setState(() {
        _selectedCategory = latestCats.last.key;
        _selectedSubCategory = null;
      });
    }
  }

  Future<void> _save() async {
    if (_pickedImagePath == null) {
      _showError('Please select an image for your dream');
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
            subCategory: _selectedSubCategory,
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
    final suggestedSubs = kSuggestedSubCategories[activeCategory] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: ext.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
      child: Form(
        key: _formKey,
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
              const SizedBox(height: 16),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Dream',
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

              // 1. Image Drop Box
              _ImagePickerWidget(
                imagePath: _pickedImagePath,
                onTap: _pickImage,
              ),
              const SizedBox(height: 18),

              // 2. Title Field
              TextFormField(
                controller: _titleCtrl,
                style: TextStyle(
                  color: ext.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'What is your vision? (e.g. Villa in Como)',
                  filled: true,
                  fillColor: ext.bgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please name your dream' : null,
              ),
              const SizedBox(height: 16),

              // 3. Category Selector Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Collection',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ext.textMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: _openAddCategory,
                    child: Text(
                      '+ Custom Category',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ext.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _CategorySelector(
                categories: categories,
                selected: activeCategory,
                onChanged: (c) => setState(() {
                  _selectedCategory = c;
                  _selectedSubCategory = null;
                }),
              ),

              // Sub-Categories Chips (if available)
              if (suggestedSubs.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestedSubs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final sub = suggestedSubs[idx];
                      final isSelected = sub == _selectedSubCategory;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedSubCategory = isSelected ? null : sub;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ext.textPrimary
                                : ext.bgColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              sub,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? ext.bgColor
                                    : ext.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // 4. Optional Details Collapsible Accordion
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showMoreDetails = !_showMoreDetails);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: ext.bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _showMoreDetails
                                ? Icons.tune_rounded
                                : Icons.more_horiz_rounded,
                            size: 16,
                            color: ext.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showMoreDetails ? 'Hide Options' : 'More Options (Timeframe, Notes, Spotlight)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ext.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        _showMoreDetails
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: ext.textMuted,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Details
              if (_showMoreDetails) ...[
                const SizedBox(height: 14),
                // Timeframe Field
                TextFormField(
                  controller: _timeframeCtrl,
                  style: TextStyle(color: ext.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Target Timeframe (e.g. 2027, In 3 Years)',
                    filled: true,
                    fillColor: ext.bgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                // Motivation Notes Field
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  style: TextStyle(color: ext.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Personal Motivation / Affirmation (Optional)',
                    filled: true,
                    fillColor: ext.bgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                // Spotlight Switcher
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: ext.bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: _isSpotlight
                                ? const Color(0xFFFFD700)
                                : ext.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Featured Spotlight',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ext.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isSpotlight,
                        activeTrackColor: ext.accent,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          setState(() => _isSpotlight = v);
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // 5. Submit Button
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
                          'Add Dream',
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

// ── Minimalist Image Picker Widget ───────────────────────────────────────────

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
        width: double.infinity,
        height: imagePath != null ? 180 : 120,
        decoration: BoxDecoration(
          color: ext.bgColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: imagePath != null
              ? Stack(
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
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library_rounded,
                                color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Change',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ext.accent.withValues(alpha: 0.14),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_rounded,
                          color: ext.accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select Dream Photo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ext.textPrimary,
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

// ── Compact Category Selector ────────────────────────────────────────────────

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

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final cat = categories[idx];
          final isSelected = cat.key == selected;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(cat.key);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF7582FF)
                        : const Color(0xFF5360ED))
                    : ext.bgColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF5360ED).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: isSelected
                          ? [Colors.white, Colors.white]
                          : AppColors.getCategoryGradient(cat.key),
                    ).createShader(bounds),
                    child: Icon(
                      cat.icon,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    cat.displayName,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : ext.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
