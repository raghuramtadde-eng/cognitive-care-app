import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import 'auth/login_screen.dart';
import 'caregiver_home_screen.dart';
import 'caregiver_patient_picker_screen.dart';
import 'patient_setup_screen.dart';

/// Everything the CAREGIVER role can reach lives behind this gate: login,
/// then (if no patients yet) first-time setup, then -- if the account has
/// more than one patient -- an explicit "which patient?" choice up front
/// (see caregiver_patient_picker_screen.dart), then the caregiver dashboard.
/// A caregiver with exactly one patient skips straight to the dashboard,
/// same reasoning as PatientAuthGate's single-patient auto-select. Nothing
/// rendered here ever exposes a patient-facing screen — entering Patient
/// Mode always goes back out through Role Selection.
class CaregiverAuthGate extends StatefulWidget {
  const CaregiverAuthGate({super.key});

  @override
  State<CaregiverAuthGate> createState() => _CaregiverAuthGateState();
}

class _CaregiverAuthGateState extends State<CaregiverAuthGate> {
  String? _loadedForCaregiverId;
  Patient? _selectedPatient;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final patientProviderRef = context.read<PatientProvider>();

    if (!auth.isLoggedIn) {
      _loadedForCaregiverId = null;
      _selectedPatient = null;
      return const LoginScreen();
    }

    final uid = auth.currentUser!.id;
    if (_loadedForCaregiverId != uid) {
      _loadedForCaregiverId = uid;
      _selectedPatient = null;
      Future.microtask(() => patientProviderRef.loadForCaregiver(uid));
    }

    final patientProvider = context.watch<PatientProvider>();
    if (patientProvider.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final patients = patientProvider.patients;
    if (patients.isEmpty) {
      return const PatientSetupScreen();
    }

    final target = _selectedPatient ?? (patients.length == 1 ? patients.first : null);
    if (target == null) {
      return CaregiverPatientPickerScreen(
        patients: patients,
        onSelected: (patient) {
          patientProvider.setActivePatient(patient);
          setState(() => _selectedPatient = patient);
        },
      );
    }

    // Keep the provider's activePatient in sync with our chosen target --
    // covers the single-patient auto-select case, where nothing has
    // explicitly called setActivePatient yet this session.
    if (patientProvider.activePatient?.id != target.id) {
      Future.microtask(() => patientProvider.setActivePatient(target));
    }

    return const CaregiverHomeScreen();
  }
}
