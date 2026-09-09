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
import 'round_result_screen.dart';

/// Each tile pairs a color with an icon (not color alone) so the game stays
/// usable for colorblind patients and reads as a themed, designed board
/// rather than a plain Simon clone.
const _genericTileThemes = <GameThemeItem>[
  GameThemeItem.icon(Icons.circle, Color(0xFFB3261E)),
  GameThemeItem.icon(Icons.square, Color(0xFF2D5F6B)),
  GameThemeItem.icon(Icons.star, Color(0xFF2E7D4F)),
  GameThemeItem.icon(Icons.favorite, Color(0xFFC9A227)),
  GameThemeItem.icon(Icons.change_history, Color(0xFF6A4C93)),
  GameThemeItem.icon(Icons.diamond, Color(0xFFE07A3E)),
  GameThemeItem.icon(Icons.hexagon, Color(0xFF1F6F78)),
  GameThemeItem.icon(Icons.bolt, Color(0xFF8D6E63)),
];

/// Levels 1-3 stay exactly as before this feature existed. Level 4+ swaps
/// to a themed re-skin (not an addition — the board already uses all 8
/// tiles at max level) built around the patient's chosen cultural theme —
/// see regional_theme_items.dart for sourcing. Independent of the
/// patient's UI language (see patient.dart).
List<GameThemeItem> _tileThemesForLevel(int level, CulturalTheme theme) =>
    level >= 4 ? regionalThemeSets[theme]!.sequenceItems : _genericTileThemes;

int _lengthForLevel(int level) => switch (level) {
      1 => 3,
      2 => 4,
      3 => 5,
      4 => 6,
      _ => 7,
    };

/// More tiles on screen at higher levels — genuine "distractors" (more
/// visually-similar choices to pick correctly from) rather than a
/// gotcha-tap mechanic, keeping the no-wrong-answers-punished ethos intact.
int _tileCountForLevel(int level) => switch (level) {
      1 || 2 => 4,
      3 || 4 => 6,
      _ => 8,
    };

int _flashMsForLevel(int level) => (800 - (level - 1) * 100).clamp(400, 800);

enum _Phase { loading, showing, input, done }

class SequenceRecallScreen extends StatefulWidget {
  const SequenceRecallScreen({super.key});

  @override
  State<SequenceRecallScreen> createState() => _SequenceRecallScreenState();
}

class _SequenceRecallScreenState extends State<SequenceRecallScreen> {
  int? _level;
  int _tileCount = 4;
  List<int> _sequence = [];
  int _highlightedTile = -1;
  _Phase _phase = _Phase.loading;
  final List<int> _userTaps = [];
  final List<int> _tapResponseTimes = [];
  final Stopwatch _sinceLastPrompt = Stopwatch();

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final patient = context.read<PatientProvider>().activePatient!;
    final progress = await context
        .read<GameProvider>()
        .getOrCreateProgress(patient.id, GameType.sequenceRecall);
    final length = _lengthForLevel(progress.currentLevel);
    final tileCount = _tileCountForLevel(progress.currentLevel);
    final rand = Random();
    setState(() {
      _level = progress.currentLevel;
      _tileCount = tileCount;
      _sequence = List.generate(length, (_) => rand.nextInt(tileCount));
      _userTaps.clear();
      _tapResponseTimes.clear();
      _phase = _Phase.showing;
    });
    await _playSequence();
  }

  Future<void> _playSequence() async {
    final flashMs = _flashMsForLevel(_level!);
    for (final tile in _sequence) {
      if (!mounted) return;
      setState(() => _highlightedTile = tile);
      await Future.delayed(Duration(milliseconds: flashMs));
      if (!mounted) return;
      setState(() => _highlightedTile = -1);
      await Future.delayed(const Duration(milliseconds: 250));
    }
    if (!mounted) return;
    setState(() => _phase = _Phase.input);
    _sinceLastPrompt
      ..reset()
      ..start();
  }

  void _onTapTile(int tileIndex) {
    if (_phase != _Phase.input) return;
    _tapResponseTimes.add(_sinceLastPrompt.elapsedMilliseconds);
    _sinceLastPrompt
      ..reset()
      ..start();
    setState(() {
      _userTaps.add(tileIndex);
    });
    if (_userTaps.length == _sequence.length) {
      _sinceLastPrompt.stop();
      _finishRound();
    }
  }

  Future<void> _finishRound() async {
    setState(() => _phase = _Phase.done);
    int correct = 0;
    for (var i = 0; i < _sequence.length; i++) {
      if (_userTaps[i] == _sequence[i]) correct++;
    }
    final accuracy = correct / _sequence.length;
    final avgResponseTimeMs = _tapResponseTimes.isEmpty
        ? 0
        : (_tapResponseTimes.reduce((a, b) => a + b) / _tapResponseTimes.length)
            .round();
    final score = (_sequence.length * 100 * accuracy).round();

    final patient = context.read<PatientProvider>().activePatient!;
    final (session, decision) =
        await context.read<GameProvider>().recordRoundResult(
              patientId: patient.id,
              gameType: GameType.sequenceRecall,
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
    final gameName = AppLocalizations.of(context)!.gameSequenceRecall;
    navigator.pushReplacement(MaterialPageRoute(
      builder: (_) => RoundResultScreen(
        gameName: gameName,
        session: session,
        decision: decision,
        onPlayAgain: () => navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const SequenceRecallScreen())),
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
      _Phase.showing => l10n.watchThePattern,
      _Phase.input => l10n.yourTurnTap(_userTaps.length + 1, _sequence.length),
      _ => '',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF3ECE0),
      appBar: AppBar(title: Text(l10n.sequenceRecallLevel(_level!))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: List.generate(_tileCount, (i) {
                  final isLit = _highlightedTile == i;
                  final culturalTheme = context.read<PatientProvider>().activePatient!.culturalTheme;
                  final item = _tileThemesForLevel(_level!, culturalTheme)[i];
                  final color = item.accentColor;
                  return GestureDetector(
                    onTap: () => _onTapTile(i),
                    child: AnimatedScale(
                      scale: isLit ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isLit ? color : color.withValues(alpha: 0.30),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isLit
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.6),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  )
                                ]
                              : [],
                        ),
                        child: Center(
                          child: item.glyph(
                              size: 32,
                              color: isLit ? Colors.white : color.withValues(alpha: 0.6)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
