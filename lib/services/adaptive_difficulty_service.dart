import '../models/game_progress.dart';
import '../models/game_session.dart';

/// Why the difficulty did (or didn't) change on the last round. Kept as an
/// enum rather than a hardcoded English string here so the UI layer (which
/// has access to AppLocalizations) owns the actual translated wording —
/// this service has no BuildContext to translate with.
enum DifficultyReason {
  accuracyLow,
  excellentRound,
  twoStrongRounds,
  goodRound,
  twoWeakRounds,
  belowTargetRound,
  steadyPerformance,
}

/// Result of evaluating one just-completed round against the patient's
/// current progress. Screens apply this directly to update GameProgress.
class DifficultyDecision {
  final int newLevel;
  final int newConsecutiveGood;
  final int newConsecutivePoor;
  final DifficultyReason reason;

  DifficultyDecision({
    required this.newLevel,
    required this.newConsecutiveGood,
    required this.newConsecutivePoor,
    required this.reason,
  });
}

/// Rule-based adaptive difficulty engine shared by every cognitive game.
///
/// Design (deliberately explainable, not a black box — important for a
/// dementia-care product where caregivers need to trust why difficulty
/// changed): a round is scored as GOOD, POOR, or NEUTRAL from accuracy and
/// response time relative to the current level's expected pace. Level only
/// moves after two consecutive rounds agree, so a single lucky/unlucky round
/// never swings difficulty — but a single very strong or very weak round
/// (accuracy >= 0.95 or < 0.4) can act immediately, since that's a clear signal.
class AdaptiveDifficultyService {
  static const int minLevel = 1;
  static const int maxLevel = 5;

  /// Baseline expected response time per item at level 1, growing with level
  /// since harder levels have more items/steps to process.
  static int expectedResponseTimeMs(int level) => 4000 + (level - 1) * 800;

  static DifficultyDecision evaluate({
    required GameProgress currentProgress,
    required GameSession latestSession,
  }) {
    final level = currentProgress.currentLevel;
    final threshold = expectedResponseTimeMs(level);
    final accuracy = latestSession.accuracy;
    final speedOk = latestSession.avgResponseTimeMs <= threshold;

    // Immediate escalation on very poor performance — don't make a
    // struggling patient wait through a second bad round.
    if (accuracy < 0.4) {
      return DifficultyDecision(
        newLevel: _clamp(level - 1),
        newConsecutiveGood: 0,
        newConsecutivePoor: 0,
        reason: DifficultyReason.accuracyLow,
      );
    }

    // Immediate escalation on excellent performance.
    if (accuracy >= 0.95 && speedOk) {
      return DifficultyDecision(
        newLevel: _clamp(level + 1),
        newConsecutiveGood: 0,
        newConsecutivePoor: 0,
        reason: DifficultyReason.excellentRound,
      );
    }

    final isGood = accuracy >= 0.85 && speedOk;
    final isPoor = accuracy < 0.55;

    if (isGood) {
      final streak = currentProgress.consecutiveGood + 1;
      if (streak >= 2) {
        return DifficultyDecision(
          newLevel: _clamp(level + 1),
          newConsecutiveGood: 0,
          newConsecutivePoor: 0,
          reason: DifficultyReason.twoStrongRounds,
        );
      }
      return DifficultyDecision(
        newLevel: level,
        newConsecutiveGood: streak,
        newConsecutivePoor: 0,
        reason: DifficultyReason.goodRound,
      );
    }

    if (isPoor) {
      final streak = currentProgress.consecutivePoor + 1;
      if (streak >= 2) {
        return DifficultyDecision(
          newLevel: _clamp(level - 1),
          newConsecutiveGood: 0,
          newConsecutivePoor: 0,
          reason: DifficultyReason.twoWeakRounds,
        );
      }
      return DifficultyDecision(
        newLevel: level,
        newConsecutiveGood: 0,
        newConsecutivePoor: streak,
        reason: DifficultyReason.belowTargetRound,
      );
    }

    // Steady, unremarkable performance: hold level, reset streaks.
    return DifficultyDecision(
      newLevel: level,
      newConsecutiveGood: 0,
      newConsecutivePoor: 0,
      reason: DifficultyReason.steadyPerformance,
    );
  }

  static int _clamp(int level) =>
      level.clamp(minLevel, maxLevel).toInt();
}
