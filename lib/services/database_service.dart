import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/caregiver_alert.dart';
import '../models/game_progress.dart';
import '../models/game_session.dart';
import '../models/memory_lane_item.dart';
import '../models/patient.dart';
import '../models/routine_item.dart';
import '../models/routine_log.dart';

/// Single source of truth for all on-device data. Every table carries
/// `updatedAt` + `isSynced` so the future Supabase sync engine (Phase 4) can
/// push/pull without any schema changes to earlier phases.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // Plain sqflite only talks to a real Android/iOS SQLite engine. On
    // Windows/Linux/macOS (used here for fast desktop dev/testing before
    // deploying to a tablet) we route through sqflite_common_ffi instead.
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cognitive_care.db');
    return openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v2 introduces caregiver-owned auth: every patient now belongs to a
      // caregiver account and is unlocked via a PIN instead of a bare UI
      // toggle. Existing dev/test patient rows have neither, so they default
      // to empty strings — expect to just recreate patients after this
      // upgrade rather than trying to "adopt" old test data.
      await db.execute(
          "ALTER TABLE patients ADD COLUMN caregiverId TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE patients ADD COLUMN pinHash TEXT NOT NULL DEFAULT ''");
    }
    if (oldVersion < 3) {
      // v3 turns Memory Lane into a personalized reminiscence feature
      // (place/date/story/song, plus soft engagement counters) instead of a
      // bare photo/habit list — see memory_lane_item.dart.
      await db.execute('ALTER TABLE memory_lane_items ADD COLUMN place TEXT');
      await db.execute('ALTER TABLE memory_lane_items ADD COLUMN memoryDate TEXT');
      await db.execute('ALTER TABLE memory_lane_items ADD COLUMN songLocalPath TEXT');
      await db.execute('ALTER TABLE memory_lane_items ADD COLUMN songRemoteUrl TEXT');
      await db.execute(
          'ALTER TABLE memory_lane_items ADD COLUMN viewCount INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE memory_lane_items ADD COLUMN presentedCount INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE memory_lane_items ADD COLUMN recognizedCount INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 4) {
      // v4 adds the daily-routine recall check-in: a separate memory
      // exercise ("did you do this today?") layered on top of the existing
      // Done/Missed record, not a replacement for it -- see
      // routine_recall_screen.dart and RoutineLog.recalledCorrectly.
      await db.execute('ALTER TABLE routine_logs ADD COLUMN recalledCorrectly INTEGER');
    }
    if (oldVersion < 5) {
      // v5 adds the caregiver alert system -- see caregiver_alert.dart and
      // alert_service.dart. A brand new table, so CREATE (not ALTER) here,
      // identical to the one in _onCreate below.
      await db.execute('''
        CREATE TABLE IF NOT EXISTS caregiver_alerts (
          id TEXT PRIMARY KEY,
          patientId TEXT NOT NULL,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          sourceKey TEXT NOT NULL,
          date TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          isRead INTEGER NOT NULL DEFAULT 0,
          isSynced INTEGER NOT NULL DEFAULT 0,
          UNIQUE(patientId, sourceKey, date)
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_alerts_patient ON caregiver_alerts(patientId, createdAt)');
    }
    if (oldVersion < 6) {
      // v6 adds a per-patient cultural/familiar theme for progressive game
      // content -- deliberately independent of `language` (see patient.dart
      // and regional_theme_items.dart), so it gets its own column rather
      // than being derived from the existing one.
      await db.execute(
          "ALTER TABLE patients ADD COLUMN culturalTheme TEXT NOT NULL DEFAULT 'general'");
    }
    if (oldVersion < 7) {
      // v7 replaces the PIN-only patient gate with a Patient User ID +
      // password login (see patient_login_screen.dart): a bare PIN gave no
      // way to tell two patients apart if a caregiver picked the same one
      // for both. `userId` is unique globally (see the UNIQUE index below
      // and is_patient_user_id_taken() in supabase_schema.sql), not just
      // per-caregiver, so it alone identifies the exact patient account.
      // `pinHash` is renamed rather than dropped -- it's the same salted
      // hash scheme, now storing a password hash instead of a PIN hash.
      await db.execute('ALTER TABLE patients RENAME COLUMN pinHash TO passwordHash');
      await db.execute("ALTER TABLE patients ADD COLUMN userId TEXT NOT NULL DEFAULT ''");
      await db.execute('ALTER TABLE patients ADD COLUMN sessionTokenHash TEXT');
      // Existing rows predate userId entirely -- backfill a placeholder
      // derived from their name + a slice of their own (already-unique) id,
      // so the UNIQUE index below can be created without data loss. A
      // caregiver can tell the patient apart by name in the Patients screen
      // regardless of this placeholder; done row-by-row in Dart (not a
      // single SQL UPDATE) to avoid fighting sqlite's string-escaping for
      // names that themselves contain a single quote.
      final legacyRows =
          await db.query('patients', columns: ['id', 'name'], where: "userId = ''");
      for (final row in legacyRows) {
        final id = row['id'] as String;
        final name = (row['name'] as String).toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
        final placeholder = '${name}_${id.substring(0, 6)}';
        await db.update('patients', {'userId': placeholder},
            where: 'id = ?', whereArgs: [id]);
      }
      await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_patients_user_id ON patients(userId)');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        caregiverId TEXT NOT NULL,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        language TEXT NOT NULL,
        culturalTheme TEXT NOT NULL DEFAULT 'general',
        photoPath TEXT,
        userId TEXT NOT NULL,
        passwordHash TEXT NOT NULL,
        sessionTokenHash TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_patients_caregiver ON patients(caregiverId)');
    await db.execute(
        'CREATE UNIQUE INDEX idx_patients_user_id ON patients(userId)');

    await db.execute('''
      CREATE TABLE game_sessions (
        id TEXT PRIMARY KEY,
        patientId TEXT NOT NULL,
        gameType TEXT NOT NULL,
        difficultyLevel INTEGER NOT NULL,
        score INTEGER NOT NULL,
        accuracy REAL NOT NULL,
        avgResponseTimeMs INTEGER NOT NULL,
        playedAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_sessions_patient_game ON game_sessions(patientId, gameType, playedAt)');

    await db.execute('''
      CREATE TABLE game_progress (
        patientId TEXT NOT NULL,
        gameType TEXT NOT NULL,
        currentLevel INTEGER NOT NULL,
        consecutiveGood INTEGER NOT NULL DEFAULT 0,
        consecutivePoor INTEGER NOT NULL DEFAULT 0,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (patientId, gameType)
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_items (
        id TEXT PRIMARY KEY,
        patientId TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        scheduledHour INTEGER NOT NULL,
        scheduledMinute INTEGER NOT NULL,
        active INTEGER NOT NULL DEFAULT 1,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_logs (
        id TEXT PRIMARY KEY,
        routineItemId TEXT NOT NULL,
        patientId TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        completedAt TEXT,
        recalledCorrectly INTEGER,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_routinelogs_patient_date ON routine_logs(patientId, date)');

    await db.execute('''
      CREATE TABLE memory_lane_items (
        id TEXT PRIMARY KEY,
        patientId TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        place TEXT,
        memoryDate TEXT,
        localPath TEXT,
        remoteUrl TEXT,
        songLocalPath TEXT,
        songRemoteUrl TEXT,
        viewCount INTEGER NOT NULL DEFAULT 0,
        presentedCount INTEGER NOT NULL DEFAULT 0,
        recognizedCount INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE caregiver_alerts (
        id TEXT PRIMARY KEY,
        patientId TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        sourceKey TEXT NOT NULL,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        isSynced INTEGER NOT NULL DEFAULT 0,
        UNIQUE(patientId, sourceKey, date)
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_alerts_patient ON caregiver_alerts(patientId, createdAt)');
  }

  // ---------------- Patients ----------------

  Future<void> upsertPatient(Patient patient) async {
    final db = await database;
    await db.insert('patients', patient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Patient>> getPatientsForCaregiver(String caregiverId) async {
    final db = await database;
    final rows = await db.query(
      'patients',
      where: 'caregiverId = ?',
      whereArgs: [caregiverId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(Patient.fromMap).toList();
  }

  Future<Patient?> getPatient(String id) async {
    final db = await database;
    final rows = await db.query('patients', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Patient.fromMap(rows.first);
  }

  /// Unscoped by caregiver -- userId is unique across every patient this
  /// device has ever cached (see the UNIQUE index in _onCreate/_onUpgrade),
  /// so this is a safe local pre-check when creating a patient offline (see
  /// PatientProvider.createPatient).
  Future<Patient?> getPatientByUserId(String userId) async {
    final db = await database;
    final rows = await db.query('patients', where: 'userId = ?', whereArgs: [userId]);
    if (rows.isEmpty) return null;
    return Patient.fromMap(rows.first);
  }

  // ---------------- Game sessions ----------------

  Future<void> insertGameSession(GameSession session) async {
    final db = await database;
    await db.insert('game_sessions', session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<GameSession>> getSessions(
    String patientId,
    GameType gameType, {
    int? limit,
  }) async {
    final db = await database;
    final rows = await db.query(
      'game_sessions',
      where: 'patientId = ? AND gameType = ?',
      whereArgs: [patientId, gameType.key],
      orderBy: 'playedAt DESC',
      limit: limit,
    );
    return rows.map(GameSession.fromMap).toList();
  }

  Future<List<GameSession>> getAllSessionsForPatient(String patientId) async {
    final db = await database;
    final rows = await db.query(
      'game_sessions',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'playedAt DESC',
    );
    return rows.map(GameSession.fromMap).toList();
  }

  // ---------------- Game progress (adaptive difficulty state) ----------------

  Future<GameProgress?> getProgress(String patientId, GameType gameType) async {
    final db = await database;
    final rows = await db.query(
      'game_progress',
      where: 'patientId = ? AND gameType = ?',
      whereArgs: [patientId, gameType.key],
    );
    if (rows.isEmpty) return null;
    return GameProgress.fromMap(rows.first);
  }

  Future<void> upsertProgress(GameProgress progress) async {
    final db = await database;
    await db.insert('game_progress', progress.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---------------- Routine items ----------------

  Future<void> upsertRoutineItem(RoutineItem item) async {
    final db = await database;
    await db.insert('routine_items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<RoutineItem>> getRoutineItems(String patientId) async {
    final db = await database;
    final rows = await db.query(
      'routine_items',
      where: 'patientId = ? AND active = 1',
      whereArgs: [patientId],
      orderBy: 'scheduledHour ASC, scheduledMinute ASC',
    );
    return rows.map(RoutineItem.fromMap).toList();
  }

  Future<void> deleteRoutineItem(String id) async {
    final db = await database;
    await db.delete('routine_items', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Routine logs ----------------

  Future<void> upsertRoutineLog(RoutineLog log) async {
    final db = await database;
    await db.insert('routine_logs', log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<RoutineLog>> getRoutineLogsForDate(
      String patientId, String date) async {
    final db = await database;
    final rows = await db.query(
      'routine_logs',
      where: 'patientId = ? AND date = ?',
      whereArgs: [patientId, date],
    );
    return rows.map(RoutineLog.fromMap).toList();
  }

  Future<List<RoutineLog>> getRoutineLogsInRange(
      String patientId, String startDate, String endDate) async {
    final db = await database;
    final rows = await db.query(
      'routine_logs',
      where: 'patientId = ? AND date >= ? AND date <= ?',
      whereArgs: [patientId, startDate, endDate],
      orderBy: 'date ASC',
    );
    return rows.map(RoutineLog.fromMap).toList();
  }

  // ---------------- Memory Lane ----------------

  Future<void> upsertMemoryLaneItem(MemoryLaneItem item) async {
    final db = await database;
    await db.insert('memory_lane_items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MemoryLaneItem>> getMemoryLaneItems(String patientId,
      {MemoryLaneType? type}) async {
    final db = await database;
    final rows = await db.query(
      'memory_lane_items',
      where: type == null ? 'patientId = ?' : 'patientId = ? AND type = ?',
      whereArgs: type == null ? [patientId] : [patientId, type.key],
      orderBy: 'createdAt DESC',
    );
    return rows.map(MemoryLaneItem.fromMap).toList();
  }

  Future<void> deleteMemoryLaneItem(String id) async {
    final db = await database;
    await db.delete('memory_lane_items', where: 'id = ?', whereArgs: [id]);
  }

  /// Soft engagement signal only (see memory_lane_item.dart) — bumps
  /// `viewCount` whenever the patient opens a memory card. Marks the row
  /// unsynced so the new count reaches the caregiver dashboard on next sync.
  Future<void> recordMemoryLaneView(String id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE memory_lane_items SET viewCount = viewCount + 1, '
      'updatedAt = ?, isSynced = 0 WHERE id = ?',
      [DateTime.now().toIso8601String(), id],
    );
  }

  /// Records one "Who is this?" attempt. Always increments `presentedCount`;
  /// increments `recognizedCount` too when the patient picked the right
  /// name. Never used to gate or slow anything down for the patient — purely
  /// a soft caregiver-dashboard signal.
  Future<void> recordMemoryLaneRecognitionAttempt(String id, {required bool recognized}) async {
    final db = await database;
    final recognizedDelta = recognized ? 'recognizedCount + 1' : 'recognizedCount';
    await db.rawUpdate(
      'UPDATE memory_lane_items SET presentedCount = presentedCount + 1, '
      'recognizedCount = $recognizedDelta, updatedAt = ?, isSynced = 0 WHERE id = ?',
      [DateTime.now().toIso8601String(), id],
    );
  }

  // ---------------- Caregiver alerts ----------------

  /// Silently does nothing if this exact occurrence (same patient + source +
  /// date) was already alerted on — see the UNIQUE constraint in
  /// caregiver_alerts. Lets [AlertService] re-run its checks freely (e.g. on
  /// every dashboard load) without needing to track what it already flagged.
  Future<void> insertAlertIfNew(CaregiverAlert alert) async {
    final db = await database;
    await db.insert('caregiver_alerts', alert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<CaregiverAlert>> getAlertsForPatient(String patientId,
      {int? limit}) async {
    final db = await database;
    final rows = await db.query(
      'caregiver_alerts',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return rows.map(CaregiverAlert.fromMap).toList();
  }

  Future<int> getUnreadAlertCount(String patientId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM caregiver_alerts WHERE patientId = ? AND isRead = 0',
      [patientId],
    );
    return (result.first['c'] as int?) ?? 0;
  }

  Future<void> markAlertRead(String id) async {
    final db = await database;
    await db.update('caregiver_alerts', {'isRead': 1, 'isSynced': 0},
        where: 'id = ?', whereArgs: [id]);
  }
}
