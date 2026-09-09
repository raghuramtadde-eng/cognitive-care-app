enum GameType { memoryMatch, sequenceRecall, spotChange }

extension GameTypeX on GameType {
  String get key => switch (this) {
        GameType.memoryMatch => 'memory_match',
        GameType.sequenceRecall => 'sequence_recall',
        GameType.spotChange => 'spot_change',
      };

  static GameType fromKey(String key) => switch (key) {
        'memory_match' => GameType.memoryMatch,
        'sequence_recall' => GameType.sequenceRecall,
        'spot_change' => GameType.spotChange,
        _ => throw ArgumentError('Unknown game type: $key'),
      };

  String get displayName => switch (this) {
        GameType.memoryMatch => 'Memory Match',
        GameType.sequenceRecall => 'Sequence Recall',
        GameType.spotChange => 'Spot the Change',
      };
}

/// One completed round of a game. This is the raw performance record that
/// both the adaptive difficulty engine and the caregiver dashboard read from.
class GameSession {
  final String id;
  final String patientId;
  final GameType gameType;
  final int difficultyLevel; // the level this round was PLAYED at
  final int score;
  final double accuracy; // 0.0 - 1.0
  final int avgResponseTimeMs;
  final String playedAt; // ISO8601
  final String updatedAt;
  final bool isSynced;

  GameSession({
    required this.id,
    required this.patientId,
    required this.gameType,
    required this.difficultyLevel,
    required this.score,
    required this.accuracy,
    required this.avgResponseTimeMs,
    required this.playedAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'gameType': gameType.key,
      'difficultyLevel': difficultyLevel,
      'score': score,
      'accuracy': accuracy,
      'avgResponseTimeMs': avgResponseTimeMs,
      'playedAt': playedAt,
      'updatedAt': updatedAt,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      gameType: GameTypeX.fromKey(map['gameType'] as String),
      difficultyLevel: map['difficultyLevel'] as int,
      score: map['score'] as int,
      accuracy: (map['accuracy'] as num).toDouble(),
      avgResponseTimeMs: map['avgResponseTimeMs'] as int,
      playedAt: map['playedAt'] as String,
      updatedAt: map['updatedAt'] as String,
      isSynced: (map['isSynced'] as int) == 1,
    );
  }
}
