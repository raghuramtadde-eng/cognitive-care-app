import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/regional_theme_items.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_session.dart';
import '../../models/game_theme_item.dart';
import '../../models/patient.dart';
import '../../providers/game_provider.dart';
import '../../providers/patient_provider.dart';
import '../../theme/app_theme.dart';
import 'round_result_screen.dart';

/// Attention/pattern-recognition game: a grid of icons is memorized, hidden
/// briefly, then re-shown with exactly one icon changed. No side-by-side
/// photo pairs (which would need hand-authored art with known difference
/// coordinates) — this reuses the same procedurally-generated icon
/// approach as Memory Match, so difficulty scales with pure code, not art.
const _genericIconPool = <GameThemeItem>[
  GameThemeItem.icon(Icons.star, AppTheme.primary),
  GameThemeItem.icon(Icons.favorite, AppTheme.primary),
  GameThemeItem.icon(Icons.pets, AppTheme.primary),
  GameThemeItem.icon(Icons.local_florist, AppTheme.primary),
  GameThemeItem.icon(Icons.wb_sunny, AppTheme.primary),
  GameThemeItem.icon(Icons.umbrella, AppTheme.primary),
  GameThemeItem.icon(Icons.cake, AppTheme.primary),
  GameThemeItem.icon(Icons.music_note, AppTheme.primary),
  GameThemeItem.icon(Icons.home, AppTheme.primary),
  GameThemeItem.icon(Icons.anchor, AppTheme.primary),
  GameThemeItem.icon(Icons.eco, AppTheme.primary),
  GameThemeItem.icon(Icons.wb_cloudy, AppTheme.primary),
  GameThemeItem.icon(Icons.diamond, AppTheme.primary),
  GameThemeItem.icon(Icons.hexagon, AppTheme.primary),
  GameThemeItem.icon(Icons.bolt, AppTheme.primary),
  GameThemeItem.icon(Icons.circle, AppTheme.primary),
  GameThemeItem.icon(Icons.square, AppTheme.primary),
  GameThemeItem.icon(Icons.change_history, AppTheme.primary),
  GameThemeItem.icon(Icons.spa, AppTheme.primary),
  GameThemeItem.icon(Icons.icecream, AppTheme.primary),
];

/// Levels 1-2 stay exactly as before this feature existed; level 3+ adds
/// (never replaces) the patient's chosen cultural theme — see
/// regional_theme_items.dart for sourcing. Independent of the patient's UI
/// language (see patient.dart).
List<GameThemeItem> _poolForLevel(int level, CulturalTheme theme) => level >= 3
    ? [..._genericIconPool, ...regionalThemeSets[theme]!.matchAndSpotItems]
    : _genericIconPool;

const _trialsPerRound = 3;

int _gridSizeForLevel(int level) => switch (level) {
      1 => 4,
      2 => 6,
      3 => 9,
      4 => 12,
      _ => 16,
    };

int _colsForGridSize(int n) => switch (n) {
      4 => 2,
      6 => 3,
      9 => 3,
      _ => 4,
    };

enum _Phase { loading, memorize, hiddenGap, spot, feedback, done }

class SpotChangeScreen extends StatefulWidget {
  const SpotChangeScreen({super.key});

  @override
  State<SpotChangeScreen> createState() => _SpotChangeScreenState();
}

class _SpotChangeScreenState extends State<SpotChangeScreen> {
  int? _level;
  int _gridSize = 4;
  _Phase _phase = _Phase.loading;

  List<GameThemeItem> _icons = [];
  int _changedIndex = -1;
  int? _tappedIndex;
  int _trialIndex = 0;
  int _correctTrials = 0;
  final List<int> _responseTimes = [];
  final Stopwatch _stopwatch = Stopwatch();

