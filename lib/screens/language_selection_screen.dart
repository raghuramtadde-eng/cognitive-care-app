import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_locale_provider.dart';
import '../theme/app_theme.dart';
import 'role_selection_screen.dart';

/// The very first screen a brand-new device shows, before Role Selection --
/// and also reachable later (when [isInitialSetup] is false) to change the
/// choice, via a language icon on Role Selection / the Caregiver home
/// screen. Deliberately carries NO English instruction text: an elderly
/// patient who only reads Assamese or Manipuri must still be able to use
/// this screen unaided, so each option is labelled only in its own
/// language/script, exactly as it would appear to a native reader.
class LanguageSelectionScreen extends StatelessWidget {
  final bool isInitialSetup;
  const LanguageSelectionScreen({super.key, this.isInitialSetup = false});

  Future<void> _choose(BuildContext context, String code) async {
    await context.read<AppLocaleProvider>().setLanguage(code);
    if (!context.mounted) return;
    if (isInitialSetup) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isInitialSetup
          ? null
          : AppBar(
              title: Text(AppLocalizations.of(context)!.languageTooltip),
              backgroundColor: Colors.transparent,
              elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LanguageCard(
                script: 'অসমীয়া',
                latin: 'Assamese',
                color: AppTheme.primary,
                onTap: () => _choose(context, 'as'),
              ),
              const SizedBox(height: 20),
              _LanguageCard(
                script: 'মেইতেই / ꯃꯤꯇꯩ',
                latin: 'Manipuri / Meitei',
                color: AppTheme.accent,
                onTap: () => _choose(context, 'mni'),
              ),
              const SizedBox(height: 20),
              _LanguageCard(
                script: 'English',
                latin: '',
                color: AppTheme.success,
                onTap: () => _choose(context, 'en'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String script;
  final String latin;
  final Color color;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.script,
    required this.latin,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          child: Column(
            children: [
              Text(script,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                  textAlign: TextAlign.center),
              if (latin.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(latin,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
