import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/patient_provider.dart';
import '../theme/app_theme.dart';
import 'caregiver_auth_gate.dart';
import 'language_selection_screen.dart';
import 'patient_auth_gate.dart';

/// The app's true entry point, shown on every launch and returned to
/// whenever either mode is exited. Exactly two choices, each leading into
/// its own separate navigation stack — the caregiver and patient
/// interfaces never share a screen.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Reaching this screen means Patient Mode (if it was ever entered) has
    // been exited, and any caregiver session is done -- reset so the
    // pre-login screens go back to following the device-wide language
    // choice instead of a cached patient's, see PatientProvider
    // .patientModeActive and main.dart.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PatientProvider>().exitPatientMode();
    });
  }

  void _go(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // AppBarTheme's foregroundColor (white, for the normal teal AppBar
        // background used everywhere else) would be nearly invisible against
        // this screen's pale cream Scaffold background -- override it here.
        foregroundColor: AppTheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: l10n.languageTooltip,
            icon: const Icon(Icons.language),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageSelectionScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(l10n.whoIsUsingApp,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 48),
              _RoleCard(
                icon: Icons.medical_services_outlined,
                label: l10n.roleCaregiver,
                subtitle: l10n.roleCaregiverSubtitle,
                color: AppTheme.primary,
                onTap: () => _go(context, const CaregiverAuthGate()),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                icon: Icons.favorite_outline,
                label: l10n.rolePatient,
                subtitle: l10n.rolePatientSubtitle,
                color: AppTheme.accent,
                onTap: () => _go(context, const PatientAuthGate()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 15, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 32, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
