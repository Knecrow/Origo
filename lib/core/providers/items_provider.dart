// lib/core/providers/items_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/origo_category.dart';
import '../models/origo_item.dart';
import '../utils/image_loader.dart' as loader;

class ItemsProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<OrigoItem> _items = [];
  List<OrigoItem> get items => _items;

  List<OrigoCategory> _categories = OrigoCategory.defaultCategories;
  List<OrigoCategory> get categories => _categories;

  List<String> get categoryKeys => _categories.map((c) => c.key).toList();

  Map<String, String> get categoryDisplayNames => {
        for (final c in _categories) c.key: c.displayName,
      };

  Map<String, IconData> get categoryIcons => {
        for (final c in _categories) c.key: c.icon,
      };

  Map<String, Color> get categoryColors => {
        for (final c in _categories) c.key: c.color,
      };

  List<OrigoItem> get spotlightItems =>
      _items.where((i) => i.isSpotlight).toList();

  List<OrigoItem> itemsByCategory(String category) =>
      _items.where((i) => i.category == category).toList();

  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (final item in _items) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, OrigoItem?> get categoryLatestCover {
    final latest = <String, OrigoItem?>{};
    for (final item in _items) {
      if (!latest.containsKey(item.category)) {
        latest[item.category] = item;
      }
    }
    return latest;
  }

  bool _loading = false;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();

    try {
      final loadedCategories = await _db.getAllCategories();
      if (loadedCategories.isNotEmpty) {
        _categories = loadedCategories.map((c) {
          if (c.isDefault) {
            return c.copyWith(displayName: c.key);
          }
          return c;
        }).toList();
      }
    } catch (_) {}

    _items = await _db.getAllItems();
    _loading = false;
    notifyListeners();
  }

  // ── CATEGORIES ─────────────────────────────────────────────────────────────

  Future<void> addCategory({
    required String name,
    String? displayName,
    IconData icon = Icons.category_rounded,
    Color color = const Color(0xFF5E8BB8),
  }) async {
    final trimmedKey = name.trim();
    if (trimmedKey.isEmpty) return;

    final upperDisplay = (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim().toUpperCase()
        : trimmedKey.toUpperCase();

    final newCat = OrigoCategory(
      key: trimmedKey,
      displayName: upperDisplay,
      icon: icon,
      color: color,
      isDefault: false,
    );

    await _db.insertCategory(newCat);
    _categories.removeWhere((c) => c.key.toLowerCase() == trimmedKey.toLowerCase());
    _categories.add(newCat);
    notifyListeners();
  }

  Future<void> deleteCategory(String key) async {
    await _db.deleteCategory(key);
    _categories.removeWhere((c) => c.key == key);
    _items.removeWhere((i) => i.category == key);
    notifyListeners();
  }

  Future<void> deleteSubCategory(String categoryKey, String subCategory) async {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].category == categoryKey && _items[i].subCategory == subCategory) {
        final updated = _items[i].copyWith(subCategory: '');
        await _db.updateItem(updated);
        _items[i] = updated;
      }
    }
    notifyListeners();
  }

  // ── ITEMS ──────────────────────────────────────────────────────────────────

  Future<void> addItem({
    required String title,
    required String category,
    String? subCategory,
    required String imagePath,
    String? targetTimeframe,
    String? motivationNotes,
    bool isSpotlight = false,
  }) async {
    final finalPath = (kIsWeb ||
            imagePath.startsWith('http://') ||
            imagePath.startsWith('https://') ||
            imagePath.startsWith('data:image'))
        ? imagePath
        : await loader.saveLocalImage(imagePath);

    final item = OrigoItem(
      title: title,
      category: category,
      subCategory: subCategory?.trim().isNotEmpty == true ? subCategory : null,
      imagePath: finalPath,
      targetTimeframe: targetTimeframe?.trim().isNotEmpty == true
          ? targetTimeframe
          : null,
      motivationNotes: motivationNotes?.trim().isNotEmpty == true
          ? motivationNotes
          : null,
      isSpotlight: isSpotlight,
    );
    final id = await _db.insertItem(item);
    _items.insert(0, item.copyWith(id: id));
    notifyListeners();
  }

  Future<void> toggleSpotlight(OrigoItem item) async {
    final updated = item.copyWith(isSpotlight: !item.isSpotlight);
    await _db.updateItem(updated);
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      _items[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteItem(OrigoItem item) async {
    await _db.deleteItem(item.id!);
    if (!kIsWeb &&
        !item.imagePath.startsWith('http://') &&
        !item.imagePath.startsWith('https://') &&
        !item.imagePath.startsWith('data:image')) {
      await loader.deleteLocalImage(item.imagePath);
    }
    _items.removeWhere((i) => i.id == item.id);
    notifyListeners();
  }

  // ── BULK / RESET ACTIONS ───────────────────────────────────────────────────

  Future<void> clearAllItems() async {
    await _db.clearAllItems();
    _items.clear();
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    await _db.resetToDefaults();
    await loadAll();
  }
}
