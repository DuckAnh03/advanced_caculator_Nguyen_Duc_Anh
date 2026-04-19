import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';
import '../models/calculator_settings.dart';
import '../utils/constants.dart';

/// Handles all read/write to SharedPreferences.
/// Every method is async and returns null/empty on failure
/// so callers don't need to handle exceptions.
class StorageService {
  StorageService._();

  static SharedPreferences? _prefs;

  /// Must be called once in main() before runApp().
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    assert(_prefs != null, 'StorageService.init() was not called');
    return _prefs!;
  }

  // ─── Settings ─────────────────────────────────────────────────────────

  static Future<bool> saveSettings(CalculatorSettings settings) async {
    return _p.setString(StorageKeys.settings, settings.toJsonString());
  }

  static CalculatorSettings loadSettings() {
    final raw = _p.getString(StorageKeys.settings);
    if (raw == null) return const CalculatorSettings();
    try {
      return CalculatorSettings.fromJsonString(raw);
    } catch (_) {
      return const CalculatorSettings();
    }
  }

  // ─── History ──────────────────────────────────────────────────────────

  static Future<bool> saveHistory(List<CalculationHistory> history) async {
    final encoded = jsonEncode(history.map((h) => h.toJson()).toList());
    return _p.setString(StorageKeys.history, encoded);
  }

  static List<CalculationHistory> loadHistory() {
    final raw = _p.getString(StorageKeys.history);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CalculationHistory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> clearHistory() async {
    return _p.remove(StorageKeys.history);
  }

  // ─── Memory Value ─────────────────────────────────────────────────────

  static Future<bool> saveMemory(double value) async {
    return _p.setDouble(StorageKeys.memory, value);
  }

  static double loadMemory() {
    return _p.getDouble(StorageKeys.memory) ?? 0.0;
  }

  static Future<bool> clearMemory() async {
    return _p.remove(StorageKeys.memory);
  }

  // ─── Utility ──────────────────────────────────────────────────────────

  /// Wipes everything — useful for testing or "factory reset".
  static Future<bool> clearAll() async {
    return _p.clear();
  }
}
