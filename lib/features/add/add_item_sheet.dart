// lib/features/add/add_item_sheet.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/items_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/origo_image.dart';

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

  String? _pickedImagePath;
  bool _saving = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
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

  void _promptUrlInput() {
    final ext = context.ext;
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: ext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Image URL',
          style: TextStyle(
            color: ext.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: urlCtrl,
          autofocus: true,
          style: TextStyle(color: ext.textPrimary),
          decoration: InputDecoration(
            hintText: 'https://example.com/image.jpg',
            filled: true,
            fillColor: ext.cardSecondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: ext.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = urlCtrl.text.trim();
              if (val.isNotEmpty) {
                setState(() => _pickedImagePath = val);
                Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ext.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Use Image'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_pickedImagePath == null) {
      _showError('Please add a photo for your dream');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final categories = context.read<ItemsProvider>().categories;
    final cat = widget.initialCategory ??
        (categories.isNotEmpty ? categories.first.key : 'Home');

    setState(() => _saving = true);
    try {
      await context.read<ItemsProvider>().addItem(
            title: _titleCtrl.text.trim(),
            category: cat,
            subCategory: widget.initialSubCategory,
            imagePath: _pickedImagePath!,
          );
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      _showError('Failed to save dream. Please try again.');
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

              // 1. Photo Adder Box
              _ImagePickerWidget(
                imagePath: _pickedImagePath,
                onTap: _pickImage,
                onUrlTap: _promptUrlInput,
                onRemove: () => setState(() => _pickedImagePath = null),
              ),
              const SizedBox(height: 18),

              // 2. Dream Name Field
              TextFormField(
                controller: _titleCtrl,
                autofocus: _pickedImagePath != null,
                style: TextStyle(
                  color: ext.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Dream Name (e.g. Lake Como Villa)',
                  hintStyle: TextStyle(
                    color: ext.textMuted.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: ext.cardSecondaryColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a name for your dream';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Save Button
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
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Add Dream',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
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

// ── Ultra-Clean Image Picker Widget ───────────────────────────────────────────

class _ImagePickerWidget extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;
  final VoidCallback onUrlTap;
  final VoidCallback onRemove;

  const _ImagePickerWidget({
    required this.imagePath,
    required this.onTap,
    required this.onUrlTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.ext;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imagePath != null) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: ext.cardSecondaryColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              OrigoImage(
                imagePath: imagePath!,
                fit: BoxFit.cover,
              ),
              // Change photo tap area
              GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.translucent,
              ),
              // Remove / Replace badges
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.photo_library_rounded, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Change', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
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

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ext.cardSecondaryColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: ext.textMuted.withValues(alpha: isDark ? 0.18 : 0.12),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: ext.primaryGradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ext.accent.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Text(
              'Tap to Upload Photo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ext.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'from gallery, camera or ',
                style: TextStyle(fontSize: 11.5, color: ext.textMuted),
              ),
              GestureDetector(
                onTap: onUrlTap,
                child: Text(
                  'paste URL',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: ext.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
