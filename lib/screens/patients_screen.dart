import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/patient_provider.dart';
import '../theme/app_theme.dart';
import 'patient_setup_screen.dart';

/// Lets a caregiver switch the active patient or add another one. Kept
/// deliberately simple — one device is expected to mostly serve one patient,
/// but caregivers managing more than one elder shouldn't need a second app.
class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PatientSetupScreen())),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addPatientButton),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patientProvider.patients.length,
        itemBuilder: (context, index) {
          final patient = patientProvider.patients[index];
          final isActive = patientProvider.activePatient?.id == patient.id;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary,
                child: Text(patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(patient.name),
              subtitle: Text(l10n.ageValueLabel(patient.age)),
              trailing: isActive
                  ? Chip(label: Text(l10n.activeChip), backgroundColor: AppTheme.success,
                      labelStyle: const TextStyle(color: Colors.white))
                  : TextButton(
                      onPressed: () => patientProvider.setActivePatient(patient),
                      child: Text(l10n.switchToButton),
                    ),
            ),
          );
        },
      ),
    );
  }
}
