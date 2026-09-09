import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/routine_item.dart';
import '../models/routine_log.dart';
import '../services/alert_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';

const _supportedLanguageCodes = {'en', 'as', 'mni'};

String _routineTypeName(AppLocalizations l10n, RoutineType type) => switch (type) {
      RoutineType.medicine => l10n.routineTypeMedicine,
      RoutineType.hydration => l10n.routineTypeHydration,
      RoutineType.activity => l10n.routineTypeActivity,
      RoutineType.appointment => l10n.routineTypeAppointment,
    };

final _dateFmt = DateFormat('yyyy-MM-dd');

/// Manages the patient's daily routine: the recurring reminders themselves
/// (RoutineItem) and each day's completion record (RoutineLog). Schedules
/// on-device notifications so reminders fire without internet.
class RoutineProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;
  final _notifications = NotificationService.instance;
  final _uuid = const Uuid();

  List<RoutineItem> _items = [];
  Map<String, RoutineLog> _todayLogsByItemId = {};

  List<RoutineItem> get items => _items;

  Future<void> loadForPatient(String patientId) async {
    _items = await _db.getRoutineItems(patientId);
    final today = _dateFmt.format(DateTime.now());
    final logs = await _db.getRoutineLogsForDate(patientId, today);
    _todayLogsByItemId = {for (final l in logs) l.routineItemId: l};
    notifyListeners();
    AlertService.instance.checkMissedReminders(patientId);
  }

  RoutineStatus statusFor(String routineItemId) =>
      _todayLogsByItemId[routineItemId]?.status ?? RoutineStatus.pending;

  /// Today's items whose scheduled time has already passed and that the
  /// patient hasn't already been asked about today -- the recall check-in
  /// only ever asks about things that could plausibly have happened
  /// already, never a reminder still hours away, and never repeats the
  /// same question again once answered until the next day's items reset.
  List<RoutineItem> get recallEligibleItems {
    final now = DateTime.now();
    return _items.where((item) {
      final scheduled = DateTime(
          now.year, now.month, now.day, item.scheduledHour, item.scheduledMinute);
      final alreadyAsked = _todayLogsByItemId[item.id]?.recalledCorrectly != null;
      return !scheduled.isAfter(now) && !alreadyAsked;
    }).toList();
  }

  Future<void> addRoutineItem({
    required String patientId,
    required String patientLanguage,
    required RoutineType type,
    required String title,
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now().toIso8601String();
    final item = RoutineItem(
      id: _uuid.v4(),
      patientId: patientId,
      type: type,
      title: title,
      scheduledHour: hour,
      scheduledMinute: minute,
      updatedAt: now,
    );
    await _db.upsertRoutineItem(item);
    // Baked in at schedule time, not read live at fire time -- there's no
    // widget tree (and so no ambient app locale) when a notification fires
    // while the app isn't running.
    final locale = Locale(
        _supportedLanguageCodes.contains(patientLanguage) ? patientLanguage : 'en');
    final l10n = await AppLocalizations.delegate.load(locale);
    await _notifications.scheduleDaily(
      routineItemId: item.id,
      title: l10n.reminderNotificationTitle(_routineTypeName(l10n, type)),
      body: title,
      hour: hour,
      minute: minute,
    );
    await loadForPatient(patientId);
    SyncService.instance.syncNow();
  }

  Future<void> removeRoutineItem(String patientId, String itemId) async {
    await _db.deleteRoutineItem(itemId);
    await _notifications.cancel(itemId);
    await loadForPatient(patientId);
  }

  Future<void> markStatus(
      String patientId, RoutineItem item, RoutineStatus status) async {
    final today = _dateFmt.format(DateTime.now());
    final now = DateTime.now().toIso8601String();
    final existing = _todayLogsByItemId[item.id];
    final log = RoutineLog(
      id: existing?.id ?? _uuid.v4(),
      routineItemId: item.id,
      patientId: patientId,
      date: today,
      status: status,
      completedAt: status == RoutineStatus.done ? now : null,
      updatedAt: now,
    );
    await _db.upsertRoutineLog(log);
    _todayLogsByItemId[item.id] = log;
    notifyListeners();
    SyncService.instance.syncNow();
  }

  /// Records whether the patient correctly recalled having done (or not
  /// done) this item today -- a memory check layered on top of the existing
  /// Done/Missed record, never a replacement for it. If nothing was logged
  /// yet today, an implicit "not done" (pending) log is created first so
  /// there's something for the recall to be compared against and stored on.
  Future<bool> recordRecall(String patientId, RoutineItem item,
      {required bool patientSaysDone}) async {
    final today = _dateFmt.format(DateTime.now());
    final now = DateTime.now().toIso8601String();
    final existing = _todayLogsByItemId[item.id];
    final actualStatus = existing?.status ?? RoutineStatus.pending;
    final actuallyDone = actualStatus == RoutineStatus.done;
    final wasCorrect = patientSaysDone == actuallyDone;

    final log = (existing ??
            RoutineLog(
              id: _uuid.v4(),
              routineItemId: item.id,
              patientId: patientId,
              date: today,
              status: RoutineStatus.pending,
              updatedAt: now,
            ))
        .copyWith(recalledCorrectly: wasCorrect, updatedAt: now);

    await _db.upsertRoutineLog(log);
    _todayLogsByItemId[item.id] = log;
    notifyListeners();
    SyncService.instance.syncNow();
    return actuallyDone;
  }

  /// Adherence over the last [days] days: fraction of scheduled items marked
  /// done vs missed (pending-and-past isn't counted against them yet).
  Future<RoutineAdherence> adherenceOverLastDays(
      String patientId, int days) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days - 1));
    final logs = await _db.getRoutineLogsInRange(
        patientId, _dateFmt.format(start), _dateFmt.format(end));
    final done = logs.where((l) => l.status == RoutineStatus.done).length;
    final missed = logs.where((l) => l.status == RoutineStatus.missed).length;
    final total = done + missed;
    return RoutineAdherence(
      done: done,
      missed: missed,
      adherenceRate: total == 0 ? 1.0 : done / total,
    );
  }

  /// How often the patient's own memory of "did I do this?" matched what
  /// was actually logged, over the last [days] days -- a caregiver-facing
  /// view of [recordRecall]'s data, kept separate from adherence above since
  /// forgetting you did something is a different signal than not doing it.
  /// Queries routine items directly rather than relying on [_items], since
  /// this can be opened from the caregiver dashboard without the patient
  /// side ever having called [loadForPatient] for this patient in this
  /// provider instance.
  Future<RecallAccuracy> recallAccuracyOverLastDays(
      String patientId, int days) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days - 1));
    final logs = await _db.getRoutineLogsInRange(
        patientId, _dateFmt.format(start), _dateFmt.format(end));
    final answered = logs.where((l) => l.recalledCorrectly != null).toList();
    final correct = answered.where((l) => l.recalledCorrectly == true).length;
    final mismatchLogs = answered.where((l) => l.recalledCorrectly == false).toList();
    Map<String, String> titlesById = {};
    if (mismatchLogs.isNotEmpty) {
      final items = await _db.getRoutineItems(patientId);
      titlesById = {for (final item in items) item.id: item.title};
    }
    final mismatches = mismatchLogs
        .map((l) => RecallMismatch(
              itemTitle: titlesById[l.routineItemId] ?? l.routineItemId,
              date: l.date,
              actualStatus: l.status,
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return RecallAccuracy(
      answered: answered.length,
      correct: correct,
      mismatches: mismatches.take(5).toList(),
    );
  }
}

class RoutineAdherence {
  final int done;
  final int missed;
  final double adherenceRate;
  RoutineAdherence(
      {required this.done, required this.missed, required this.adherenceRate});
}

class RecallMismatch {
  final String itemTitle;
  final String date; // yyyy-MM-dd
  final RoutineStatus actualStatus;
  RecallMismatch(
      {required this.itemTitle, required this.date, required this.actualStatus});
}

class RecallAccuracy {
  final int answered;
  final int correct;
  final List<RecallMismatch> mismatches;
  RecallAccuracy(
      {required this.answered, required this.correct, required this.mismatches});
}
