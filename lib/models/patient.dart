enum CulturalTheme { generalNer, assam, manipur }

extension CulturalThemeX on CulturalTheme {
  String get key => switch (this) {
        CulturalTheme.generalNer => 'general',
        CulturalTheme.assam => 'assam',
        CulturalTheme.manipur => 'manipur',
      };

  static CulturalTheme fromKey(String key) => switch (key) {
        'assam' => CulturalTheme.assam,
        'manipur' => CulturalTheme.manipur,
        _ => CulturalTheme.generalNer,
      };

  String get displayName => switch (this) {
        CulturalTheme.generalNer => 'General NER',
        CulturalTheme.assam => 'Assam',
        CulturalTheme.manipur => 'Manipur',
      };
}

class Patient {
  final String id;
  final String caregiverId;
  final String name;
  final int age;
  final String language; // 'en', 'as' (Assamese), 'mni' (Manipuri)
  // Deliberately independent of `language` above -- a caregiver may want
  // English UI with Assam-themed game content, or Assamese UI with Manipur
  // theme, etc. Never inferred from `language`; always an explicit
  // caregiver choice at patient setup (see patient_setup_screen.dart and
  // regional_theme_items.dart).
  final CulturalTheme culturalTheme;
  final String? photoPath;
  // Globally unique across every caregiver's patients (not just this
  // caregiver's own) -- see is_patient_user_id_taken() in
  // supabase_schema.sql. This, not the password, is what identifies the
  // exact patient account at login (see patient_login_screen.dart).
  final String userId;
  final String passwordHash;
  // Set only after a successful login with "remember this device" checked
  // (see PatientProvider.rememberPatientSession) -- lets the device skip
  // password re-entry via a random token instead of ever storing the
  // plaintext password. Null means no remembered session is active for
  // this patient.
  final String? sessionTokenHash;
  final String createdAt;
  final String updatedAt;
  final bool isSynced;

  Patient({
    required this.id,
    required this.caregiverId,
    required this.name,
    required this.age,
    required this.language,
    this.culturalTheme = CulturalTheme.generalNer,
    this.photoPath,
    required this.userId,
    required this.passwordHash,
    this.sessionTokenHash,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Patient copyWith({
    String? name,
    int? age,
    String? language,
    CulturalTheme? culturalTheme,
    String? photoPath,
    String? userId,
    String? passwordHash,
    Object? sessionTokenHash = _unset,
    String? updatedAt,
    bool? isSynced,
  }) {
    return Patient(
      id: id,
      caregiverId: caregiverId,
      name: name ?? this.name,
      age: age ?? this.age,
      language: language ?? this.language,
      culturalTheme: culturalTheme ?? this.culturalTheme,
      photoPath: photoPath ?? this.photoPath,
      userId: userId ?? this.userId,
      passwordHash: passwordHash ?? this.passwordHash,
      sessionTokenHash: identical(sessionTokenHash, _unset)
          ? this.sessionTokenHash
          : sessionTokenHash as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caregiverId': caregiverId,
      'name': name,
      'age': age,
      'language': language,
      'culturalTheme': culturalTheme.key,
      'photoPath': photoPath,
      'userId': userId,
      'passwordHash': passwordHash,
      'sessionTokenHash': sessionTokenHash,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      caregiverId: map['caregiverId'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      language: map['language'] as String,
      culturalTheme: CulturalThemeX.fromKey(map['culturalTheme'] as String? ?? 'general'),
      photoPath: map['photoPath'] as String?,
      userId: map['userId'] as String,
      passwordHash: map['passwordHash'] as String,
      sessionTokenHash: map['sessionTokenHash'] as String?,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      isSynced: (map['isSynced'] as int) == 1,
    );
  }
}

const _unset = Object();
