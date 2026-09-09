enum RoutineStatus { pending, done, missed }

extension RoutineStatusX on RoutineStatus {
  String get key => name;
  static RoutineStatus fromKey(String key) =>
      RoutineStatus.values.firstWhere((e) => e.name == key);
}

/// One day's occurrence of a RoutineItem, e.g. "8:00 tablet for 2026-09-04".
class RoutineLog {
  final String id;
  final String routineItemId;
  final String patientId;
  final String date; // yyyy-MM-dd
  final RoutineStatus status;
  final String? completedAt;
  // Null = the patient hasn't been asked to recall this one yet today; the
  // recall exercise is a separate memory check on top of the caregiver's own
  // Done/Missed record (statuses above), never something that overrides it
  // (see routine_recall_screen.dart) -- so a caregiver dashboard can later
  // show recall accuracy as its own soft trend, same spirit as Memory Lane's
  // recognizedCount, without conflating "did it happen" with "did they
  // remember it happening".
  final bool? recalledCorrectly;
  final String updatedAt;
  final bool isSynced;

  RoutineLog({
    required this.id,
    required this.routineItemId,
    required this.patientId,
    required this.date,
    required this.status,
    this.completedAt,
    this.recalledCorrectly,
    required this.updatedAt,
    this.isSynced = false,
  });

  RoutineLog copyWith({
    RoutineStatus? status,
    String? completedAt,
    bool? recalledCorrectly,
    String? updatedAt,
    bool? isSynced,
  }) {
    return RoutineLog(
      id: id,
      routineItemId: routineItemId,
      patientId: patientId,
      date: date,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      recalledCorrectly: recalledCorrectly ?? this.recalledCorrectly,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routineItemId': routineItemId,
      'patientId': patientId,
      'date': date,
      'status': status.key,
      'completedAt': completedAt,
      'recalledCorrectly':
          recalledCorrectly == null ? null : (recalledCorrectly! ? 1 : 0),
      'updatedAt': updatedAt,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory RoutineLog.fromMap(Map<String, dynamic> map) {
    return RoutineLog(
      id: map['id'] as String,
      routineItemId: map['routineItemId'] as String,
      patientId: map['patientId'] as String,
      date: map['date'] as String,
      status: RoutineStatusX.fromKey(map['status'] as String),
      completedAt: map['completedAt'] as String?,
      recalledCorrectly: (map['recalledCorrectly'] as int?) == null
          ? null
          : (map['recalledCorrectly'] as int) == 1,
      updatedAt: map['updatedAt'] as String,
      isSynced: (map['isSynced'] as int) == 1,
    );
  }
}
