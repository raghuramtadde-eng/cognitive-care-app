import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'l10n/app_localizations.dart';
import 'l10n/fallback_locale_delegates.dart';
import 'providers/app_locale_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/routine_provider.dart';
import 'screens/language_selection_screen.dart';
import 'screens/role_selection_screen.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  await NotificationService.instance.init();
  SyncService.instance.startWatching();

  final appLocale = AppLocaleProvider();
  await appLocale.load();

  runApp(CognitiveCareApp(appLocale: appLocale));
}

class CognitiveCareApp extends StatelessWidget {
  final AppLocaleProvider appLocale;
  const CognitiveCareApp({super.key, required this.appLocale});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appLocale),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
      ],
      child: Consumer2<PatientProvider, AppLocaleProvider>(
        builder: (context, patientProvider, appLocaleProvider, _) => MaterialApp(
          title: 'Cognitive Care',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          // Before Patient Mode is actually entered (a confirmed User
          // ID + password login), the device-wide first-launch choice
          // (AppLocaleProvider) governs Role Selection; once inside
          // Patient Mode, that patient's own stored language takes over,
          // same as before this feature existed — see PatientProvider.locale.
          // Deliberately NOT `activePatient != null`: loadForCaregiver()
          // sets a *default* active patient the moment a caregiver's
          // roster loads, well before any patient login is confirmed,
          // which would otherwise leak that cached patient's language
          // onto the pre-login screens.
          locale: patientProvider.patientModeActive
              ? patientProvider.locale
              : appLocaleProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            // Manipuri isn't one of the languages flutter_localizations
            // ships built-in strings for -- see fallback_locale_delegates.dart.
            MniMaterialLocalizationsDelegate(),
            MniWidgetsLocalizationsDelegate(),
            MniCupertinoLocalizationsDelegate(),
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          // A brand-new device (no language chosen yet) starts at the
          // script-only language picker; every later launch goes straight
          // to Role Selection — the app's one true entry point otherwise,
          // reached again on every mode exit via pushAndRemoveUntil (see
          // role_selection_screen.dart for why that guarantees the
          // caregiver and patient interfaces never share a screen).
          home: appLocaleProvider.hasChosen
              ? const RoleSelectionScreen()
              : const LanguageSelectionScreen(isInitialSetup: true),
        ),
      ),
    );
  }
}
