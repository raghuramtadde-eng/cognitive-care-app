enum RoutineType { medicine, hydration, activity, appointment }

extension RoutineTypeX on RoutineType {
  String get key => name;
  static RoutineType fromKey(String key) =>
      RoutineType.values.firstWhere((e) => e.name == key);
}

/// A recurring daily reminder set up by the caregiver (e.g. "Morning tablet
/// at 8:00"). RoutineLog rows record whether each day's occurrence happened.
class RoutineItem {
  final String id;
  final String patientId;
  final RoutineType type;
  final String title;
  final int scheduledHour;
  final int scheduledMinute;
  final bool active;
  final String updatedAt;
  final bool isSynced;

  RoutineItem({
    required this.id,
    required this.patientId,
    required this.type,
    required this.title,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.active = true,
    required this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'type': type.key,
      'title': title,
      'scheduledHour': scheduledHour,
      'scheduledMinute': scheduledMinute,
      'active': active ? 1 : 0,
      'updatedAt': updatedAt,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory RoutineItem.fromMap(Map<String, dynamic> map) {
    return RoutineItem(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      type: RoutineTypeX.fromKey(map['type'] as String),
      title: map['title'] as String,
      scheduledHour: map['scheduledHour'] as int,
      scheduledMinute: map['scheduledMinute'] as int,
      active: (map['active'] as int) == 1,
      updatedAt: map['updatedAt'] as String,
      isSynced: (map['isSynced'] as int) == 1,
    );
  }
}
