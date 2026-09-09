import 'package:flutter/material.dart';

/// Elderly-friendly design system: large text, high contrast, big tap
/// targets, minimal visual noise. Used everywhere so every phase looks and
/// behaves consistently.
class AppTheme {
  static const Color primary = Color(0xFF2D5F6B); // calm teal
  static const Color accent = Color(0xFFE07A3E); // warm orange for actions
  static const Color success = Color(0xFF2E7D4F);
  static const Color warning = Color(0xFFC65D2E);
  static const Color danger = Color(0xFFB3261E);
  static const Color background = Color(0xFFFAF7F2);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1C1B1F);

  static const double minTapTarget = 64.0;

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ).copyWith(
        headlineMedium: const TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: const TextStyle(fontSize: 20, color: textPrimary),
        bodyMedium: const TextStyle(fontSize: 18, color: textPrimary),
        labelLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, minTapTarget),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
