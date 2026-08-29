// lib/core/models/origo_category.dart

import 'package:flutter/material.dart';

const List<IconData> kAllSupportedCategoryIcons = [
  Icons.home_rounded,
  Icons.directions_car_rounded,
  Icons.flight_rounded,
  Icons.explore_rounded,
  Icons.directions_boat_rounded,
  Icons.auto_awesome_rounded,
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
  Icons.category_rounded,
];

IconData iconFromCode(int code) {
  for (final icon in kAllSupportedCategoryIcons) {
    if (icon.codePoint == code) return icon;
  }
  return Icons.category_rounded;
}

class OrigoCategory {
  final int? id;
  final String key; // Unique key e.g. 'Home', 'Watches'
  final String displayName; // e.g. 'HOME & ESTATE', 'HOROLOGY & TIME'
  final IconData icon;
  final Color color;
  final bool isDefault;

  const OrigoCategory({
    this.id,
    required this.key,
    required this.displayName,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'key': key,
      'display_name': displayName,
      'icon_code': icon.codePoint,
      'color_value': color.toARGB32(),
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory OrigoCategory.fromMap(Map<String, dynamic> map) {
    final code = map['icon_code'] as int? ?? Icons.category_rounded.codePoint;
    final colorVal = map['color_value'] as int? ?? 0xFF5E8BB8;

    return OrigoCategory(
      id: map['id'] as int?,
      key: map['key'] as String,
      displayName: (map['display_name'] as String?) ?? (map['key'] as String),
      icon: iconFromCode(code),
      color: Color(colorVal),
      isDefault: (map['is_default'] as int? ?? 0) == 1,
    );
  }

  OrigoCategory copyWith({
    int? id,
    String? key,
    String? displayName,
    IconData? icon,
    Color? color,
    bool? isDefault,
  }) {
    return OrigoCategory(
      id: id ?? this.id,
      key: key ?? this.key,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static const List<OrigoCategory> defaultCategories = [
    OrigoCategory(
      key: 'Home',
      displayName: 'HOME & ESTATE',
      icon: Icons.home_rounded,
      color: Color(0xFF7B9EC2),
      isDefault: true,
    ),
    OrigoCategory(
      key: 'Garage',
      displayName: 'GARAGE & FLEET',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF7B9EC2),
      isDefault: true,
    ),
    OrigoCategory(
      key: 'Jets',
      displayName: 'JETS & AVIATION',
      icon: Icons.flight_rounded,
      color: Color(0xFF7B9EC2),
      isDefault: true,
    ),
    OrigoCategory(
      key: 'Places',
      displayName: 'PLACES & TRAVEL',
      icon: Icons.explore_rounded,
      color: Color(0xFF7B9EC2),
      isDefault: true,
    ),
    OrigoCategory(
      key: 'Yachts',
      displayName: 'YACHTS & MARINE',
      icon: Icons.directions_boat_rounded,
      color: Color(0xFF7B9EC2),
      isDefault: true,
    ),
    OrigoCategory(
      key: 'Others',
      displayName: 'COLLECTIONS & LUXURY',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF7B9EC2),
      isDefault: true,
    ),
  ];
}
