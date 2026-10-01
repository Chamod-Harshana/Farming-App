import 'dart:convert';

/// Crop Data Model for offline database storage and UI state.
class CropModel {
  final String id;
  final String name;
  final String nameSi;
  final String category;
  final String categorySi;
  final String iconName;
  final String imagePath;
  final String description;
  final String descriptionSi;
  final String soilType;
  final String soilTypeSi;
  final int harvestDays;
  final String waterFrequency;
  final String waterFrequencySi;
  final String idealTemp;
  final bool isPinned;
  final bool isDeleted;
  final DateTime createdAt;

  // New IoT / Management Metadata fields
  final DateTime? plantDate;
  final String landSize; // e.g., "2.5 Acres"
  final int plantCount;  // e.g., 500 plants/trees
  final String notes;     // Multi-line observations / diary notes

  CropModel({
    required this.id,
    required this.name,
    required this.nameSi,
    required this.category,
    required this.categorySi,
    required this.iconName,
    required this.imagePath,
    required this.description,
    required this.descriptionSi,
    required this.soilType,
    required this.soilTypeSi,
    required this.harvestDays,
    required this.waterFrequency,
    required this.waterFrequencySi,
    required this.idealTemp,
    this.isPinned = false,
    this.isDeleted = false,
    DateTime? createdAt,
    this.plantDate,
    this.landSize = '1.0 Acre',
    this.plantCount = 100,
    this.notes = '',
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a copy with modified fields
  CropModel copyWith({
    String? id,
    String? name,
    String? nameSi,
    String? category,
    String? categorySi,
    String? iconName,
    String? imagePath,
    String? description,
    String? descriptionSi,
    String? soilType,
    String? soilTypeSi,
    int? harvestDays,
    String? waterFrequency,
    String? waterFrequencySi,
    String? idealTemp,
    bool? isPinned,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? plantDate,
    String? landSize,
    int? plantCount,
    String? notes,
  }) {
    return CropModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameSi: nameSi ?? this.nameSi,
      category: category ?? this.category,
      categorySi: categorySi ?? this.categorySi,
      iconName: iconName ?? this.iconName,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      descriptionSi: descriptionSi ?? this.descriptionSi,
      soilType: soilType ?? this.soilType,
      soilTypeSi: soilTypeSi ?? this.soilTypeSi,
      harvestDays: harvestDays ?? this.harvestDays,
      waterFrequency: waterFrequency ?? this.waterFrequency,
      waterFrequencySi: waterFrequencySi ?? this.waterFrequencySi,
      idealTemp: idealTemp ?? this.idealTemp,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      plantDate: plantDate ?? this.plantDate,
      landSize: landSize ?? this.landSize,
      plantCount: plantCount ?? this.plantCount,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to Map for database persistence
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameSi': nameSi,
      'category': category,
      'categorySi': categorySi,
      'iconName': iconName,
      'imagePath': imagePath,
      'description': description,
      'descriptionSi': descriptionSi,
      'soilType': soilType,
      'soilTypeSi': soilTypeSi,
      'harvestDays': harvestDays,
      'waterFrequency': waterFrequency,
      'waterFrequencySi': waterFrequencySi,
      'idealTemp': idealTemp,
      'isPinned': isPinned ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'plantDate': plantDate?.toIso8601String(),
      'landSize': landSize,
      'plantCount': plantCount,
      'notes': notes,
    };
  }

  /// Factory constructor to construct CropModel from Database Map
  factory CropModel.fromMap(Map<String, dynamic> map) {
    return CropModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameSi: map['nameSi'] ?? '',
      category: map['category'] ?? '',
      categorySi: map['categorySi'] ?? '',
      iconName: map['iconName'] ?? 'eco',
      imagePath: map['imagePath'] ?? '',
      description: map['description'] ?? '',
      descriptionSi: map['descriptionSi'] ?? '',
      soilType: map['soilType'] ?? '',
      soilTypeSi: map['soilTypeSi'] ?? '',
      harvestDays: (map['harvestDays'] as num?)?.toInt() ?? 90,
      waterFrequency: map['waterFrequency'] ?? '',
      waterFrequencySi: map['waterFrequencySi'] ?? '',
      idealTemp: map['idealTemp'] ?? '',
      isPinned: (map['isPinned'] == 1 || map['isPinned'] == true),
      isDeleted: (map['isDeleted'] == 1 || map['isDeleted'] == true),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      plantDate: map['plantDate'] != null ? DateTime.tryParse(map['plantDate']) : null,
      landSize: map['landSize'] ?? '1.0 Acre',
      plantCount: (map['plantCount'] as num?)?.toInt() ?? 100,
      notes: map['notes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CropModel.fromJson(String source) =>
      CropModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
