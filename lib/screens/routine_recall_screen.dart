import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/routine_item.dart';
import '../models/routine_log.dart';
import '../providers/patient_provider.dart';
import '../providers/routine_provider.dart';
import '../theme/app_theme.dart';
import 'routine_screen.dart' show routineIconFor, routineTypeName;

/// A short memory exercise distinct from the reminder system itself: instead
/// of the caregiver/patient ticking Done or Missed as it happens, this asks
/// the patient afterward "did you do this today?" and checks their answer
/// against what was actually logged. Like Memory Lane, a wrong recall is
/// never shown as "wrong" -- just a warm correction -- and this never feeds
/// the adaptive difficulty engine (see adaptive_difficulty_service.dart),
/// only its own soft recalledCorrectly stat for a future caregiver trend view.
class RoutineRecallScreen extends StatefulWidget {
  const RoutineRecallScreen({super.key});

  @override
  State<RoutineRecallScreen> createState() => _RoutineRecallScreenState();
}

class _RoutineRecallScreenState extends State<RoutineRecallScreen> {
  List<RoutineItem> _items = [];
  int _index = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Can't assume RoutineProvider is already populated -- a patient reaching
  // this straight from the home grid may never have opened Daily Routine
  // this session, and its items/logs are only loaded on demand, not at app
  // start.
  Future<void> _load() async {
    final routine = context.read<RoutineProvider>();
    final patientId = context.read<PatientProvider>().activePatient!.id;
    await routine.loadForPatient(patientId);
    if (!mounted) return;
    setState(() {
      _items = routine.recallEligibleItems;
      _loading = false;
    });
  }

  void _next() {
    if (_index + 1 < _items.length) {
      setState(() => _index++);
    } else {
      setState(() => _index = _items.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF3ECE0),
      appBar: AppBar(title: Text(l10n.recallCheckIn)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _index >= _items.length
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.noRecallItemsYet,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : _RecallCard(
              key: ValueKey(_items[_index].id),
              item: _items[_index],
              onNext: _next,
            ),
    );
  }
}

class _RecallCard extends StatefulWidget {
  final RoutineItem item;
  final VoidCallback onNext;
  const _RecallCard({required super.key, required this.item, required this.onNext});

  @override
  State<_RecallCard> createState() => _RecallCardState();
}

class _RecallCardState extends State<_RecallCard> {
  bool? _patientSaidDone;
  bool? _actuallyDone;

  Future<void> _answer(bool? patientSaysDone) async {
    // "I don't remember" isn't a claim either way -- treat it the same as a
    // "no" for comparison purposes (it wasn't confidently recalled as done),
    // but the feedback copy below still treats it gently, same as a "no".
    final patientId = context.read<PatientProvider>().activePatient!.id;
    final routine = context.read<RoutineProvider>();
    final actuallyDone = await routine.recordRecall(patientId, widget.item,
        patientSaysDone: patientSaysDone ?? false);
    if (!mounted) return;
    setState(() {
      _patientSaidDone = patientSaysDone ?? false;
      _actuallyDone = actuallyDone;
    });
  }

  Future<void> _markDoneNow() async {
    final patientId = context.read<PatientProvider>().activePatient!.id;
    await context
        .read<RoutineProvider>()
        .markStatus(patientId, widget.item, RoutineStatus.done);
    if (mounted) setState(() => _actuallyDone = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = widget.item;
    final answered = _patientSaidDone != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          Icon(routineIconFor(item.type), size: 64, color: AppTheme.primary),
          const SizedBox(height: 16),
          Text(item.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            '${item.scheduledHour.toString().padLeft(2, '0')}:${item.scheduledMinute.toString().padLeft(2, '0')} • ${routineTypeName(l10n, item.type)}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 28),
          if (!answered) ...[
            Text(l10n.recallPromptQuestion,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _answer(true),
              child: Text(l10n.recallYes),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _answer(false),
              child: Text(l10n.recallNo),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _answer(null),
              child: Text(l10n.recallNotSure, style: const TextStyle(fontSize: 15)),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                // "Correct" only reads right when it was actually done --
                // correctly recalling a *non*-event doesn't warrant "that's
                // right, you did!", so it shares the plain acknowledgement
                // wording with the "said no" miss case instead.
                _actuallyDone == true
                    ? (_patientSaidDone == true
                        ? l10n.recallFeedbackCorrectDone
                        : l10n.recallFeedbackGentleCorrectionDone)
                    : l10n.recallFeedbackAcknowledgeNotDone,
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.accent),
                textAlign: TextAlign.center,
              ),
            ),
            if (_patientSaidDone == true && _actuallyDone == false) ...[
              const SizedBox(height: 16),
              Text(l10n.recallOfferMarkDone, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _markDoneNow, child: Text(l10n.markDoneNow)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(onPressed: widget.onNext, child: Text(l10n.recallNext)),
          ],
        ],
      ),
    );
  }
}
