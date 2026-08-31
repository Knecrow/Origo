// lib/core/database/database_helper.dart

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/origo_category.dart';
import '../models/origo_item.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      final factory = databaseFactoryFfiWeb;
      return factory.openDatabase(
        'origo.db',
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'origo.db');
      return openDatabase(
        path,
        version: 4,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Items table without restrictive CHECK constraint so custom categories work seamlessly
    await db.execute('''
      CREATE TABLE origo_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        sub_category TEXT,
        image_path TEXT NOT NULL,
        target_timeframe TEXT,
        motivation_notes TEXT,
        is_spotlight INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 2. Categories table
    await db.execute('''
      CREATE TABLE origo_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        icon_font_family TEXT,
        color_value INTEGER NOT NULL,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // 3. Seed default categories
    final catBatch = db.batch();
    for (final cat in OrigoCategory.defaultCategories) {
      catBatch.insert('origo_categories', cat.toMap());
    }
    await catBatch.commit(noResult: true);

    // 4. Seed initial curated dreams
    final batch = db.batch();
    for (final seed in _initialSeedItems) {
      batch.insert('origo_items', seed.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS origo_categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          key TEXT NOT NULL UNIQUE,
          display_name TEXT NOT NULL,
          icon_code INTEGER NOT NULL,
          icon_font_family TEXT,
          color_value INTEGER NOT NULL,
          is_default INTEGER DEFAULT 0
        )
      ''');

      final catBatch = db.batch();
      for (final cat in OrigoCategory.defaultCategories) {
        catBatch.insert(
          'origo_categories',
          cat.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await catBatch.commit(noResult: true);
    }

    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE origo_items ADD COLUMN sub_category TEXT');
      } catch (_) {}
    }

    if (oldVersion < 4) {
      try {
        // Migrate old category keys to new taxonomy
        await db.execute("UPDATE origo_items SET category = 'Aviation' WHERE category = 'Jets'");
        await db.execute("UPDATE origo_items SET category = 'Marine' WHERE category = 'Yachts'");
        await db.execute("UPDATE origo_items SET category = 'Collections' WHERE category = 'Others'");

        // Refresh default categories
        await db.execute("DELETE FROM origo_categories WHERE is_default = 1");
        final catBatch = db.batch();
        for (final cat in OrigoCategory.defaultCategories) {
          catBatch.insert(
            'origo_categories',
            cat.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await catBatch.commit(noResult: true);

        // Seed new categories items if missing
        final existingSanctuary = await db.query(
          'origo_items',
          where: 'category = ?',
          whereArgs: ['Sanctuary'],
        );
        if (existingSanctuary.isEmpty) {
          await db.insert('origo_items', _initialSeedItems[5].toMap());
        }

        final existingExp = await db.query(
          'origo_items',
          where: 'category = ?',
          whereArgs: ['Experiences'],
        );
        if (existingExp.isEmpty) {
          await db.insert('origo_items', _initialSeedItems[6].toMap());
        }
      } catch (_) {}
    }
  }

  static const List<OrigoItem> _initialSeedItems = [
    OrigoItem(
      title: 'Architectural Cliffside Haven',
      category: 'Home',
      subCategory: 'Villas',
      imagePath:
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
      targetTimeframe: 'By 2028',
      motivationNotes:
          'A sanctuary of concrete, warm teak, and floor-to-ceiling glass designed to harbor serenity and profound creative focus.',
      isSpotlight: true,
    ),
    OrigoItem(
      title: 'Porsche 911 GT3 RS',
      category: 'Garage',
      subCategory: 'Cars',
      imagePath:
          'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=1200&q=80',
      targetTimeframe: '2027 Q4',
      motivationNotes:
          'Weissach package with magnesium wheels in PTS Slate Grey. Pure mechanical harmony and precision track capability.',
      isSpotlight: true,
    ),
    OrigoItem(
      title: 'Gulfstream G700 Cabin Suite',
      category: 'Aviation',
      subCategory: 'Private Jets',
      imagePath:
          'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=1200&q=80',
      targetTimeframe: 'By 2031',
      motivationNotes:
          'Limitless global range with zero jetlag circadian lighting and an ultra-quiet private master stateroom.',
      isSpotlight: true,
    ),
    OrigoItem(
      title: '85m Custom Explorer Yacht',
      category: 'Marine',
      subCategory: 'Superyachts',
      imagePath:
          'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?auto=format&fit=crop&w=1200&q=80',
      targetTimeframe: 'By 2033',
      motivationNotes:
          'Ice-class exploration vessel equipped with helicopter hangar and submarine dock for polar expeditions.',
      isSpotlight: true,
    ),
    OrigoItem(
      title: 'Amalfi Coast Villa & Marina',
      category: 'Places',
      subCategory: 'Europe',
      imagePath:
          'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=1200&q=80',
      targetTimeframe: 'Summer 2027',
      motivationNotes:
          'Terrace perched above Mediterranean turquoise waters with private mooring for sunrise departures.',
      isSpotlight: true,
    ),
    OrigoItem(
      title: 'Nordic Cliffside Spa & Sauna Pavilion',
      category: 'Sanctuary',
      subCategory: 'Home Spas',
      imagePath:
          'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=1200&q=80',
      targetTimeframe: 'By 2028',
      motivationNotes:
          'Private thermal hydrotherapy pools and cedar saunas facing panoramic fjord waters.',
      isSpotlight: true,
    ),
    OrigoItem(
      title: 'Aurora Borealis Glass Igloo Expedition',
      category: 'Experiences',
      subCategory: 'Polar Expeditions',
      imagePath:
          'https://images.unsplash.com/photo-1517411032315-54ef2cb783bb?auto=format&fit=crop&w=1200&q=80',
      targetTimeframe: 'Winter 2027',
      motivationNotes:
          'Stargazing beneath the Northern Lights in Finnish Lapland with private snowmobile safaris.',
      isSpotlight: true,
    ),
    OrigoItem(
      title: 'Patek Philippe Grandmaster Chime',
      category: 'Collections',
      subCategory: 'Watches',
      imagePath:
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=1200&q=80',
      targetTimeframe: 'Milestone Year',
      motivationNotes:
          'A timeless horological wonder with 20 acoustic complications and hand-engraved white gold casing.',
      isSpotlight: false,
    ),
  ];

  // ── CATEGORIES CRUD ──────────────────────────────────────────────────────────

  Future<List<OrigoCategory>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('origo_categories', orderBy: 'id ASC');
    if (maps.isEmpty) {
      return OrigoCategory.defaultCategories;
    }
    return maps.map(OrigoCategory.fromMap).toList();
  }

  Future<int> insertCategory(OrigoCategory category) async {
    final db = await database;
    return db.insert(
      'origo_categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCategory(OrigoCategory category) async {
    final db = await database;
    return db.update(
      'origo_categories',
      category.toMap(),
      where: 'key = ?',
      whereArgs: [category.key],
    );
  }

  Future<int> deleteCategory(String key) async {
    final db = await database;
    return db.delete(
      'origo_categories',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // ── ITEMS CREATE ─────────────────────────────────────────────────────────────

  Future<int> insertItem(OrigoItem item) async {
    final db = await database;
    return db.insert(
      'origo_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── ITEMS READ ───────────────────────────────────────────────────────────────

  Future<List<OrigoItem>> getAllItems() async {
    final db = await database;
    final maps = await db.query('origo_items', orderBy: 'created_at DESC');
    return maps.map(OrigoItem.fromMap).toList();
  }

  Future<List<OrigoItem>> getItemsByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'origo_items',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return maps.map(OrigoItem.fromMap).toList();
  }

  Future<List<OrigoItem>> getSpotlightItems() async {
    final db = await database;
    final maps = await db.query(
      'origo_items',
      where: 'is_spotlight = 1',
      orderBy: 'created_at DESC',
    );
    return maps.map(OrigoItem.fromMap).toList();
  }

  Future<OrigoItem?> getItemById(int id) async {
    final db = await database;
    final maps =
        await db.query('origo_items', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return OrigoItem.fromMap(maps.first);
  }

  // ── ITEMS UPDATE ─────────────────────────────────────────────────────────────

  Future<int> updateItem(OrigoItem item) async {
    final db = await database;
    return db.update(
      'origo_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> toggleSpotlight(int id, bool isSpotlight) async {
    final db = await database;
    return db.update(
      'origo_items',
      {'is_spotlight': isSpotlight ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── ITEMS DELETE ─────────────────────────────────────────────────────────────

  Future<int> deleteItem(int id) async {
    final db = await database;
    return db.delete('origo_items', where: 'id = ?', whereArgs: [id]);
  }

  // ── RESET & BACKUP ─────────────────────────────────────────────────────────

  Future<void> clearAllItems() async {
    final db = await database;
    await db.delete('origo_items');
  }

  Future<void> resetToDefaults() async {
    final db = await database;
    await db.delete('origo_items');
    await db.delete('origo_categories');

    final catBatch = db.batch();
    for (final cat in OrigoCategory.defaultCategories) {
      catBatch.insert('origo_categories', cat.toMap());
    }
    await catBatch.commit(noResult: true);

    final batch = db.batch();
    for (final seed in _initialSeedItems) {
      batch.insert('origo_items', seed.toMap());
    }
    await batch.commit(noResult: true);
  }
}
