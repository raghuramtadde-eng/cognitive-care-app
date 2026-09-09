import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'database_service.dart';

/// Uploads Memory Lane photos/songs to the private `memory-lane` Storage
/// bucket, and downloads them back down when a local copy is missing (e.g.
/// after a reinstall). Kept separate from sync_service.dart's generic
/// row-level push because binary upload/download is a different shape of
/// work than upserting table rows — SyncService.syncNow() calls into this
/// as one more step, so retry-on-reconnect keeps working the same way it
/// already does for every other table.
///
/// `remoteUrl`/`songRemoteUrl` store the object's *path within the bucket*
/// (e.g. `patientId/itemId_photo.jpg`), not a public URL — the bucket is
/// private, so every read/write goes through the authenticated client and is
/// gated by the same owns_patient() Storage policies as every other patient
/// record (see supabase_schema.sql).
class MemoryLaneStorageService {
  MemoryLaneStorageService._internal();
  static final MemoryLaneStorageService instance = MemoryLaneStorageService._internal();

  static const _bucket = 'memory-lane';

  SupabaseClient get _client => Supabase.instance.client;

  /// Uploads any photo/song that has a local file but no remote path yet.
  /// Safe to call repeatedly — already-uploaded items are skipped, and a
  /// failed upload just gets retried on the next call (e.g. next connectivity
  /// change) since `remoteUrl`/`songRemoteUrl` stays null until it succeeds.
  Future<void> syncPendingUploads() async {
    final db = await DatabaseService.instance.database;

    final photoRows = await db.query('memory_lane_items',
        where: 'localPath IS NOT NULL AND remoteUrl IS NULL');
    for (final row in photoRows) {
      await _uploadOne(
        itemId: row['id'] as String,
        patientId: row['patientId'] as String,
        localPath: row['localPath'] as String,
        column: 'remoteUrl',
        suffix: 'photo',
      );
    }

    final songRows = await db.query('memory_lane_items',
        where: 'songLocalPath IS NOT NULL AND songRemoteUrl IS NULL');
    for (final row in songRows) {
      await _uploadOne(
        itemId: row['id'] as String,
        patientId: row['patientId'] as String,
        localPath: row['songLocalPath'] as String,
        column: 'songRemoteUrl',
        suffix: 'song',
      );
    }
  }

  Future<void> _uploadOne({
    required String itemId,
    required String patientId,
    required String localPath,
    required String column,
    required String suffix,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return;
      final ext = p.extension(localPath);
      // Deterministic (not random) so a retry after a dropped connection
      // overwrites the same object instead of piling up duplicates.
      final storagePath = '$patientId/${itemId}_$suffix$ext';
      await _client.storage.from(_bucket).upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final db = await DatabaseService.instance.database;
      await db.update(
        'memory_lane_items',
        {column: storagePath, 'updatedAt': DateTime.now().toIso8601String(), 'isSynced': 0},
        where: 'id = ?',
        whereArgs: [itemId],
      );
    } catch (e) {
      // Never surfaced to the user — same "retried on next sync" contract
      // as the rest of SyncService.
      debugPrint('Memory Lane upload failed (will retry later): $e');
    }
  }

  /// Returns a local file path for this item's photo, downloading it from
  /// Storage first if the local copy is missing. Returns null if there's
  /// neither a local file nor a remote one to fall back to, or the download
  /// fails (e.g. offline) — callers already handle a null path by showing a
  /// placeholder icon.
  Future<String?> ensureLocalPhoto({
    required String itemId,
    required String? localPath,
    required String? remotePath,
  }) =>
      _ensureLocal(itemId: itemId, localPath: localPath, remotePath: remotePath, column: 'localPath');

  Future<String?> ensureLocalSong({
    required String itemId,
    required String? localPath,
    required String? remotePath,
  }) =>
      _ensureLocal(
          itemId: itemId, localPath: localPath, remotePath: remotePath, column: 'songLocalPath');

  Future<String?> _ensureLocal({
    required String itemId,
    required String? localPath,
    required String? remotePath,
    required String column,
  }) async {
    if (localPath != null && await File(localPath).exists()) return localPath;
    if (remotePath == null) return null;
    try {
      final bytes = await _client.storage.from(_bucket).download(remotePath);
      final docsDir = await getApplicationDocumentsDirectory();
      final memoryDir = Directory(p.join(docsDir.path, 'memory_lane'));
      if (!await memoryDir.exists()) await memoryDir.create(recursive: true);
      final destPath = p.join(memoryDir.path, p.basename(remotePath));
      await File(destPath).writeAsBytes(bytes);

      final db = await DatabaseService.instance.database;
      await db.update('memory_lane_items', {column: destPath},
          where: 'id = ?', whereArgs: [itemId]);
      return destPath;
    } catch (e) {
      debugPrint('Memory Lane download failed (offline?): $e');
      return null;
    }
  }
}
