import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'language_selection_screen.dart';
import 'memory_lane_screen.dart';
import 'patients_screen.dart';
import 'role_selection_screen.dart';
import 'routine_screen.dart';

/// Caregiver-only home. This screen — and everything reachable from it —
/// is never shown to a patient. Patient Mode is a completely separate
/// stack reached only through Role Selection (see patient_auth_gate.dart);
/// there is deliberately no "Open Patient View" entry point here anymore.
class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  void _backToRoleSelection(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Capture the Navigator BEFORE the async gap: signOut() completing makes
    // CaregiverAuthGate reactively swap this whole screen out for
    // LoginScreen (it watches auth state), which unmounts this button's
    // BuildContext — a `context.mounted` check after the await would
    // silently skip the explicit "go all the way back" navigation below.
    final navigator = Navigator.of(context);
    final authProvider = context.read<AuthProvider>();
    await authProvider.signOut();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.caregiverDashboardTitle),
        leading: IconButton(
          tooltip: l10n.backToRoleSelection,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _backToRoleSelection(context),
        ),
        actions: [
          IconButton(
            tooltip: l10n.languageTooltip,
            icon: const Icon(Icons.language),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageSelectionScreen())),
          ),
          IconButton(
            tooltip: l10n.signOutTooltip,
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ListTileCard(
            icon: Icons.dashboard,
            label: l10n.progressDashboardTitle,
            subtitle: l10n.progressDashboardSubtitle,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const DashboardScreen())),
          ),
          _ListTileCard(
            icon: Icons.checklist_rtl,
            label: l10n.manageDailyRoutineTitle,
            subtitle: l10n.manageDailyRoutineSubtitle,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const RoutineScreen())),
          ),
          _ListTileCard(
            icon: Icons.photo_album,
            label: l10n.manageMemoryLaneTitle,
            subtitle: l10n.manageMemoryLaneSubtitle,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const MemoryLaneScreen())),
          ),
          _ListTileCard(
            icon: Icons.people,
            label: l10n.patientsTitle,
            subtitle: l10n.patientsSubtitle,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const PatientsScreen())),
          ),
        ],
      ),
    );
  }
}

class _ListTileCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ListTileCard(
      {required this.icon, required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Icon(icon, size: 36, color: AppTheme.primary),
        title: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
