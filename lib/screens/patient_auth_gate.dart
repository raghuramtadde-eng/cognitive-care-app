import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import 'patient_login_screen.dart';
import 'patient_mode_screen.dart';
import 'role_selection_screen.dart';

/// Everything the PATIENT role can reach lives behind this gate: a single
/// Patient User ID + password login (see patient_login_screen.dart) --
/// never a list of patient names, never a bare PIN -- unless this specific
/// device already has a validated remembered session (see
/// PatientProvider.rememberPatientSession), in which case that step is
/// skipped entirely and the device goes straight to that exact patient's
/// Home. Nothing rendered here ever exposes a caregiver-facing screen. A
/// caregiver still needs to have signed in on this device at least once —
/// their cached session is what the underlying data requests run under
/// (see supabase_schema.sql for the reasoning) — but this gate never shows
/// their dashboard or any caregiver controls.
class PatientAuthGate extends StatefulWidget {
  const PatientAuthGate({super.key});

  @override
  State<PatientAuthGate> createState() => _PatientAuthGateState();
}

class _PatientAuthGateState extends State<PatientAuthGate> {
  String? _loadedForCaregiverId;
  bool _rememberedChecked = false;
  ({String userId, String token})? _remembered;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    final remembered = await context.read<PatientProvider>().getRememberedPatientSession();
    if (!mounted) return;
    setState(() {
      _remembered = remembered;
      _rememberedChecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.currentUser?.id;

    if (uid == null) {
      return const _NotSetUpScreen();
    }

    final patientProviderRef = context.read<PatientProvider>();
    if (_loadedForCaregiverId != uid) {
      _loadedForCaregiverId = uid;
      Future.microtask(() => patientProviderRef.loadForCaregiver(uid));
    }

    final patientProvider = context.watch<PatientProvider>();
    if (patientProvider.loading || !_rememberedChecked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (patientProvider.patients.isEmpty) {
      return const _NotSetUpScreen();
    }

    final remembered = _remembered;
    if (remembered != null) {
      final patient =
          patientProvider.validateRememberedSession(remembered.userId, remembered.token);
      if (patient != null) {
        if (patientProvider.activePatient?.id != patient.id || !patientProvider.patientModeActive) {
          Future.microtask(() {
            patientProvider.setActivePatient(patient);
            patientProvider.enterPatientMode();
          });
        }
        return PatientModeScreen(patient: patient);
      }
    }

    return const PatientLoginScreen();
  }
}

class _NotSetUpScreen extends StatelessWidget {
  const _NotSetUpScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 56, color: Colors.black38),
              const SizedBox(height: 16),
              Text(
                l10n.deviceNotSetUpMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                    (route) => false),
                child: Text(l10n.backButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
