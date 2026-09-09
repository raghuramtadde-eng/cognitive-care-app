import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/routine_item.dart';
import '../models/routine_log.dart';
import '../providers/patient_provider.dart';
import '../providers/routine_provider.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';

IconData routineIconFor(RoutineType type) => switch (type) {
      RoutineType.medicine => Icons.medication,
      RoutineType.hydration => Icons.local_drink,
      RoutineType.activity => Icons.directions_walk,
      RoutineType.appointment => Icons.event,
    };

String routineTypeName(AppLocalizations l10n, RoutineType type) => switch (type) {
      RoutineType.medicine => l10n.routineTypeMedicine,
      RoutineType.hydration => l10n.routineTypeHydration,
      RoutineType.activity => l10n.routineTypeActivity,
      RoutineType.appointment => l10n.routineTypeAppointment,
    };

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientId = context.read<PatientProvider>().activePatient!.id;
      context.read<RoutineProvider>().loadForPatient(patientId);
    });
  }

  Future<void> _openAddSheet() async {
    final patient = context.read<PatientProvider>().activePatient!;
    final l10n = AppLocalizations.of(context)!;
    RoutineType selectedType = RoutineType.medicine;
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    var recording = false;
    var transcribing = false;

    Future<void> toggleMic(void Function(void Function()) setSheetState) async {
      if (recording) {
        setSheetState(() {
          recording = false;
          transcribing = true;
        });
        final transcript =
            await VoiceService.instance.stopRecordingAndTranscribe(patient.language);
        if (transcript != null) titleController.text = transcript;
        setSheetState(() => transcribing = false);
        return;
      }
      final started = await VoiceService.instance.startRecording();
      if (started) setSheetState(() => recording = true);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) => SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.addReminder, style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  children: RoutineType.values.map((t) {
                    return ChoiceChip(
                      label: Text(routineTypeName(l10n, t)),
                      selected: selectedType == t,
                      onSelected: (_) => setSheetState(() => selectedType = t),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: l10n.whatIsIt,
                    // Bhashini only covers Assamese/Manipuri for us right now
                    // (see voice_service.dart) -- other languages just get a
                    // plain text field, same as before this feature existed.
                    suffixIcon: !VoiceService.instance.supportsVoice(patient.language)
                        ? null
                        : transcribing
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                onPressed: () => toggleMic(setSheetState),
                                icon: Icon(recording ? Icons.mic : Icons.mic_none,
                                    color: recording ? AppTheme.danger : null),
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.time),
                  trailing: Text(selectedTime.format(ctx),
                      style: const TextStyle(fontSize: 20)),
                  onTap: () async {
                    final picked = await showTimePicker(
                        context: ctx, initialTime: selectedTime);
                    if (picked != null) setSheetState(() => selectedTime = picked);
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;
                    await context.read<RoutineProvider>().addRoutineItem(
                          patientId: patient.id,
                          patientLanguage: patient.language,
                          type: selectedType,
                          title: titleController.text.trim(),
                          hour: selectedTime.hour,
                          minute: selectedTime.minute,
                        );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(l10n.saveReminder),
                ),
              ],
              ),
            ),
          ),
        );
      },
    );
    // Harmless no-op if nothing was recording -- covers the sheet being
    // dismissed (back gesture, tapping outside) mid-recording.
    await VoiceService.instance.cancelRecording();
  }

  @override
  Widget build(BuildContext context) {
    final routine = context.watch<RoutineProvider>();
    final patientId = context.watch<PatientProvider>().activePatient!.id;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dailyRoutine)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.add),
        label: Text(l10n.addReminder),
      ),
      body: routine.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.noRemindersYet,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routine.items.length,
              itemBuilder: (context, index) {
                final item = routine.items[index];
                final status = routine.statusFor(item.id);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(routineIconFor(item.type), size: 32, color: AppTheme.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                  style: Theme.of(context).textTheme.bodyLarge),
                              Text(
                                '${item.scheduledHour.toString().padLeft(2, '0')}:${item.scheduledMinute.toString().padLeft(2, '0')} • ${routineTypeName(l10n, item.type)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        _StatusControl(
                          status: status,
                          onDone: () => routine.markStatus(
                              patientId, item, RoutineStatus.done),
                          onMissed: () => routine.markStatus(
                              patientId, item, RoutineStatus.missed),
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

class _StatusControl extends StatelessWidget {
  final RoutineStatus status;
  final VoidCallback onDone;
  final VoidCallback onMissed;

  const _StatusControl(
      {required this.status, required this.onDone, required this.onMissed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (status == RoutineStatus.done) {
      return Chip(
        label: Text(l10n.statusDone),
        avatar: const Icon(Icons.check, color: Colors.white, size: 18),
        backgroundColor: AppTheme.success,
        labelStyle: const TextStyle(color: Colors.white),
      );
    }
    if (status == RoutineStatus.missed) {
      return Chip(
        label: Text(l10n.statusMissed),
        avatar: const Icon(Icons.close, color: Colors.white, size: 18),
        backgroundColor: AppTheme.danger,
        labelStyle: const TextStyle(color: Colors.white),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onDone,
          icon: const Icon(Icons.check_circle_outline, color: AppTheme.success, size: 34),
        ),
        IconButton(
          onPressed: onMissed,
          icon: const Icon(Icons.cancel_outlined, color: AppTheme.danger, size: 34),
        ),
      ],
    );
  }
}
