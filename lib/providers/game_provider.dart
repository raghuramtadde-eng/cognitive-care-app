import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/game_progress.dart';
import '../models/game_session.dart';
import '../services/adaptive_difficulty_service.dart';
import '../services/alert_service.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

/// Coordinates gameplay results with the adaptive difficulty engine and
/// local storage. Every game screen (Memory Match, Sequence Recall, and any
/// future game) goes through this same provider, so difficulty logic and
/// persistence are never duplicated per-game.
class GameProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  final Map<String, GameProgress> _progressCache = {};

  String _key(String patientId, GameType type) => '$patientId::${type.key}';

  /// Fetches (creating if needed) the current difficulty progress for a
  /// patient+game. Call before starting a round to know what level to render.
  Future<GameProgress> getOrCreateProgress(
      String patientId, GameType gameType) async {
    final cacheKey = _key(patientId, gameType);
    final cached = _progressCache[cacheKey];
    if (cached != null) return cached;

    var progress = await _db.getProgress(patientId, gameType);
    if (progress == null) {
      progress = GameProgress(
        patientId: patientId,
        gameType: gameType,
        currentLevel: AdaptiveDifficultyService.minLevel,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _db.upsertProgress(progress);
    }
    _progressCache[cacheKey] = progress;
    return progress;
  }

  /// Call when a round finishes. Persists the raw session, runs the adaptive
  /// engine, persists the updated progress, and returns both so the UI can
  /// show "difficulty increased!" feedback.
  Future<(GameSession, DifficultyDecision)> recordRoundResult({
    required String patientId,
    required GameType gameType,
    required int playedAtLevel,
    required int score,
    required double accuracy,
    required int avgResponseTimeMs,
  }) async {
    final now = DateTime.now().toIso8601String();
    final session = GameSession(
      id: _uuid.v4(),
      patientId: patientId,
      gameType: gameType,
      difficultyLevel: playedAtLevel,
      score: score,
      accuracy: accuracy,
      avgResponseTimeMs: avgResponseTimeMs,
      playedAt: now,
      updatedAt: now,
    );
    await _db.insertGameSession(session);

    final currentProgress = await getOrCreateProgress(patientId, gameType);
    final decision = AdaptiveDifficultyService.evaluate(
      currentProgress: currentProgress,
      latestSession: session,
    );

    final updatedProgress = currentProgress.copyWith(
      currentLevel: decision.newLevel,
      consecutiveGood: decision.newConsecutiveGood,
      consecutivePoor: decision.newConsecutivePoor,
      updatedAt: now,
      isSynced: false,
    );
    await _db.upsertProgress(updatedProgress);
    _progressCache[_key(patientId, gameType)] = updatedProgress;

    notifyListeners();
    SyncService.instance.syncNow();

    final recentSessions = await _db.getSessions(patientId, gameType, limit: 6);
    AlertService.instance.checkGameDecline(
      patientId: patientId,
      latestSession: session,
      recentSessions: recentSessions,
    );

    return (session, decision);
  }

  Future<List<GameSession>> history(String patientId, GameType gameType,
      {int? limit}) {
    return _db.getSessions(patientId, gameType, limit: limit);
  }

  Future<List<GameSession>> allHistory(String patientId) {
    return _db.getAllSessionsForPatient(patientId);
  }
}
