import 'dart:convert';
import 'calculator_mode.dart';

class CalculationHistory {
  final String id;
  final String expression;
  final String result;
  final CalculatorMode mode;
  final DateTime timestamp;

  CalculationHistory({
    required this.id,
    required this.expression,
    required this.result,
    required this.mode,
    required this.timestamp,
  });

  factory CalculationHistory.create({
    required String expression,
    required String result,
    required CalculatorMode mode,
  }) {
    return CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      expression: expression,
      result: result,
      mode: mode,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'expression': expression,
    'result': result,
    'mode': mode.key,
    'timestamp': timestamp.toIso8601String(),
  };

  factory CalculationHistory.fromJson(Map<String, dynamic> json) {
    return CalculationHistory(
      id: json['id'] as String,
      expression: json['expression'] as String,
      result: json['result'] as String,
      mode: CalculatorModeExtension.fromKey(json['mode'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory CalculationHistory.fromJsonString(String jsonString) {
    return CalculationHistory.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  String toString() => '$expression = $result';
}
