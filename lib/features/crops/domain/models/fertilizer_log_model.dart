import 'dart:convert';

/// Fertilizer Management Log Model
class FertilizerLogModel {
  final String id;
  final String cropId;
  final DateTime date;
  final String name;
  final String quantity;
  final DateTime? nextDate;
  final bool notify;

  FertilizerLogModel({
    required this.id,
    required this.cropId,
    required this.date,
    required this.name,
    required this.quantity,
    this.nextDate,
    this.notify = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'crop_id': cropId,
      'date': date.toIso8601String(),
      'name': name,
      'quantity': quantity,
      'next_date': nextDate?.toIso8601String(),
      'notify': notify ? 1 : 0,
    };
  }

  factory FertilizerLogModel.fromMap(Map<String, dynamic> map) {
    return FertilizerLogModel(
      id: map['id'] ?? '',
      cropId: map['crop_id'] ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? '',
      nextDate: map['next_date'] != null
          ? DateTime.tryParse(map['next_date'])
          : null,
      notify: (map['notify'] == 1 || map['notify'] == true),
    );
  }

  String toJson() => json.encode(toMap());

  factory FertilizerLogModel.fromJson(String source) =>
      FertilizerLogModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
