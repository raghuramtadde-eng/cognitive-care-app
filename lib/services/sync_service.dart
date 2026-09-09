import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'database_service.dart';
import 'memory_lane_storage_service.dart';

/// Push-based offline-first sync: the device is always the source of truth
/// for data entered on it. Whenever connectivity returns, every row marked
/// isSynced=0 gets upserted to the matching Supabase table, then flagged
/// synced locally. This is intentionally one-directional per row (no merge
/// conflicts to resolve) — good enough for a single-device-per-patient
/// prototype; multi-device pull-sync is a documented next step, not built
/// here to avoid unreliable conflict-resolution logic in the time available.
class SyncService {
  SyncService._internal();
  static final SyncService instance = SyncService._internal();

  final _db = DatabaseService.instance;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _syncing = false;

  SupabaseClient get _client => Supabase.instance.client;

  void startWatching() {
    _sub ??= Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        syncNow();
      }
    });
    // Also try once at startup in case connectivity is already available.
    syncNow();
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  Future<void> syncNow() async {
    if (_syncing) return;
    // Every row is RLS-scoped to whichever caregiver is authenticated —
    // nothing to push/pull correctly without an active session.
    if (_client.auth.currentSession == null) return;
    _syncing = true;
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return;

      // Guard against pre-auth dev/test rows with an empty caregiverId —
      // one bad row would otherwise fail the whole batch upsert.
      await _pushTable('patients', extraWhere: "caregiverId != ''");
      await _pushTable('game_sessions');
      await _pushTable('game_progress', compositeKeys: ['patientId', 'gameType']);
      await _pushTable('routine_items');
      await _pushTable('routine_logs');
      await _pushTable('caregiver_alerts');
      // Upload any pending photo/song files *before* pushing the row, so the
      // row that reaches Supabase already carries the resulting storage path.
      await MemoryLaneStorageService.instance.syncPendingUploads();
      await _pushTable('memory_lane_items',
          excludeColumns: ['localPath', 'songLocalPath']);
    } catch (e) {
      // Never surfaced to the user by design — the patient/caregiver-facing
      // flows never depend on network success, and syncNow() is retried on
      // every connectivity change and app start. Logged for debugging only.
      debugPrint('Sync failed (will retry later): $e');
    } finally {
      _syncing = false;
    }
  }

  Future<void> _pushTable(
    String table, {
    List<String>? compositeKeys,
    List<String> excludeColumns = const [],
    String? extraWhere,
  }) async {
    final db = await _db.database;
    final where = extraWhere == null ? 'isSynced = 0' : 'isSynced = 0 AND $extraWhere';
    final queried = await db.query(table, where: where, limit: 200);
    if (queried.isEmpty) return;

    // sqflite's query rows are unmodifiable maps — copy before excluding
    // columns, or `row.remove(...)` throws "Unsupported operation: read-only".
    final unsynced = [
      for (final row in queried) Map<String, Object?>.from(row)
    ];
    for (final column in excludeColumns) {
      for (final row in unsynced) {
        row.remove(column);
      }
    }

    await _client.from(table).upsert(unsynced);

    final batch = db.batch();
    for (final row in unsynced) {
      if (compositeKeys != null) {
        final where = compositeKeys.map((k) => '$k = ?').join(' AND ');
        final args = compositeKeys.map((k) => row[k]).toList();
        batch.update(table, {'isSynced': 1},
            where: where, whereArgs: args, conflictAlgorithm: ConflictAlgorithm.replace);
      } else {
        batch.update(table, {'isSynced': 1},
            where: 'id = ?', whereArgs: [row['id']]);
      }
    }
    await batch.commit(noResult: true);
  }
}
