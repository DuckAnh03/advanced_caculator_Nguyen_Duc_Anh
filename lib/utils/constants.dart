import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Light theme
  static const Color lightPrimary = Color(0xFF1E1E1E);
  static const Color lightSecondary = Color(0xFF424242);
  static const Color lightAccent = Color(0xFFFF6B6B);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1E1E1E);
  static const Color lightSubtext = Color(0xFF757575);

  // Dark theme
  static const Color darkPrimary = Color(0xFF121212);
  static const Color darkSecondary = Color(0xFF2C2C2C);
  static const Color darkAccent = Color(0xFF4ECDC4);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBg = Color(0xFF121212);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkSubtext = Color(0xFF9E9E9E);

  // Button color groups (used in both themes)
  static const Color operatorLight = Color(0xFFFF6B6B);
  static const Color operatorDark = Color(0xFF4ECDC4);
  static const Color functionLight = Color(0xFFB9B4C7);
  static const Color functionDark = Color(0xFF3A3A3A);
  static const Color equalsLight = Color(0xFFFF6B6B);
  static const Color equalsDark = Color(0xFF4ECDC4);
  static const Color numberLight = Color(0xFFECECEC);
  static const Color numberDark = Color(0xFF2C3947);
}

// ─── Typography ───────────────────────────────────────────────────────────────

class AppFonts {
  AppFonts._();

  static const String family = 'Roboto';

  static const TextStyle displayResult = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 32,
  );

  static const TextStyle displayExpression = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 20,
  );

  static const TextStyle historyItem = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w300, // Light
    fontSize: 18,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
  );

  static const TextStyle buttonLabelLarge = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w400,
    fontSize: 20,
  );
}

// ─── Dimensions ───────────────────────────────────────────────────────────────

class AppDimens {
  AppDimens._();

  static const double buttonSpacing = 12.0;
  static const double buttonRadius = 16.0;
  static const double displayRadius = 24.0;
  static const double screenPadding = 24.0;

  // Animation durations
  static const Duration buttonPressDuration = Duration(milliseconds: 200);
  static const Duration modeSwitchDuration = Duration(milliseconds: 300);
  static const Duration fadeInDuration = Duration(milliseconds: 250);
  static const Duration shakeErrorDuration = Duration(milliseconds: 400);
}

// ─── Storage Keys ─────────────────────────────────────────────────────────────

class StorageKeys {
  StorageKeys._();

  static const String settings = 'calculator_settings';
  static const String history = 'calculator_history';
  static const String memory = 'calculator_memory';
}
