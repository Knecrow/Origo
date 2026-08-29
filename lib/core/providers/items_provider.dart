// lib/core/providers/items_provider.dart

import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/origo_item.dart';
import '../utils/image_loader.dart' as loader;

class ItemsProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<OrigoItem> _items = [];
  List<OrigoItem> get items => _items;

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
    _items = await _db.getAllItems();
    _loading = false;
    notifyListeners();
  }

  Future<void> addItem({
    required String title,
    required String category,
    required String imagePath,
    String? targetTimeframe,
    String? motivationNotes,
    bool isSpotlight = false,
  }) async {
    // If it's on mobile/desktop and a local file path, copy locally.
    // If it's on web (data:image or url), use it directly.
    final finalPath = (kIsWeb ||
            imagePath.startsWith('http://') ||
            imagePath.startsWith('https://') ||
            imagePath.startsWith('data:image'))
        ? imagePath
        : await loader.saveLocalImage(imagePath);

    final item = OrigoItem(
      title: title,
      category: category,
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
}
