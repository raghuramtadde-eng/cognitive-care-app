import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/caregiver_alert.dart';
import '../models/game_session.dart';
import '../models/memory_lane_item.dart';
import '../providers/game_provider.dart';
import '../providers/patient_provider.dart';
import '../providers/routine_provider.dart';
import '../services/alert_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

typedef _Adherence = RoutineAdherence;
typedef _RecallAccuracy = RecallAccuracy;

String _gameTypeName(AppLocalizations l10n, GameType type) => switch (type) {
      GameType.memoryMatch => l10n.gameMemoryMatch,
      GameType.sequenceRecall => l10n.gameSequenceRecall,
      GameType.spotChange => l10n.gameSpotChange,
    };

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardData {
  final List<GameSession> memorySessions;
  final List<GameSession> sequenceSessions;
  final List<GameSession> spotChangeSessions;
  final int memoryLevel;
  final int sequenceLevel;
  final int spotChangeLevel;
  final _Adherence routineAdherence;
  final _RecallAccuracy recallAccuracy;
  final List<MemoryLaneItem> memoryLaneItems;
  final List<GameSession> recentAll;
  final List<CaregiverAlert> alerts;

  _DashboardData({
    required this.memorySessions,
    required this.sequenceSessions,
    required this.spotChangeSessions,
    required this.memoryLevel,
    required this.sequenceLevel,
    required this.spotChangeLevel,
    required this.routineAdherence,
    required this.recallAccuracy,
    required this.memoryLaneItems,
    required this.recentAll,
    required this.alerts,
  });
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final patient = context.read<PatientProvider>().activePatient!;
    final gameProvider = context.read<GameProvider>();
    final routineProvider = context.read<RoutineProvider>();

    final memorySessions =
        await gameProvider.history(patient.id, GameType.memoryMatch, limit: 10);
    final sequenceSessions =
        await gameProvider.history(patient.id, GameType.sequenceRecall, limit: 10);
    final spotChangeSessions =
        await gameProvider.history(patient.id, GameType.spotChange, limit: 10);
    final memoryProgress =
        await gameProvider.getOrCreateProgress(patient.id, GameType.memoryMatch);
    final sequenceProgress =
        await gameProvider.getOrCreateProgress(patient.id, GameType.sequenceRecall);
    final spotChangeProgress =
        await gameProvider.getOrCreateProgress(patient.id, GameType.spotChange);
    final adherence = await routineProvider.adherenceOverLastDays(patient.id, 7);
    final recallAccuracy =
        await routineProvider.recallAccuracyOverLastDays(patient.id, 7);
    final memoryLane = await DatabaseService.instance.getMemoryLaneItems(patient.id);
    final recentAll = await gameProvider.allHistory(patient.id);

    // Self-contained safety net: the caregiver may open this dashboard
    // without the patient side ever loading Daily Routine this session, so
    // check for missed reminders here too rather than only relying on
    // RoutineProvider.loadForPatient() having already run.
    await AlertService.instance.checkMissedReminders(patient.id);
    final alerts = await DatabaseService.instance.getAlertsForPatient(patient.id, limit: 20);

    return _DashboardData(
      memorySessions: memorySessions.reversed.toList(),
      sequenceSessions: sequenceSessions.reversed.toList(),
      spotChangeSessions: spotChangeSessions.reversed.toList(),
      memoryLevel: memoryProgress.currentLevel,
      sequenceLevel: sequenceProgress.currentLevel,
      spotChangeLevel: spotChangeProgress.currentLevel,
      routineAdherence: adherence,
      recallAccuracy: recallAccuracy,
      memoryLaneItems: memoryLane,
      recentAll: recentAll.take(10).toList(),
      alerts: alerts,
    );
  }

  Future<void> _refresh() async {
    // A block body, not `=> _future = _load()` -- an arrow closure here
    // would make setState's callback return a Future, which Flutter's
    // framework rejects (throws, and skips the rebuild) in debug mode.
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final patient = context.watch<PatientProvider>().activePatient!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressTitle(patient.name))),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_DashboardData>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (data.alerts.isNotEmpty) ...[
                  _AlertsCard(alerts: data.alerts, onChanged: _refresh),
                  const SizedBox(height: 16),
                ],
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    _LevelCard(
                      title: l10n.gameMemoryMatch,
                      level: data.memoryLevel,
                      sessionsCount: data.memorySessions.length,
                    ),
                    _LevelCard(
                      title: l10n.gameSequenceRecall,
                      level: data.sequenceLevel,
                      sessionsCount: data.sequenceSessions.length,
                    ),
                    _LevelCard(
                      title: l10n.gameSpotChange,
                      level: data.spotChangeLevel,
                      sessionsCount: data.spotChangeSessions.length,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: '${l10n.gameMemoryMatch} — ${l10n.accuracyTrendSuffix}',
                  sessions: data.memorySessions,
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: '${l10n.gameSequenceRecall} — ${l10n.accuracyTrendSuffix}',
                  sessions: data.sequenceSessions,
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: '${l10n.gameSpotChange} — ${l10n.accuracyTrendSuffix}',
                  sessions: data.spotChangeSessions,
                ),
                const SizedBox(height: 16),
                _RoutineAdherenceCard(adherence: data.routineAdherence),
                const SizedBox(height: 16),
                _RecallAccuracyCard(accuracy: data.recallAccuracy),
                const SizedBox(height: 16),
                _MemoryLaneSummaryCard(items: data.memoryLaneItems),
                const SizedBox(height: 16),
                _RecentSessionsCard(sessions: data.recentAll),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String title;
  final int level;
  final int sessionsCount;

  const _LevelCard(
      {required this.title, required this.level, required this.sessionsCount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(l10n.levelValueLabel(level),
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            Text(l10n.roundsLoggedLabel(sessionsCount),
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<GameSession> sessions;

  const _ChartCard({required this.title, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (sessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(l10n.noRoundsPlayedYet, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final spots = <FlSpot>[
      for (var i = 0; i < sessions.length; i++)
        FlSpot(i.toDouble(), sessions[i].accuracy * 100),
    ];
    final levelLabel = sessions.last.difficultyLevel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(l10n.nowLevelLabel(levelLabel),
                    style: const TextStyle(fontSize: 13, color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 25),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                          show: true, color: AppTheme.primary.withValues(alpha: 0.12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineAdherenceCard extends StatelessWidget {
  final _Adherence adherence;
  const _RoutineAdherenceCard({required this.adherence});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rate = adherence.adherenceRate;
    final pct = (rate * 100).round();
    final color = rate >= 0.8
        ? AppTheme.success
        : (rate >= 0.5 ? AppTheme.warning : AppTheme.danger);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.routineAdherenceTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: rate,
                      minHeight: 14,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$pct%',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.completedMissedLabel(adherence.done, adherence.missed),
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  final List<CaregiverAlert> alerts;
  final Future<void> Function() onChanged;
  const _AlertsCard({required this.alerts, required this.onChanged});

  Future<void> _markRead(String id) async {
    await DatabaseService.instance.markAlertRead(id);
    await onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unreadCount = alerts.where((a) => !a.isRead).length;

    return Card(
      color: unreadCount > 0 ? AppTheme.danger.withValues(alpha: 0.06) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active_outlined,
                    color: unreadCount > 0 ? AppTheme.danger : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  unreadCount > 0  ? l10n.alertsTitleWithCount(unreadCount) : l10n.alertsTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...alerts.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title,
                                style: TextStyle(
                                    fontWeight:
                                        a.isRead ? FontWeight.normal : FontWeight.bold,
                                    color: a.isRead ? Colors.grey.shade700 : null)),
                            Text(a.message,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: a.isRead ? Colors.grey : Colors.grey.shade800)),
                            Text(a.date,
                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (!a.isRead)
                        TextButton(
                          onPressed: () => _markRead(a.id),
                          child: Text(l10n.markReadButton),
                        ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _RecallAccuracyCard extends StatelessWidget {
  final _RecallAccuracy accuracy;
  const _RecallAccuracyCard({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (accuracy.answered == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.recallAccuracyTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                l10n.recallAccuracyExplanation,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(l10n.noRecallCheckinsYet,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final rate = accuracy.correct / accuracy.answered;
    final pct = (rate * 100).round();
    final color = rate >= 0.8
        ? AppTheme.success
        : (rate >= 0.5 ? AppTheme.warning : AppTheme.danger);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.recallAccuracyTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              l10n.recallAccuracyExplanation,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: rate,
                      minHeight: 14,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$pct%',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                l10n.recallStatsLabel(accuracy.correct,
                    accuracy.answered - accuracy.correct, accuracy.answered),
                style: const TextStyle(color: Colors.grey)),
            if (accuracy.mismatches.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(l10n.recentMismatchesTitle,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              ...accuracy.mismatches.map((m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      l10n.mismatchLine(m.date, m.itemTitle,
                          m.actualStatus.name == 'done' ? l10n.statusDone : l10n.statusNotDoneWord),
                      style: const TextStyle(fontSize: 13),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _MemoryLaneSummaryCard extends StatelessWidget {
  final List<MemoryLaneItem> items;
  const _MemoryLaneSummaryCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final memories = items.where((i) => i.type == MemoryLaneType.photo).toList();
    final totalViews = memories.fold<int>(0, (sum, i) => sum + i.viewCount);
    final totalPresented = memories.fold<int>(0, (sum, i) => sum + i.presentedCount);
    final totalRecognized = memories.fold<int>(0, (sum, i) => sum + i.recognizedCount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.memoryLaneEngagementTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              l10n.memoryLaneEngagementSubtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(icon: Icons.photo, label: l10n.memoriesStatLabel, count: memories.length),
                _StatChip(icon: Icons.visibility_outlined, label: l10n.viewsStatLabel, count: totalViews),
                if (totalPresented > 0)
                  _StatChip(
                    icon: Icons.favorite_outline,
                    label: l10n.recognizedStatLabel,
                    count: totalRecognized,
                    suffix: '/$totalPresented',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final String suffix;
  const _StatChip(
      {required this.icon, required this.label, required this.count, this.suffix = ''});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 28),
        const SizedBox(height: 4),
        Text('$count$suffix', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _RecentSessionsCard extends StatelessWidget {
  final List<GameSession> sessions;
  const _RecentSessionsCard({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.recentSessionHistoryTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.noSessionsYet, style: const TextStyle(color: Colors.grey)),
              )
            else
              ...sessions.map((s) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                      child: Text('L${s.difficultyLevel}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ),
                    title: Text(_gameTypeName(l10n, s.gameType)),
                    subtitle: Text(
                        l10n.accuracyAvgLabel((s.accuracy * 100).round(), s.avgResponseTimeMs)),
                    trailing: Text(l10n.ptsLabel(s.score),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  )),
          ],
        ),
      ),
    );
  }
}
