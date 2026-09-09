import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/memory_lane_item.dart';
import '../providers/patient_provider.dart';
import '../services/database_service.dart';
import '../services/memory_lane_storage_service.dart';
import '../services/sync_service.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';

/// What the patient actually sees for Memory Lane: a warm, simple browse of
/// caregiver-added memories — one at a time, no scoring, no adaptive
/// difficulty. The optional "Who is this?" prompt on each card is a gentle
/// validation moment, never a test: a wrong guess is revealed with the same
/// warmth as a right one, and nothing here ever feeds the cognitive games'
/// difficulty engine (see adaptive_difficulty_service.dart) — only soft
/// view/recognition counters surface on the caregiver dashboard.
class MemoryLanePatientScreen extends StatefulWidget {
  const MemoryLanePatientScreen({super.key});

  @override
  State<MemoryLanePatientScreen> createState() => _MemoryLanePatientScreenState();
}

class _MemoryLanePatientScreenState extends State<MemoryLanePatientScreen> {
  List<MemoryLaneItem> _items = [];
  bool _loading = true;
  int _pageIndex = 0;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final patientId = context.read<PatientProvider>().activePatient!.id;
    var items = await DatabaseService.instance.getMemoryLaneItems(patientId,
        type: MemoryLaneType.photo);
    items = await _withLocalMediaEnsured(items);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
    if (items.isNotEmpty) _recordView(items.first);
  }

  /// Downloads a photo/song from Storage into local cache when the local
  /// copy is missing, so the patient can still browse memories that were
  /// added on this account but never downloaded to this device yet.
  Future<List<MemoryLaneItem>> _withLocalMediaEnsured(List<MemoryLaneItem> items) async {
    final storage = MemoryLaneStorageService.instance;
    final result = <MemoryLaneItem>[];
    for (final item in items) {
      final localPath = await storage.ensureLocalPhoto(
          itemId: item.id, localPath: item.localPath, remotePath: item.remoteUrl);
      final songLocalPath = await storage.ensureLocalSong(
          itemId: item.id, localPath: item.songLocalPath, remotePath: item.songRemoteUrl);
      result.add(item.copyWith(localPath: localPath, songLocalPath: songLocalPath));
    }
    return result;
  }

  void _recordView(MemoryLaneItem item) {
    DatabaseService.instance.recordMemoryLaneView(item.id);
    SyncService.instance.syncNow();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF3ECE0),
      appBar: AppBar(title: Text(l10n.memoryLane)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.noMemoriesYetPatient,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _items.length,
                        onPageChanged: (i) {
                          setState(() => _pageIndex = i);
                          _recordView(_items[i]);
                        },
                        itemBuilder: (context, i) => _MemoryCard(
                          item: _items[i],
                          otherNames: _items
                              .where((it) => it.id != _items[i].id && it.title != _items[i].title)
                              .map((it) => it.title)
                              .toSet()
                              .toList(),
                        ),
                      ),
                    ),
                    if (_items.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _items.length,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == _pageIndex
                                    ? AppTheme.primary
                                    : AppTheme.primary.withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _MemoryCard extends StatefulWidget {
  final MemoryLaneItem item;
  final List<String> otherNames;
  const _MemoryCard({required this.item, required this.otherNames});

  @override
  State<_MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<_MemoryCard> {
  // Guessing is the *first* thing shown, not an opt-in after the name is
  // already visible — otherwise there's nothing left to guess. It only
  // starts this way when there's actually someone else to distinguish from;
  // with nothing to compare against, skip straight to the reveal.
  late final bool _guessing = _canGuess;
  bool _revealed = false;
  bool _skipped = false;
  bool? _wasCorrect;
  late final List<String> _guessOptions;
  final _player = AudioPlayer();
  bool _playing = false;

  // Separate player/state from the song button above -- narration and the
  // patient's own favorite song are independent things a patient might want
  // playing, not a single toggle.
  final _voicePlayer = AudioPlayer();
  bool _speaking = false;
  bool _synthesizing = false;

  bool get _canGuess => widget.otherNames.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final rand = Random();
    final distractors = widget.otherNames.toList()..shuffle(rand);
    _guessOptions = [widget.item.title, ...distractors.take(2)]..shuffle(rand);
  }

  @override
  void dispose() {
    _player.dispose();
    _voicePlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleSong() async {
    if (_playing) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(widget.item.songLocalPath!));
    }
    if (mounted) setState(() => _playing = !_playing);
  }

  Future<void> _toggleSpeak() async {
    if (_speaking) {
      await _voicePlayer.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    final language = context.read<PatientProvider>().activePatient!.language;
    final text = [widget.item.title, widget.item.description]
        .whereType<String>()
        .join('. ');
    setState(() => _synthesizing = true);
    final path = await VoiceService.instance.synthesize(languageCode: language, text: text);
    if (!mounted) return;
    setState(() => _synthesizing = false);
    // Bhashini was offline/unreachable/errored -- the name and story are
    // already right there on screen as text, so there's nothing more to do.
    if (path == null) return;
    await _voicePlayer.play(DeviceFileSource(path));
    if (mounted) setState(() => _speaking = true);
    _voicePlayer.onPlayerComplete.first.then((_) {
      if (mounted) setState(() => _speaking = false);
    });
  }

  void _pickGuess(String name) {
    final correct = name == widget.item.title;
    DatabaseService.instance
        .recordMemoryLaneRecognitionAttempt(widget.item.id, recognized: correct);
    SyncService.instance.syncNow();
    setState(() {
      _wasCorrect = correct;
      _revealed = true;
    });
  }

  // Opting out isn't a wrong answer — it's not an answer at all, so it's
  // never recorded as a recognition attempt.
  void _skip() {
    setState(() {
      _skipped = true;
      _revealed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final l10n = AppLocalizations.of(context)!;
    // Ask first, reveal second: the guess prompt is the *initial* state
    // whenever there's someone to guess against, not something layered on
    // after the name was already shown.
    final showGuessPrompt = _guessing && !_revealed;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: item.localPath != null
                ? Image.file(
                    File(item.localPath!),
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 320,
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.photo, size: 64, color: AppTheme.primary),
                    ),
                  )
                : Container(
                    height: 320,
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.photo, size: 64, color: AppTheme.primary),
                  ),
          ),
          const SizedBox(height: 20),
          if (showGuessPrompt) ...[
            Text(l10n.whoIsThis,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._guessOptions.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () => _pickGuess(name),
                    child: Text(name),
                  ),
                )),
            TextButton(
              onPressed: _skip,
              child: Text(l10n.iWouldRatherJustSeeIt, style: const TextStyle(fontSize: 15)),
            ),
          ] else ...[
            if (_revealed && !_skipped)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _wasCorrect == true ? l10n.rememberedCorrectly : l10n.thisIsWhoItIs,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.accent),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(item.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center),
                ),
                // Bhashini only covers Assamese/Manipuri for us right now
                // (see voice_service.dart) -- other languages simply don't
                // get this button rather than showing one that never works.
                if (VoiceService.instance.supportsVoice(
                    context.watch<PatientProvider>().activePatient!.language)) ...[
                  const SizedBox(width: 8),
                  _synthesizing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          onPressed: _toggleSpeak,
                          icon: Icon(_speaking ? Icons.volume_up : Icons.volume_up_outlined,
                              color: AppTheme.accent),
                        ),
                ],
              ],
            ),
            if (item.place != null || item.memoryDate != null) ...[
              const SizedBox(height: 6),
              Text(
                [
                  if (item.place != null) item.place!,
                  if (item.memoryDate != null)
                    DateFormat.yMMMd().format(DateTime.parse(item.memoryDate!)),
                ].join(' • '),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
            if (item.description != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6),
                  ],
                ),
                child: Text(item.description!,
                    style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
              ),
            ],
            if (item.songLocalPath != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _toggleSong,
                icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                label: Text(_playing ? l10n.playingSong : l10n.playTheSong),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
