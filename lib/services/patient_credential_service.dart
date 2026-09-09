import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Hashes/verifies a patient's password (and remembered-device session
/// tokens) entirely on-device (no network needed -- patient login must work
/// offline). Salting with the patient's own id stops trivial cross-patient
/// rainbow-table reuse. Real protection against a stranger reading a
/// patient's data is still the caregiver's own Supabase account credentials
/// -- see supabase_schema.sql's AUTH MODEL note.
class PatientCredentialService {
  static String hash(String patientId, String secret) {
    final bytes = utf8.encode('$patientId:$secret');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String patientId, String secret, String storedHash) {
    return hash(patientId, secret) == storedHash;
  }
}
