import 'dart:convert';

/// Financial Record Model (Income / Expense / Harvest)
class FinancialRecordModel {
  final String id;
  final String cropId;
  final String type; // 'income' or 'expense'
  final DateTime date;
  final double amount;
  final String description;
  final String? yieldQuantity; // optional for harvest income (e.g. "250 kg")
  final String? notes;

  FinancialRecordModel({
    required this.id,
    required this.cropId,
    required this.type,
    required this.date,
    required this.amount,
    required this.description,
    this.yieldQuantity,
    this.notes,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'crop_id': cropId,
      'type': type,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
      'yield_quantity': yieldQuantity,
      'notes': notes,
    };
  }

  factory FinancialRecordModel.fromMap(Map<String, dynamic> map) {
    return FinancialRecordModel(
      id: map['id'] ?? '',
      cropId: map['crop_id'] ?? '',
      type: map['type'] ?? 'expense',
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      yieldQuantity: map['yield_quantity'],
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory FinancialRecordModel.fromJson(String source) =>
      FinancialRecordModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
