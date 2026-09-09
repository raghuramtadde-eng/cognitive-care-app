import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/caregiver_alert.dart';
import '../models/game_session.dart';
import '../models/routine_item.dart';
import '../models/routine_log.dart';
import 'database_service.dart';
import 'notification_service.dart';
import 'sync_service.dart';

final _dateFmt = DateFormat('yyyy-MM-dd');

String _routineTypeLabel(RoutineType type) => switch (type) {
      RoutineType.medicine => 'Medicine',
      RoutineType.hydration => 'Hydration',
      RoutineType.activity => 'Activity',
      RoutineType.appointment => 'Appointment',
    };

/// Detects the two caregiver-alert conditions this app watches for: a
/// routine item left unactioned well past its scheduled time, and a sudden,
/// sharp drop in a game's accuracy relative to the patient's own recent
/// baseline. Deliberately self-contained -- every check queries
/// DatabaseService directly rather than trusting a provider's in-memory
/// state, since that state may not be loaded yet depending on which screen
/// the caregiver or patient opened first (see routine_provider.dart's
/// recallEligibleItems and recallAccuracyOverLastDays for the same lesson
/// learned earlier in this feature's development).
class AlertService {
  AlertService._internal();
  static final AlertService instance = AlertService._internal();

  final _db = DatabaseService.instance;

  /// A routine item counts as alert-worthy once this long has passed its
  /// scheduled time today without being marked Done. Long enough that a
  /// caregiver stepping out briefly doesn't get paged, short enough to still
  /// be actionable the same day.
  static const _missedGracePeriod = Duration(hours: 1);

  /// How far below the patient's own recent-average accuracy a round has to
  /// fall to count as an "extreme decline" rather than normal variance.
  static const _declineDropThreshold = 0.3;
  static const _declineBaselineFloor = 0.5;
  static const _declineMinBaselineSessions = 3;

  int _notificationIdFor(String sourceKey, String date) =>
      '$sourceKey|$date'.hashCode & 0x7fffffff;

  Future<void> _raise(CaregiverAlert alert) async {
    await _db.insertAlertIfNew(alert);
    await NotificationService.instance.showNow(
      id: _notificationIdFor(alert.sourceKey, alert.date),
      title: alert.title,
      body: alert.message,
    );
    SyncService.instance.syncNow();
  }

  /// Call whenever routine data is loaded for a patient (Daily Routine,
  /// Recall Check-in, or the caregiver dashboard) -- cheap and idempotent,
  /// so there's no harm calling it from more than one screen.
  Future<void> checkMissedReminders(String patientId) async {
    final items = await _db.getRoutineItems(patientId);
    if (items.isEmpty) return;

    final now = DateTime.now();
    final today = _dateFmt.format(now);
    final logs = await _db.getRoutineLogsForDate(patientId, today);
    final logsByItemId = {for (final l in logs) l.routineItemId: l};

    for (final item in items) {
      final status = logsByItemId[item.id]?.status;
      if (status == RoutineStatus.done) continue;
      final scheduled = DateTime(
          now.year, now.month, now.day, item.scheduledHour, item.scheduledMinute);
      if (now.difference(scheduled) < _missedGracePeriod) continue;

      final hh = item.scheduledHour.toString().padLeft(2, '0');
      final mm = item.scheduledMinute.toString().padLeft(2, '0');
      await _raise(CaregiverAlert(
        id: const Uuid().v4(),
        patientId: patientId,
        type: AlertType.missedReminder,
        title: 'Missed reminder',
        message:
            '${item.title} (${_routineTypeLabel(item.type)}) was scheduled for '
            '$hh:$mm and still hasn\'t been marked done.',
        sourceKey: item.id,
        date: today,
        createdAt: now.toIso8601String(),
      ));
    }
  }

  /// Call right after a new game session is recorded. [recentSessions] must
  /// include the just-recorded session plus its predecessors, most recent
  /// first (i.e. exactly what GameProvider.history()/getSessions() already
  /// returns) -- this method does the excluding and averaging itself.
  Future<void> checkGameDecline({
    required String patientId,
    required GameSession latestSession,
    required List<GameSession> recentSessions,
  }) async {
    final baseline =
        recentSessions.where((s) => s.id != latestSession.id).toList();
    if (baseline.length < _declineMinBaselineSessions) return;

    final baselineAvg =
        baseline.map((s) => s.accuracy).reduce((a, b) => a + b) / baseline.length;
    final drop = baselineAvg - latestSession.accuracy;
    if (baselineAvg < _declineBaselineFloor || drop < _declineDropThreshold) return;

    final now = DateTime.now();
    final today = _dateFmt.format(now);
    final baselinePct = (baselineAvg * 100).round();
    final latestPct = (latestSession.accuracy * 100).round();

    await _raise(CaregiverAlert(
      id: const Uuid().v4(),
      patientId: patientId,
      type: AlertType.gameDecline,
      title: 'Accuracy drop in ${latestSession.gameType.displayName}',
      message: 'Latest round scored $latestPct% accuracy, down from a recent '
          'average of $baselinePct%.',
      sourceKey: latestSession.gameType.key,
      date: today,
      createdAt: now.toIso8601String(),
    ));
  }
}
