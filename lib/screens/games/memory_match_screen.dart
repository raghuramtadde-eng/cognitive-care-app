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

/// Themed card faces — a distinct color per icon so the board feels vivid
/// rather than a wall of identical teal squares. Memory Lane can later swap
/// this pool for personalized family photos on top of the same engine.
const _genericTheme = <GameThemeItem>[
  GameThemeItem.icon(Icons.star, Color(0xFFC9A227)),
  GameThemeItem.icon(Icons.favorite, Color(0xFFB3261E)),
  GameThemeItem.icon(Icons.pets, Color(0xFF8D6E63)),
  GameThemeItem.icon(Icons.local_florist, Color(0xFFE07A3E)),
  GameThemeItem.icon(Icons.wb_sunny, Color(0xFFF2A900)),
  GameThemeItem.icon(Icons.umbrella, Color(0xFF2D5F6B)),
  GameThemeItem.icon(Icons.cake, Color(0xFFD46A9F)),
  GameThemeItem.icon(Icons.music_note, Color(0xFF6A4C93)),
  GameThemeItem.icon(Icons.home, Color(0xFF2E7D4F)),
  GameThemeItem.icon(Icons.anchor, Color(0xFF1F6F78)),
  GameThemeItem.icon(Icons.eco, Color(0xFF3E8914)),
  GameThemeItem.icon(Icons.wb_cloudy, Color(0xFF5B7C99)),
];

/// Levels 1-2 stay exactly as before this feature existed; level 3+ adds
/// (never replaces) the patient's chosen cultural theme for variety as
/// they progress — see regional_theme_items.dart for sourcing. The theme
/// is independent of the patient's UI language (see patient.dart).
List<GameThemeItem> _themePoolForLevel(int level, CulturalTheme theme) => level >= 3
    ? [..._genericTheme, ...regionalThemeSets[theme]!.matchAndSpotItems]
    : _genericTheme;

int _pairsForLevel(int level) => switch (level) {
      1 => 3,
      2 => 4,
      3 => 6,
      4 => 7,
      _ => 8,
    };

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _CardModel {
  final int pairId;
  bool revealed = false;
  bool matched = false;
  _CardModel(this.pairId);
}

enum _Phase { loading, memorize, playing }

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  int? _level;
  List<_CardModel> _cards = [];
  List<int> _revealedIndices = [];
  int _attempts = 0;
  int _matchedPairs = 0;
  bool _busy = false;
  _Phase _phase = _Phase.loading;
  final Stopwatch _stopwatch = Stopwatch();
  List<GameThemeItem> _themeForRound = [];

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final patient = context.read<PatientProvider>().activePatient!;
    final progress = await context
        .read<GameProvider>()
        .getOrCreateProgress(patient.id, GameType.memoryMatch);
    final pairs = _pairsForLevel(progress.currentLevel);
    final theme = (_themePoolForLevel(progress.currentLevel, patient.culturalTheme).toList()
          ..shuffle())
        .take(pairs)
        .toList();
    final deck = <_CardModel>[];
    for (var i = 0; i < theme.length; i++) {
      deck.add(_CardModel(i));
      deck.add(_CardModel(i));
    }
    deck.shuffle(Random());
    setState(() {
      _level = progress.currentLevel;
      _cards = deck;
      _themeForRound = theme;
      _attempts = 0;
      _matchedPairs = 0;
      _revealedIndices = [];
      _phase = _Phase.memorize;
      for (final c in deck) {
        c.revealed = true;
      }
    });
    // No countdown here on purpose: a fixed timer that suits one patient on
    // one day could easily be too fast for the same patient on a harder
    // day. The patient (or their caregiver) decides when to proceed —
    // response time is still measured during the recall phase below, which
    // is what actually feeds the adaptive difficulty engine.
  }

  void _onReadyToPlay() {
    setState(() {
      for (final c in _cards) {
        c.revealed = false;
      }
      _phase = _Phase.playing;
    });
    _stopwatch
      ..reset()
      ..start();
  }

  void _onTapCard(int index) {
    if (_busy || _phase != _Phase.playing) return;
    final card = _cards[index];
    if (card.matched || card.revealed) return;

    setState(() {
      card.revealed = true;
      _revealedIndices.add(index);
    });

    if (_revealedIndices.length == 2) {
      _attempts++;
      final first = _cards[_revealedIndices[0]];
      final second = _cards[_revealedIndices[1]];
      _busy = true;
      if (first.pairId == second.pairId) {
        setState(() {
          first.matched = true;
          second.matched = true;
          _matchedPairs++;
          _revealedIndices = [];
          _busy = false;
        });
        if (_matchedPairs == _cards.length ~/ 2) {
          _finishRound();
        }
      } else {
        Timer(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          setState(() {
            first.revealed = false;
            second.revealed = false;
            _revealedIndices = [];
            _busy = false;
          });
        });
      }
    }
  }

  Future<void> _finishRound() async {
    _stopwatch.stop();
    final totalPairs = _cards.length ~/ 2;
    // Perfect play = attempts == totalPairs. Extra attempts reduce accuracy.
    final accuracy = (totalPairs / _attempts).clamp(0.0, 1.0);
    final avgResponseTimeMs = (_stopwatch.elapsedMilliseconds / _attempts).round();
    final score = (totalPairs * 100 * accuracy).round();

    final patient = context.read<PatientProvider>().activePatient!;
    final (session, decision) =
        await context.read<GameProvider>().recordRoundResult(
              patientId: patient.id,
              gameType: GameType.memoryMatch,
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
    final gameName = AppLocalizations.of(context)!.gameMemoryMatch;
    navigator.pushReplacement(MaterialPageRoute(
      builder: (_) => RoundResultScreen(
        gameName: gameName,
        session: session,
        decision: decision,
        onPlayAgain: () => navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const MemoryMatchScreen())),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_level == null || _phase == _Phase.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF3ECE0),
      appBar: AppBar(
        title: Text(l10n.memoryMatchLevel(_level!)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_phase == _Phase.memorize)
              const _MemorizeBanner()
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6),
                  ],
                ),
                child: Text(l10n.matchedPairs(_matchedPairs, _cards.length ~/ 2),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: _cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  final show = card.revealed || card.matched;
                  final item = _themeForRound[card.pairId];
                  return GestureDetector(
                    onTap: () => _onTapCard(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: show
                            ? null
                            : const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppTheme.primary, Color(0xFF1F4650)],
                              ),
                        color: card.matched
                            ? item.accentColor.withValues(alpha: 0.20)
                            : (show ? Colors.white : null),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: card.matched ? item.accentColor : AppTheme.primary,
                          width: card.matched ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: show
                            ? item.glyph(size: 34)
                            : const Icon(Icons.auto_awesome,
                                color: Colors.white70, size: 22),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_phase == _Phase.memorize) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _onReadyToPlay,
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text(l10n.readyStartMatching),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MemorizeBanner extends StatelessWidget {
  const _MemorizeBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.visibility_outlined, size: 32, color: AppTheme.accent),
          const SizedBox(height: 8),
          Text(l10n.memorizeCardsPrompt,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accent)),
          const SizedBox(height: 4),
          Text(l10n.tapWhenReady,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
