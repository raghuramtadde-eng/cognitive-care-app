import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/game_session.dart';
import '../../services/adaptive_difficulty_service.dart';
import '../../theme/app_theme.dart';

String _reasonText(AppLocalizations l10n, DifficultyReason reason) => switch (reason) {
      DifficultyReason.accuracyLow => l10n.reasonAccuracyLow,
      DifficultyReason.excellentRound => l10n.reasonExcellentRound,
      DifficultyReason.twoStrongRounds => l10n.reasonTwoStrongRounds,
      DifficultyReason.goodRound => l10n.reasonGoodRound,
      DifficultyReason.twoWeakRounds => l10n.reasonTwoWeakRounds,
      DifficultyReason.belowTargetRound => l10n.reasonBelowTargetRound,
      DifficultyReason.steadyPerformance => l10n.reasonSteadyPerformance,
    };

/// Shared "round finished" feedback screen for every game — shows score,
/// accuracy, and, importantly, an honest explanation of any difficulty
/// change so caregivers/patients can see the adaptive system reasoning.
class RoundResultScreen extends StatelessWidget {
  final String gameName;
  final GameSession session;
  final DifficultyDecision decision;
  final VoidCallback onPlayAgain;

  const RoundResultScreen({
    super.key,
    required this.gameName,
    required this.session,
    required this.decision,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final leveledUp = decision.newLevel > session.difficultyLevel;
    final leveledDown = decision.newLevel < session.difficultyLevel;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.roundComplete(gameName))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              leveledUp
                  ? Icons.trending_up
                  : (leveledDown ? Icons.trending_down : Icons.emoji_events),
              size: 72,
              color: leveledUp
                  ? AppTheme.success
                  : (leveledDown ? AppTheme.warning : AppTheme.accent),
            ),
            const SizedBox(height: 20),
            Text(l10n.scoreLabel(session.score),
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(l10n.accuracyLabel((session.accuracy * 100).round()),
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (leveledUp)
                      Text(l10n.difficultyIncreased,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.success))
                    else if (leveledDown)
                      Text(l10n.difficultyDecreased,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warning))
                    else
                      Text(l10n.difficultySame,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(_reasonText(l10n, decision.reason),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onPlayAgain,
              child: Text(l10n.playAgain),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context)
                  .popUntil((route) => route.isFirst),
              child: Text(l10n.backToHome,
                  style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
