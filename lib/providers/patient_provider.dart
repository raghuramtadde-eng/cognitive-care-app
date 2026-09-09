import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/patient.dart';
import '../services/database_service.dart';
import '../services/patient_credential_service.dart';
import '../services/sync_service.dart';

/// Thrown by [PatientProvider.createPatient] when the requested Patient
/// User ID is already taken by another patient -- checked globally (not
/// just among this caregiver's own patients), since a User ID must
/// uniquely identify one patient account across the whole app.
class UserIdTakenException implements Exception {}

/// Holds the patient profiles belonging to the currently signed-in
/// caregiver, and which one is currently active on this device. Scoped
/// entirely by `caregiverId` — a caregiver only ever sees their own
/// patients, both locally and (once synced) in Supabase via RLS.
class PatientProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  String? _caregiverId;
  List<Patient> _patients = [];
  Patient? _activePatient;
  bool _loading = true;

  // Deliberately separate from `activePatient`: loadForCaregiver() below
  // sets a *default* active patient purely for other screens' convenience
  // (e.g. which patient's routine the caregiver is currently editing) the
  // moment a caregiver's roster loads — well before Patient Mode is
  // actually entered. main.dart needs to know specifically whether a
  // patient has actually logged in this session, not just whether some
  // default patient happens to be cached, or the pre-login screens would
  // incorrectly follow a stale cached patient's language (see
  // PatientLoginScreen._submit() and RoleSelectionScreen, which resets
  // this on every return visit).
  bool _patientModeActive = false;
  bool get patientModeActive => _patientModeActive;
  void enterPatientMode() {
    _patientModeActive = true;
    notifyListeners();
  }
  void exitPatientMode() {
    _patientModeActive = false;
    notifyListeners();
  }

  List<Patient> get patients => _patients;
  Patient? get activePatient => _activePatient;
  bool get loading => _loading;
  bool get hasAnyPatient => _patients.isNotEmpty;

  // Drives MaterialApp's locale so patient-facing screens follow whichever
  // patient is logged in, not the device's system language -- multiple
  // patients on one shared tablet may each have a different preference.
  // Falls back to English for a language code we don't ship a translation
  // for yet, rather than crashing on an unsupported locale.
  static const _supportedLanguageCodes = {'en', 'as', 'mni'};
  Locale get locale {
    final lang = _activePatient?.language;
    return Locale(_supportedLanguageCodes.contains(lang) ? lang! : 'en');
  }

  String _activePatientKey(String caregiverId) => 'active_patient_id_$caregiverId';

  /// Call whenever the signed-in caregiver changes (login, logout, switch
  /// account). Loading with a null id clears everything back to empty.
  Future<void> loadForCaregiver(String? caregiverId) async {
    _loading = true;
    notifyListeners();

    _caregiverId = caregiverId;
    if (caregiverId == null) {
      _patients = [];
      _activePatient = null;
      _loading = false;
      notifyListeners();
      return;
    }

    _patients = await _db.getPatientsForCaregiver(caregiverId);
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_activePatientKey(caregiverId));
    if (savedId != null) {
      _activePatient =
          _patients.where((p) => p.id == savedId).cast<Patient?>().firstOrNull;
    }
    _activePatient ??= _patients.isNotEmpty ? _patients.first : null;
    _loading = false;
    notifyListeners();
  }

  static String _normalizeUserId(String userId) => userId.trim().toLowerCase();

  /// Best-effort GLOBAL uniqueness check (across every caregiver's
  /// patients, not just this one's) via a narrow Postgres function -- RLS
  /// on the patients table correctly stops a caregiver's own session from
  /// seeing other caregivers' rows, so a true global check needs this
  /// additive, boolean-only escape hatch (see is_patient_user_id_taken() in
  /// supabase_schema.sql). Returns null (not false) when it couldn't be
  /// checked at all (offline, no session, RPC error) -- callers must treat
  /// null as "unknown", not "not taken", and fall back to the local check.
  Future<bool?> checkUserIdTakenRemotely(String userId) async {
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentSession == null) return null;
      final result = await client.rpc('is_patient_user_id_taken',
          params: {'p_user_id': _normalizeUserId(userId)});
      return result as bool;
    } catch (e) {
      debugPrint('User ID availability check failed (offline?): $e');
      return null;
    }
  }

  /// Creates a patient with the given Patient User ID + password. Throws
  /// [UserIdTakenException] without writing anything if the User ID is
  /// already taken -- checked globally online when possible, falling back
  /// to a same-device check (still enforced by a UNIQUE index locally, see
  /// database_service.dart) so patient creation keeps working offline.
  /// A genuine cross-device collision that slips past both checks is
  /// caught by Supabase's own UNIQUE constraint at the next sync, the same
  /// way every other sync conflict in this app is handled -- silently
  /// retried, never surfaced (see SyncService).
  Future<Patient> createPatient({
    required String name,
    required int age,
    required String language,
    CulturalTheme culturalTheme = CulturalTheme.generalNer,
    required String userId,
    required String password,
  }) async {
    final caregiverId = _caregiverId;
    if (caregiverId == null) {
      throw StateError('Cannot create a patient without a signed-in caregiver.');
    }
    final normalizedUserId = _normalizeUserId(userId);

    final remotelyTaken = await checkUserIdTakenRemotely(normalizedUserId);
    if (remotelyTaken == true) throw UserIdTakenException();
    if (remotelyTaken == null) {
      final localMatch = await _db.getPatientByUserId(normalizedUserId);
      if (localMatch != null) throw UserIdTakenException();
    }

    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    final patient = Patient(
      id: id,
      caregiverId: caregiverId,
      name: name,
      age: age,
      language: language,
      culturalTheme: culturalTheme,
      userId: normalizedUserId,
      passwordHash: PatientCredentialService.hash(id, password),
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );
    await _db.upsertPatient(patient);
    _patients = await _db.getPatientsForCaregiver(caregiverId);
    await setActivePatient(patient);
    notifyListeners();
    SyncService.instance.syncNow();
    return patient;
  }

  /// Patient login -- looks up the User ID only among the CURRENTLY
  /// signed-in caregiver's own patients (`_patients`, populated by
  /// loadForCaregiver above). That's the same data scope patient lookup has
  /// always used in this app; a User ID belonging to a different
  /// caregiver's patient simply won't be found here, which is correct --
  /// this device's cached Supabase session couldn't read that patient's
  /// data anyway (see supabase_schema.sql's RLS policies).
  Patient? authenticatePatient(String userId, String password) {
    final normalizedUserId = _normalizeUserId(userId);
    for (final p in _patients) {
      if (p.userId == normalizedUserId) {
        return PatientCredentialService.verify(p.id, password, p.passwordHash) ? p : null;
      }
    }
    return null;
  }

  Future<void> setActivePatient(Patient patient) async {
    _activePatient = patient;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activePatientKey(patient.caregiverId), patient.id);
    notifyListeners();
  }

  // ---------------- Remember this device ----------------
  //
  // Device-wide (not caregiver-scoped) -- the real deployment this app is
  // built for is one tablet per patient, kept at their own bedside. On a
  // successful login with "remember this device" checked, a random session
  // token is generated and only ITS HASH is stored on the patient's own
  // row (never the password); the raw token plus the User ID (not a
  // secret -- just an identifier) are cached in SharedPreferences. A later
  // launch that presents a valid token skips straight to that exact
  // patient's Home with no password re-entry. "Exit Patient Mode" (see
  // patient_mode_screen.dart) invalidates the token both locally and on
  // the patient's row, so a stale remembered session can never be reused,
  // and the next entry falls back to the full User ID + password login.
  static const _rememberedUserIdKey = 'remembered_patient_user_id';
  static const _rememberedTokenKey = 'remembered_patient_session_token';

  Future<void> rememberPatientSession(Patient patient) async {
    final token = _uuid.v4();
    final updated = patient.copyWith(
      sessionTokenHash: PatientCredentialService.hash(patient.id, token),
      isSynced: false,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await _db.upsertPatient(updated);
    _patients = [
      for (final p in _patients) p.id == updated.id ? updated : p,
    ];
    if (_activePatient?.id == updated.id) _activePatient = updated;
    SyncService.instance.syncNow();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rememberedUserIdKey, patient.userId);
    await prefs.setString(_rememberedTokenKey, token);
    notifyListeners();
  }

  Future<({String userId, String token})?> getRememberedPatientSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_rememberedUserIdKey);
    final token = prefs.getString(_rememberedTokenKey);
    if (userId == null || token == null) return null;
    return (userId: userId, token: token);
  }

  /// Only searches `_patients` (this caregiver's own, see loadForCaregiver)
  /// -- same data-scope reasoning as [authenticatePatient] above.
  Patient? validateRememberedSession(String userId, String token) {
    for (final p in _patients) {
      if (p.userId == userId) {
        final expectedHash = p.sessionTokenHash;
        if (expectedHash == null) return null;
        return PatientCredentialService.hash(p.id, token) == expectedHash ? p : null;
      }
    }
    return null;
  }

  /// Clears the remembered device locally, and -- when the patient whose
  /// session it was is known -- invalidates that token on their own row
  /// too, so it can never be replayed even from a synced copy elsewhere.
  Future<void> forgetRememberedPatientDevice({Patient? currentPatient}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberedUserIdKey);
    await prefs.remove(_rememberedTokenKey);

    if (currentPatient != null && currentPatient.sessionTokenHash != null) {
      final updated = currentPatient.copyWith(
        sessionTokenHash: null,
        isSynced: false,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _db.upsertPatient(updated);
      _patients = [
        for (final p in _patients) p.id == updated.id ? updated : p,
      ];
      if (_activePatient?.id == updated.id) _activePatient = updated;
      SyncService.instance.syncNow();
      notifyListeners();
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
