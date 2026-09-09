enum AlertType { missedReminder, gameDecline }

extension AlertTypeX on AlertType {
  String get key => name;
  static AlertType fromKey(String key) =>
      AlertType.values.firstWhere((e) => e.name == key);
}

/// A caregiver-facing notice that something may need attention: a routine
/// item that went unactioned well past its time, or a sudden, sharp drop in
/// a game's accuracy relative to the patient's own recent baseline. Kept
/// entirely separate from RoutineLog/GameSession -- this is a derived signal
/// for the caregiver dashboard, never something the patient-side screens or
/// the adaptive difficulty engine read back.
///
/// [sourceKey] + [date] together identify the specific occurrence that
/// triggered this alert (a routine item's id for a missed reminder, a game
/// type's key for a decline) so the same occurrence never generates more
/// than one alert row (enforced by a UNIQUE(patientId, sourceKey, date)
/// constraint at the DB layer, inserted with a conflict-ignore).
class CaregiverAlert {
  final String id;
  final String patientId;
  final AlertType type;
  final String title;
  final String message;
  final String sourceKey;
  final String date; // yyyy-MM-dd
  final String createdAt;
  final bool isRead;
  final bool isSynced;

  CaregiverAlert({
    required this.id,
    required this.patientId,
    required this.type,
    required this.title,
    required this.message,
    required this.sourceKey,
    required this.date,
    required this.createdAt,
    this.isRead = false,
    this.isSynced = false,
  });

  CaregiverAlert copyWith({bool? isRead, bool? isSynced}) {
    return CaregiverAlert(
      id: id,
      patientId: patientId,
      type: type,
      title: title,
      message: message,
      sourceKey: sourceKey,
      date: date,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'type': type.key,
      'title': title,
      'message': message,
      'sourceKey': sourceKey,
      'date': date,
      'createdAt': createdAt,
      'isRead': isRead ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory CaregiverAlert.fromMap(Map<String, dynamic> map) {
    return CaregiverAlert(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      type: AlertTypeX.fromKey(map['type'] as String),
      title: map['title'] as String,
      message: map['message'] as String,
      sourceKey: map['sourceKey'] as String,
      date: map['date'] as String,
      createdAt: map['createdAt'] as String,
      isRead: (map['isRead'] as int) == 1,
      isSynced: (map['isSynced'] as int) == 1,
    );
  }
}
