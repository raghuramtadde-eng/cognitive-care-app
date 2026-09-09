import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/memory_lane_item.dart';
import '../providers/patient_provider.dart';
import '../services/database_service.dart';
import '../services/memory_lane_storage_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';

/// Caregiver-facing Memory Lane manager: add a personalized memory (photo,
/// who/where/when, a short story, optionally a favorite song) and review or
/// remove what's been added. The patient-facing browsing experience lives
/// in memory_lane_patient_screen.dart — this screen is caregiver-only.
class MemoryLaneScreen extends StatefulWidget {
  const MemoryLaneScreen({super.key});

  @override
  State<MemoryLaneScreen> createState() => _MemoryLaneScreenState();
}

class _MemoryLaneScreenState extends State<MemoryLaneScreen> {
  List<MemoryLaneItem> _items = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final patientId = context.read<PatientProvider>().activePatient!.id;
    var items = await DatabaseService.instance.getMemoryLaneItems(patientId);
    items = await _withLocalMediaEnsured(items);
    if (mounted) setState(() => _items = items);
  }

  /// Downloads a photo/song from Storage into local cache when the local
  /// copy is missing (e.g. this is a fresh install) — a no-op, near-instant
  /// pass when everything is already local, which is the common case.
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

  Future<void> _addMemory() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;

    final draft = await showDialog<_MemoryDraft>(
      context: context,
      builder: (_) => const _MemoryDetailsDialog(),
    );
    if (draft == null || !mounted) return;

    final docsDir = await getApplicationDocumentsDirectory();
    final memoryDir = Directory(p.join(docsDir.path, 'memory_lane'));
    if (!await memoryDir.exists()) await memoryDir.create(recursive: true);

    final photoExt = p.extension(picked.path);
    final photoDest = p.join(memoryDir.path, '${_uuid.v4()}$photoExt');
    await File(picked.path).copy(photoDest);

    String? songDest;
    if (draft.songPickedPath != null) {
      final songExt = p.extension(draft.songPickedPath!);
      songDest = p.join(memoryDir.path, '${_uuid.v4()}$songExt');
      await File(draft.songPickedPath!).copy(songDest);
    }
    if (!mounted) return;

    final patientId = context.read<PatientProvider>().activePatient!.id;
    final now = DateTime.now().toIso8601String();
    await DatabaseService.instance.upsertMemoryLaneItem(MemoryLaneItem(
      id: _uuid.v4(),
      patientId: patientId,
      type: MemoryLaneType.photo,
      title: draft.name,
      description: draft.story,
      place: draft.place,
      memoryDate: draft.date?.toIso8601String(),
      localPath: photoDest,
      songLocalPath: songDest,
      createdAt: now,
      updatedAt: now,
    ));
    await _load();
    SyncService.instance.syncNow();
  }

  Future<void> _deleteMemory(MemoryLaneItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeMemoryQuestionTitle),
        content: Text(l10n.removeMemoryConfirm(item.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancelButton)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.removeButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await DatabaseService.instance.deleteMemoryLaneItem(item.id);
    await _load();
  }

  void _openItem(MemoryLaneItem item) {
    showDialog(
      context: context,
      builder: (_) => _MemoryPreviewDialog(
        item: item,
        onDelete: () {
          Navigator.pop(context);
          _deleteMemory(item);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.memoryLane)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMemory,
        icon: const Icon(Icons.add_a_photo),
        label: Text(l10n.addAMemoryButton),
      ),
      body: _items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.noMemoriesAddedCaregiver,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onTap: () => _openItem(item),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              item.localPath != null
                                  ? Image.file(File(item.localPath!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, _, _) => Container(
                                            color: AppTheme.primary.withValues(alpha: 0.1),
                                            child: const Center(
                                                child: Icon(Icons.photo, size: 48, color: AppTheme.primary)),
                                          ))
                                  : Container(
                                      color: AppTheme.primary.withValues(alpha: 0.1),
                                      child: const Center(
                                          child: Icon(Icons.photo, size: 48, color: AppTheme.primary)),
                                    ),
                              if (item.songLocalPath != null)
                                const Positioned(
                                  right: 8,
                                  top: 8,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.music_note, size: 16, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _MemoryDraft {
  final String name;
  final String? place;
  final DateTime? date;
  final String? story;
  final String? songPickedPath;
  _MemoryDraft({required this.name, this.place, this.date, this.story, this.songPickedPath});
}

class _MemoryDetailsDialog extends StatefulWidget {
  const _MemoryDetailsDialog();

  @override
  State<_MemoryDetailsDialog> createState() => _MemoryDetailsDialogState();
}

class _MemoryDetailsDialogState extends State<_MemoryDetailsDialog> {
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _storyController = TextEditingController();
  DateTime? _date;
  String? _songPath;
  String? _songName;

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickSong() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    final path = result?.files.single.path;
    if (path == null) return;
    setState(() {
      _songPath = path;
      _songName = result!.files.single.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.tellUsAboutMemoryTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.whoIsThisRequiredLabel),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _placeController,
              decoration: InputDecoration(labelText: l10n.placeOptionalLabel),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(_date == null
                  ? l10n.whenWasThisOptional
                  : DateFormat.yMMMd().format(_date!)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _storyController,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.shortStoryOptionalLabel),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickSong,
              icon: Icon(_songPath == null ? Icons.music_note_outlined : Icons.music_note),
              label: Text(_songName ?? l10n.attachFavoriteSongOptional),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancelButton)),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              _MemoryDraft(
                name: name,
                place: _placeController.text.trim().isEmpty ? null : _placeController.text.trim(),
                date: _date,
                story: _storyController.text.trim().isEmpty ? null : _storyController.text.trim(),
                songPickedPath: _songPath,
              ),
            );
          },
          child: Text(l10n.saveButton),
        ),
      ],
    );
  }
}

class _MemoryPreviewDialog extends StatefulWidget {
  final MemoryLaneItem item;
  final VoidCallback onDelete;
  const _MemoryPreviewDialog({required this.item, required this.onDelete});

  @override
  State<_MemoryPreviewDialog> createState() => _MemoryPreviewDialogState();
}

class _MemoryPreviewDialogState extends State<_MemoryPreviewDialog> {
  final _player = AudioPlayer();
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggleSong() async {
    if (_playing) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(widget.item.songLocalPath!));
    }
    setState(() => _playing = !_playing);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = widget.item;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.localPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(item.localPath!),
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 220,
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      child: const Center(
                          child: Icon(Icons.photo, size: 48, color: AppTheme.primary)),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(item.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              if (item.place != null || item.memoryDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  [
                    if (item.place != null) item.place!,
                    if (item.memoryDate != null)
                      DateFormat.yMMMd().format(DateTime.parse(item.memoryDate!)),
                  ].join(' • '),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
              if (item.description != null) ...[
                const SizedBox(height: 12),
                Text(item.description!, textAlign: TextAlign.center),
              ],
              if (item.songLocalPath != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _toggleSong,
                  icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                  label: Text(_playing ? l10n.playingSong : l10n.playTheSong),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                l10n.viewedTimes(item.viewCount) +
                    (item.presentedCount > 0
                        ? ' • ${l10n.recognizedCountSuffix(item.recognizedCount, item.presentedCount)}'
                        : ''),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                      label: Text(l10n.removeButton, style: const TextStyle(color: AppTheme.danger)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.closeButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
