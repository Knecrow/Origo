// lib/core/models/origo_item.dart

const List<String> kCategories = [
  'Home',
  'Places',
  'Garage',
  'Jets',
  'Yachts',
  'Others',
];

const Map<String, List<String>> kSuggestedSubCategories = {
  'Garage': ['Cars', 'Bikes', 'Hypercars', 'Classics'],
  'Home': ['Villas', 'Penthouses', 'Interiors', 'Architecture'],
  'Places': ['Europe', 'Tropical', 'Mountains', 'Islands'],
  'Jets': ['Private Jets', 'Helicopters', 'Cabins'],
  'Yachts': ['Superyachts', 'Catamarans', 'Speedboats'],
  'Others': ['Watches', 'Art', 'Fashion', 'Technology'],
};

class OrigoItem {
  final int? id;
  final String title;
  final String category;
  final String? subCategory;
  final String imagePath;
  final String? targetTimeframe;
  final String? motivationNotes;
  final bool isSpotlight;
  final String? createdAt;

  const OrigoItem({
    this.id,
    required this.title,
    required this.category,
    this.subCategory,
    required this.imagePath,
    this.targetTimeframe,
    this.motivationNotes,
    this.isSpotlight = false,
    this.createdAt,
  });

  OrigoItem copyWith({
    int? id,
    String? title,
    String? category,
    String? subCategory,
    String? imagePath,
    String? targetTimeframe,
    String? motivationNotes,
    bool? isSpotlight,
    String? createdAt,
  }) {
    return OrigoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      imagePath: imagePath ?? this.imagePath,
      targetTimeframe: targetTimeframe ?? this.targetTimeframe,
      motivationNotes: motivationNotes ?? this.motivationNotes,
      isSpotlight: isSpotlight ?? this.isSpotlight,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'category': category,
      'sub_category': subCategory,
      'image_path': imagePath,
      'target_timeframe': targetTimeframe,
      'motivation_notes': motivationNotes,
      'is_spotlight': isSpotlight ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory OrigoItem.fromMap(Map<String, dynamic> map) {
    return OrigoItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      subCategory: map['sub_category'] as String?,
      imagePath: map['image_path'] as String,
      targetTimeframe: map['target_timeframe'] as String?,
      motivationNotes: map['motivation_notes'] as String?,
      isSpotlight: (map['is_spotlight'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String?,
    );
  }

  @override
  String toString() =>
      'OrigoItem(id: $id, title: $title, category: $category, subCategory: $subCategory, isSpotlight: $isSpotlight)';
}
