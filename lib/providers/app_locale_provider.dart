import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The device-wide language choice made once on first launch (see
/// language_selection_screen.dart) and changeable later from Role
/// Selection / the Caregiver home screen's language icon. Governs every
/// screen shown before a specific patient is active -- Role Selection and
/// the patient picker. Once a patient is active, PatientProvider.locale
/// takes over instead (see main.dart), same as before this feature existed.
class AppLocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'device_locale_code';
  static const _supportedCodes = {'en', 'as', 'mni'};

  String? _code;

  /// False only in the brief window between construction and [load]
  /// completing -- main.dart awaits [load] before runApp, so in practice
  /// the rest of the app never sees this false.
  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// True once the caregiver/patient has made a choice (persisted). False
  /// on a genuinely fresh install -- that's what sends the app to
  /// LanguageSelectionScreen instead of Role Selection on cold launch.
  bool get hasChosen => _code != null;

  Locale get locale => Locale(_code ?? 'en');

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _code = prefs.getString(_prefsKey);
    _loaded = true;
  }

  Future<void> setLanguage(String code) async {
    if (!_supportedCodes.contains(code)) return;
    _code = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }
}