  // Set once per trial by _prepareTrial(); revealed only after the patient
  // taps "I'm Ready" in _onReadyToSpot().
  List<GameThemeItem> _pendingIcons = [];
  GameThemeItem? _pendingChangeTo;
  int _pendingChangedIndex = -1;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final patient = context.read<PatientProvider>().activePatient!;
    final progress = await context
        .read<GameProvider>()
        .getOrCreateProgress(patient.id, GameType.spotChange);
    setState(() {
      _level = progress.currentLevel;
      _gridSize = _gridSizeForLevel(progress.currentLevel);
      _trialIndex = 0;
      _correctTrials = 0;
      _responseTimes.clear();
    });
    _prepareTrial();
  }

  /// Builds the next trial's picture and shows it for the patient to study,
  /// with no imposed countdown — same reasoning as Memory Match: a fixed
  /// timer that fits one patient on one day may not fit them on a harder
  /// day. They (or their caregiver) decide when to move on.
  void _prepareTrial() {
    final rand = Random();
    final culturalTheme = context.read<PatientProvider>().activePatient!.culturalTheme;
    final pool = _poolForLevel(_level!, culturalTheme).toList()..shuffle();
    setState(() {
      _pendingIcons = pool.take(_gridSize).toList();
      _pendingChangeTo = pool[_gridSize]; // guaranteed distinct from the grid
      _pendingChangedIndex = rand.nextInt(_gridSize);
      _icons = _pendingIcons;
      _tappedIndex = null;
      _phase = _Phase.memorize;
    });
  }

  Future<void> _onReadyToSpot() async {
    setState(() => _phase = _Phase.hiddenGap);
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {
      _changedIndex = _pendingChangedIndex;
      _icons = List.of(_pendingIcons)..[_pendingChangedIndex] = _pendingChangeTo!;
      _phase = _Phase.spot;
    });
    _stopwatch
      ..reset()
      ..start();
  }

  void _onTapTile(int index) {
    if (_phase != _Phase.spot) return;
    _stopwatch.stop();
    _responseTimes.add(_stopwatch.elapsedMilliseconds);
    final correct = index == _changedIndex;
    if (correct) _correctTrials++;

    setState(() {
      _tappedIndex = index;
      _phase = _Phase.feedback;
    });

    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_trialIndex + 1 >= _trialsPerRound) {
        _finishRound();
      } else {
        setState(() => _trialIndex++);
        _prepareTrial();
      }
    });
  }

  Future<void> _finishRound() async {
    setState(() => _phase = _Phase.done);
    final accuracy = _correctTrials / _trialsPerRound;
    final avgResponseTimeMs = _responseTimes.isEmpty
        ? 0
        : (_responseTimes.reduce((a, b) => a + b) / _responseTimes.length).round();
    final score = (_trialsPerRound * 100 * accuracy).round();

    final patient = context.read<PatientProvider>().activePatient!;
    final (session, decision) =
        await context.read<GameProvider>().recordRoundResult(
              patientId: patient.id,
              gameType: GameType.spotChange,
              playedAtLevel: _level!,
              score: score,
              accuracy: accuracy,
              avgResponseTimeMs: avgResponseTimeMs,
            );

    if (!mounted) return;
    // Capture the Navigator (and translated name) before pushReplacement
    // disposes this screen's context — reusing `context` afterward (as the
    // old onPlayAgain closure did) throws "deactivated widget" and silently
    // drops the tap.
    final navigator = Navigator.of(context);
    final gameName = AppLocalizations.of(context)!.gameSpotChange;
    navigator.pushReplacement(MaterialPageRoute(
      builder: (_) => RoundResultScreen(
        gameName: gameName,
        session: session,
        decision: decision,
        onPlayAgain: () => navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const SpotChangeScreen())),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_level == null || _phase == _Phase.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l10n = AppLocalizations.of(context)!;

    final statusText = switch (_phase) {
      _Phase.memorize => l10n.memorizePicturePrompt,
      _Phase.hiddenGap => l10n.getReady,
      _Phase.spot => l10n.whichOneChanged(_trialIndex + 1, _trialsPerRound),
      _Phase.feedback => _tappedIndex == _changedIndex ? l10n.correctExclaim : l10n.thatsNotIt,
      _ => '',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF3ECE0),
      appBar: AppBar(title: Text(l10n.spotChangeLevel(_level!))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6),
                ],
              ),
              child: Text(statusText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _phase == _Phase.hiddenGap
                  ? const Center(
                      child: Icon(Icons.help_outline, size: 64, color: Colors.black26))
                  : GridView.count(
                      crossAxisCount: _colsForGridSize(_gridSize),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: List.generate(_gridSize, (i) {
                        final isChangedReveal =
                            _phase == _Phase.feedback && i == _changedIndex;
                        final isWrongTap = _phase == _Phase.feedback &&
                            _tappedIndex == i &&
                            i != _changedIndex;
                        return GestureDetector(
                          onTap: () => _onTapTile(i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isChangedReveal
                                  ? AppTheme.success.withValues(alpha: 0.25)
                                  : (isWrongTap
                                      ? AppTheme.danger.withValues(alpha: 0.18)
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isChangedReveal
                                    ? AppTheme.success
                                    : (isWrongTap ? AppTheme.danger : AppTheme.primary),
                                width: isChangedReveal || isWrongTap ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Center(
                              child: _icons[i].glyph(size: 32, color: AppTheme.primary),
                            ),
                          ),
                        );
                      }),
                    ),
            ),
            if (_phase == _Phase.memorize) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _onReadyToSpot,
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text(l10n.imReady),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
