import 'dart:convert';

/// Irrigation Log Model for Irrigation Management & Reminders
class IrrigationLogModel {
  final String id;
  final String cropId;
  final DateTime date;
  final String time;
  final String amount;
  final String method; // e.g. Drip, Sprinkler, Manual
  final DateTime? nextDate;
  final bool notify;

  IrrigationLogModel({
    required this.id,
    required this.cropId,
    required this.date,
    this.time = '08:00 AM',
    required this.amount,
    this.method = 'Drip',
    this.nextDate,
    this.notify = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'crop_id': cropId,
      'date': date.toIso8601String(),
      'time': time,
      'amount': amount,
      'method': method,
      'next_date': nextDate?.toIso8601String(),
      'notify': notify ? 1 : 0,
    };
  }

  factory IrrigationLogModel.fromMap(Map<String, dynamic> map) {
    return IrrigationLogModel(
      id: map['id'] ?? '',
      cropId: map['crop_id'] ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      time: map['time'] ?? '08:00 AM',
      amount: map['amount'] ?? '',
      method: map['method'] ?? 'Drip',
      nextDate: map['next_date'] != null
          ? DateTime.tryParse(map['next_date'])
          : null,
      notify: (map['notify'] == 1 || map['notify'] == true),
    );
  }

  String toJson() => json.encode(toMap());

  factory IrrigationLogModel.fromJson(String source) =>
      IrrigationLogModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
