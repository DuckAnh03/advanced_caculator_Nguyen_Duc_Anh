import 'package:flutter/material.dart';
import '../models/calculator_settings.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  late CalculatorSettings _settings;

  ThemeProvider() {
    _settings = StorageService.loadSettings();
  }

  // ─── Getters ────────────────────────────────────────────────────────────

  AppTheme get appTheme => _settings.theme;

  ThemeMode get themeMode {
    switch (_settings.theme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
    }
  }

  // ─── Actions ────────────────────────────────────────────────────────────

  Future<void> setTheme(AppTheme theme) async {
    _settings = _settings.copyWith(theme: theme);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  // ─── Theme Data ─────────────────────────────────────────────────────────

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      tertiary: AppColors.lightAccent,
      surface: AppColors.lightSurface,
    ),
    fontFamily: AppFonts.family,
    useMaterial3: true,
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      tertiary: AppColors.darkAccent,
      surface: AppColors.darkSurface,
    ),
    fontFamily: AppFonts.family,
    useMaterial3: true,
  );
}
