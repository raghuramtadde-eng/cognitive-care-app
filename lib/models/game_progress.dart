import 'game_session.dart';

/// The patient's CURRENT standing in one game — a fast-lookup cache derived
/// from GameSession history, updated by AdaptiveDifficultyService after every
/// round. GameSession rows remain the source of truth for history/trends.
class GameProgress {
  final String patientId;
  final GameType gameType;
  final int currentLevel;
  final int consecutiveGood;
  final int consecutivePoor;
  final String updatedAt;
  final bool isSynced;

  GameProgress({
    required this.patientId,
    required this.gameType,
    required this.currentLevel,
    this.consecutiveGood = 0,
    this.consecutivePoor = 0,
    required this.updatedAt,
    this.isSynced = false,
  });

  GameProgress copyWith({
    int? currentLevel,
    int? consecutiveGood,
    int? consecutivePoor,
    String? updatedAt,
    bool? isSynced,
  }) {
    return GameProgress(
      patientId: patientId,
      gameType: gameType,
      currentLevel: currentLevel ?? this.currentLevel,
      consecutiveGood: consecutiveGood ?? this.consecutiveGood,
      consecutivePoor: consecutivePoor ?? this.consecutivePoor,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'gameType': gameType.key,
      'currentLevel': currentLevel,
      'consecutiveGood': consecutiveGood,
      'consecutivePoor': consecutivePoor,
      'updatedAt': updatedAt,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory GameProgress.fromMap(Map<String, dynamic> map) {
    return GameProgress(
      patientId: map['patientId'] as String,
      gameType: GameTypeX.fromKey(map['gameType'] as String),
      currentLevel: map['currentLevel'] as int,
      consecutiveGood: map['consecutiveGood'] as int,
      consecutivePoor: map['consecutivePoor'] as int,
      updatedAt: map['updatedAt'] as String,
      isSynced: (map['isSynced'] as int) == 1,
    );
  }
}
