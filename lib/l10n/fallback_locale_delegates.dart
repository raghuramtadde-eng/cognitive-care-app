import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Manipuri ('mni') has real translations in our own AppLocalizations, but
/// isn't one of the languages Flutter's own flutter_localizations package
/// ships built-in Material/Cupertino/Widgets strings for (unlike Assamese,
/// which Flutter does support) -- without these, any widget that needs
/// MaterialLocalizations (Scaffold, showDatePicker, TextField's selection
/// toolbar, etc.) crashes outright with "No MaterialLocalizations found"
/// the moment a patient or caregiver picks Manipuri. This is Flutter's own
/// documented gap and documented fix: a locale-specific fallback delegate
/// that satisfies the Type but serves the framework's built-in English
/// defaults, since there's no real Manipuri translation of "OK"/"Cancel"/
/// date-picker labels to fall back to instead. Only claims 'mni' -- English
/// and Assamese still resolve through Flutter's own delegates untouched.
class MniMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const MniMaterialLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mni';
  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const DefaultMaterialLocalizations();
  @override
  bool shouldReload(MniMaterialLocalizationsDelegate old) => false;
}

class MniCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const MniCupertinoLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mni';
  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      const DefaultCupertinoLocalizations();
  @override
  bool shouldReload(MniCupertinoLocalizationsDelegate old) => false;
}

class MniWidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const MniWidgetsLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mni';
  @override
  Future<WidgetsLocalizations> load(Locale locale) async =>
      const DefaultWidgetsLocalizations();
  @override
  bool shouldReload(MniWidgetsLocalizationsDelegate old) => false;
}
