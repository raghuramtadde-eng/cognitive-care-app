import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../theme/app_theme.dart';
import 'games/memory_match_screen.dart';
import 'games/sequence_recall_screen.dart';
import 'games/spot_change_screen.dart';
import 'memory_lane_patient_screen.dart';
import 'role_selection_screen.dart';
import 'routine_recall_screen.dart';
import 'routine_screen.dart';

/// What the patient actually uses, entered only via a correct Patient User
/// ID + password login (see patient_login_screen.dart) or a previously
/// remembered device session (see PatientProvider.rememberPatientSession).
/// This is the terminal screen of the Patient-role stack — exiting always
/// lands on Role Selection, never on any caregiver screen, and needs no
/// re-authentication since leaving isn't the sensitive direction. Exiting
/// also invalidates this device's remembered session (if any), so a
/// caregiver always has a way to re-bind the device to someone else, or
/// fall back to the full User ID + password login.
class PatientModeScreen extends StatelessWidget {
  final Patient patient;
  const PatientModeScreen({super.key, required this.patient});

  void _exit(BuildContext context) {
    context.read<PatientProvider>().forgetRememberedPatientDevice(currentPatient: patient);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helloName(patient.name)),
        actions: [
          IconButton(
            tooltip: l10n.exitPatientMode,
            icon: const Icon(Icons.lock_outline),
            onPressed: () => _exit(context),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        // Without this, cells default to a 1:1 square, which is a few
        // pixels too short once a two-word label (e.g. "Memory Match")
        // wraps to two lines on a narrower/denser real-device screen --
        // confirmed via a live "BOTTOM OVERFLOWED BY 6.0 PIXELS" report.
        childAspectRatio: 0.85,
        children: [
          _BigTile(
            icon: Icons.grid_view,
            label: l10n.gameMemoryMatch,
            color: AppTheme.primary,
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MemoryMatchScreen())),
          ),
          _BigTile(
            icon: Icons.pattern,
            label: l10n.gameSequenceRecall,
            color: AppTheme.accent,
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SequenceRecallScreen())),
          ),
          _BigTile(
            icon: Icons.visibility_outlined,
            label: l10n.gameSpotChange,
            color: const Color(0xFF6A4C93),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SpotChangeScreen())),
          ),
          _BigTile(
            icon: Icons.checklist_rtl,
            label: l10n.dailyRoutine,
            color: AppTheme.success,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const RoutineScreen())),
          ),
          _BigTile(
            icon: Icons.photo_album,
            label: l10n.memoryLane,
            color: AppTheme.warning,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const MemoryLanePatientScreen())),
          ),
          _BigTile(
            icon: Icons.psychology_outlined,
            label: l10n.recallCheckIn,
            color: const Color(0xFF1F6F78),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const RoutineRecallScreen())),
          ),
        ],
      ),
    );
  }
}

class _BigTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BigTile(
      {required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              // maxLines + ellipsis is a hard safety net: even a larger
              // system font-scale setting (common for elderly users) or an
              // unusually narrow screen can no longer force this past the
              // tile's available height, only truncate gracefully.
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
