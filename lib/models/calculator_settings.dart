import 'dart:convert';
import 'calculator_mode.dart';

enum AppTheme { light, dark }

extension AppThemeExtension on AppTheme {
  String get label {
    switch (this) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
    }
  }

  String get key => toString().split('.').last;

  static AppTheme fromKey(String key) {
    return AppTheme.values.firstWhere(
      (e) => e.key == key,
      orElse: () => AppTheme.light,
    );
  }
}

class CalculatorSettings {
  final AppTheme theme;
  final int decimalPrecision; // 2–10
  final AngleMode angleMode;
  final bool hapticFeedback;
  final bool soundEffects;
  final int historySize; // 25 | 50 | 100
  final CalculatorMode lastMode;

  const CalculatorSettings({
    this.theme = AppTheme.light,
    this.decimalPrecision = 6,
    this.angleMode = AngleMode.degrees,
    this.hapticFeedback = true,
    this.soundEffects = false,
    this.historySize = 50,
    this.lastMode = CalculatorMode.basic,
  });

  CalculatorSettings copyWith({
    AppTheme? theme,
    int? decimalPrecision,
    AngleMode? angleMode,
    bool? hapticFeedback,
    bool? soundEffects,
    int? historySize,
    CalculatorMode? lastMode,
  }) {
    return CalculatorSettings(
      theme: theme ?? this.theme,
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      angleMode: angleMode ?? this.angleMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      historySize: historySize ?? this.historySize,
      lastMode: lastMode ?? this.lastMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'theme': theme.key,
    'decimalPrecision': decimalPrecision,
    'angleMode': angleMode.key,
    'hapticFeedback': hapticFeedback,
    'soundEffects': soundEffects,
    'historySize': historySize,
    'lastMode': lastMode.key,
  };

  factory CalculatorSettings.fromJson(Map<String, dynamic> json) {
    return CalculatorSettings(
      theme: AppThemeExtension.fromKey(json['theme'] as String? ?? ''),
      decimalPrecision: json['decimalPrecision'] as int? ?? 6,
      angleMode: AngleModeExtension.fromKey(json['angleMode'] as String? ?? ''),
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      soundEffects: json['soundEffects'] as bool? ?? false,
      historySize: json['historySize'] as int? ?? 50,
      lastMode: CalculatorModeExtension.fromKey(
        json['lastMode'] as String? ?? '',
      ),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory CalculatorSettings.fromJsonString(String jsonString) {
    return CalculatorSettings.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }
}
