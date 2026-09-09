import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/patient_provider.dart';
import '../theme/app_theme.dart';
import 'patient_mode_screen.dart';
import 'role_selection_screen.dart';

/// Patient Mode's one and only entry point: a Patient User ID + password,
/// set up by the caregiver (see patient_setup_screen.dart) -- never a bare
/// PIN, and never a list of patient names to pick from first. Large,
/// elderly-friendly controls throughout.
class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberDevice = true;
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_userIdController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = l10n.incorrectPatientLoginError);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final patientProvider = context.read<PatientProvider>();
    final patient =
        patientProvider.authenticatePatient(_userIdController.text, _passwordController.text);
    if (patient == null) {
      setState(() {
        _submitting = false;
        _error = l10n.incorrectPatientLoginError;
      });
      return;
    }

    await patientProvider.setActivePatient(patient);
    patientProvider.enterPatientMode();
    if (_rememberDevice) {
      await patientProvider.rememberPatientSession(patient);
    }
    if (!mounted) return;
    // Clears this whole Patient-role stack so the only way back out of
    // Patient Mode is the explicit exit button there.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => PatientModeScreen(patient: patient)),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.patientLoginTitle),
        leading: IconButton(
          tooltip: l10n.backToRoleSelection,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              (route) => false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _userIdController,
              autocorrect: false,
              style: const TextStyle(fontSize: 22),
              decoration: InputDecoration(
                labelText: l10n.patientUserIdFieldLabel,
                labelStyle: const TextStyle(fontSize: 18),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(fontSize: 22),
              decoration: InputDecoration(
                labelText: l10n.passwordLabel,
                labelStyle: const TextStyle(fontSize: 18),
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 18)),
            ],
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _rememberDevice,
              onChanged: (v) => setState(() => _rememberDevice = v ?? true),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.rememberThisDeviceLabel, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
              child: _submitting
                  ? const SizedBox(
                      height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                  : Text(l10n.logInButton, style: const TextStyle(fontSize: 22)),
            ),
          ],
        ),
      ),
    );
  }
}
