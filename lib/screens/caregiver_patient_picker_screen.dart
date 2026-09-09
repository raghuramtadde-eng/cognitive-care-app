import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';

/// Shown right after caregiver login whenever there's more than one patient
/// on the account -- picking one up front means the whole Caregiver
/// Dashboard, Daily Routine, and Memory Lane session that follows is
/// unambiguous, instead of the caregiver having to dig into the Patients
/// screen and tap "Switch to" after the fact. A caregiver with only one
/// patient never sees this screen at all (see caregiver_auth_gate.dart).
class CaregiverPatientPickerScreen extends StatelessWidget {
  final List<Patient> patients;
  final ValueChanged<Patient> onSelected;

  const CaregiverPatientPickerScreen({
    super.key,
    required this.patients,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.choosePatientTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(l10n.choosePatientSubtitle,
                style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      child: Text(
                          patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(patient.name, style: const TextStyle(fontSize: 20)),
                    subtitle: Text(l10n.ageValueLabel(patient.age)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => onSelected(patient),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
