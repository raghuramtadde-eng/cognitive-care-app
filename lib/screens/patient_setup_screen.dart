import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import 'caregiver_home_screen.dart';
import 'role_selection_screen.dart';

const _languages = [
  ('en', 'English'),
  ('as', 'Assamese'),
  ('mni', 'Manipuri'),
];

final _userIdPattern = RegExp(r'^[a-z0-9_]{3,}$');

String _themeLabel(AppLocalizations l10n, CulturalTheme theme) => switch (theme) {
      CulturalTheme.generalNer => l10n.themeGeneralNer,
      CulturalTheme.assam => l10n.themeAssam,
      CulturalTheme.manipur => l10n.themeManipur,
    };

/// Caregiver creates a patient profile, including the Patient User ID +
/// password that will later log them into Patient view (see
/// patient_login_screen.dart). Shown right after login whenever the
/// signed-in caregiver has no patients yet.
class PatientSetupScreen extends StatefulWidget {
  const PatientSetupScreen({super.key});

  @override
  State<PatientSetupScreen> createState() => _PatientSetupScreenState();
}

class _PatientSetupScreenState extends State<PatientSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  String _language = 'en';
  CulturalTheme _culturalTheme = CulturalTheme.generalNer;
  bool _saving = false;
  String? _userIdError;

  Future<void> _submit() async {
    setState(() => _userIdError = null);
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await context.read<PatientProvider>().createPatient(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            language: _language,
            culturalTheme: _culturalTheme,
            userId: _userIdController.text.trim(),
            password: _passwordController.text,
          );
    } on UserIdTakenException {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _userIdError = l10n.userIdAlreadyTakenError;
      });
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CaregiverHomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.setUpPatientProfileTitle),
        leading: IconButton(
          tooltip: l10n.backToRoleSelection,
          icon: const Icon(Icons.arrow_back),
          // Reached two ways: as the mandatory bootstrap screen right after
          // signup (no previous route -- nothing to pop to, so fall back to
          // Role Selection), and via "Add Patient" from patients_screen.dart
          // (a real previous route exists, so back should just return to
          // that screen instead of blowing away the whole caregiver stack).
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                  (route) => false);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.welcomeHeading,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                l10n.welcomeSubtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.patientsNameLabel),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.pleaseEnterNameError : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: l10n.ageFieldLabel),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0 || n > 120) return l10n.enterValidAgeError;
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(l10n.preferredLanguageLabel,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: _languages.map((lang) {
                  final selected = _language == lang.$1;
                  return ChoiceChip(
                    label: Text(lang.$2, style: const TextStyle(fontSize: 18)),
                    selected: selected,
                    onSelected: (_) => setState(() => _language = lang.$1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(l10n.culturalThemeLabel,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text(
                // Deliberately separate from the language choice above -- an
                // English-speaking patient can still get Assam- or
                // Manipur-themed game content, and vice versa.
                l10n.culturalThemeExplanation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: CulturalTheme.values.map((theme) {
                  final selected = _culturalTheme == theme;
                  return ChoiceChip(
                    label: Text(_themeLabel(l10n, theme), style: const TextStyle(fontSize: 18)),
                    selected: selected,
                    onSelected: (_) => setState(() => _culturalTheme = theme),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(l10n.setPatientCredentialsLabel,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text(
                l10n.credentialHandoffExplanation(_nameController.text.trim().isEmpty
                    ? l10n.defaultPatientWord
                    : _nameController.text.trim()),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _userIdController,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: l10n.patientUserIdFieldLabel,
                  errorText: _userIdError,
                ),
                validator: (v) {
                  final value = v?.trim().toLowerCase() ?? '';
                  if (!_userIdPattern.hasMatch(value)) return l10n.enterValidUserIdError;
                  return null;
                },
                onChanged: (_) {
                  if (_userIdError != null) setState(() => _userIdError = null);
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: l10n.passwordLabel),
                obscureText: true,
                validator: (v) => (v == null || v.length < 4) ? l10n.passwordTooShortError : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordConfirmController,
                decoration: InputDecoration(labelText: l10n.confirmPasswordLabel),
                obscureText: true,
                validator: (v) =>
                    (v != _passwordController.text) ? l10n.passwordsDoNotMatchError : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 24, width: 24,
                        child: CircularProgressIndicator(color: Colors.white))
                    : Text(l10n.continueButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
