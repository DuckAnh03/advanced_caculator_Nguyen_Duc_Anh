import 'package:flutter/material.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import '../services/storage_service.dart';
import '../utils/calculator_logic.dart';
import '../utils/expression_parser.dart';

class CalculatorProvider extends ChangeNotifier {
  // ─── State ──────────────────────────────────────────────────────────────

  String _expression = ''; // what the user is building
  String _result = ''; // evaluated result shown below
  String _error = ''; // error message (empty = no error)
  bool _justEvaluated = false; // true right after pressing "="

  CalculatorMode _mode = CalculatorMode.basic;
  AngleMode _angleMode = AngleMode.degrees;
  ProgrammerBase _programmerBase = ProgrammerBase.decimal;

  double _memory = 0.0;
  bool _memoryHasValue = false;

  bool _shiftActive = false; // "2nd" button in scientific mode

  late CalculatorSettings _settings;

  // ─── Init ────────────────────────────────────────────────────────────────

  CalculatorProvider() {
    _settings = StorageService.loadSettings();
    _mode = _settings.lastMode;
    _angleMode = _settings.angleMode;
    _memory = StorageService.loadMemory();
    _memoryHasValue = _memory != 0.0;
  }

  // ─── Getters ────────────────────────────────────────────────────────────

  String get expression => _expression;
  String get result => _result;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;
  bool get justEvaluated => _justEvaluated;

  CalculatorMode get mode => _mode;
  AngleMode get angleMode => _angleMode;
  ProgrammerBase get programmerBase => _programmerBase;

  double get memory => _memory;
  bool get memoryHasValue => _memoryHasValue;
  bool get shiftActive => _shiftActive;

  CalculatorSettings get settings => _settings;

  // ─── Input Handling ──────────────────────────────────────────────────────

  /// Called when a digit or symbol button is tapped.
  void appendInput(String value) {
    _clearError();

    // If just evaluated and user types a digit → start fresh
    if (_justEvaluated && _isDigitOrDot(value)) {
      _expression = '';
      _result = '';
    }
    _justEvaluated = false;

    // If just evaluated and user types an operator → continue from result
    if (_justEvaluated && _isOperator(value) && _result.isNotEmpty) {
      _expression = _result;
    }

    _expression += value;
    notifyListeners();
  }

  /// Evaluate the full expression on "=" press.
  void evaluate() {
    if (_expression.isEmpty) return;
    _clearError();

    try {
      final closed = ExpressionParser.autoClose(_expression);
      final res = ExpressionParser.evaluate(
        closed,
        angleMode: _angleMode,
        precision: _settings.decimalPrecision,
      );
      _result = res;
      _justEvaluated = true;
    } on CalculatorException catch (e) {
      _error = e.message;
      _result = '';
    }
    notifyListeners();
  }

  // ─── Clear / Delete ──────────────────────────────────────────────────────

  void clearEntry() {
    _error = '';
    _result = '';
    _expression = '';
    _justEvaluated = false;
    notifyListeners();
  }

  void clearLastChar() {
    _clearError();
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      notifyListeners();
    }
  }

  /// Swipe right on display → delete last character.
  void onSwipeRight() => clearLastChar();

  // ─── Scientific Actions ───────────────────────────────────────────────────
  bool _isImmediateFunction(String fn) {
    return ['x²', 'x³', '1/x', '±', '%', 'n!'].contains(fn);
  }

  void appendFunctionPrefix(String fn) {
    _clearError();

    if (_justEvaluated) {
      _expression = '';
      _result = '';
      _justEvaluated = false;
    }

    // ─── CASE 1: Function tính ngay (√, x², ±...) ───
    if (_isImmediateFunction(fn)) {
      final operand = _expression.isEmpty && _result.isNotEmpty
          ? _result
          : ExpressionParser.lastNumber(_expression);

      if (operand.isEmpty) return;

      try {
        final val = double.parse(operand);
        double? res;

        switch (fn) {
          case 'x²':
            res = CalculatorLogic.square(val);
            break;
          case 'x³':
            res = CalculatorLogic.cube(val);
            break;
          case '√':
            res = CalculatorLogic.sqrt(val);
            break;
          case '∛':
            res = CalculatorLogic.cbrt(val);
            break;
          case 'n!':
            res = CalculatorLogic.factorial(val);
            break;
          case '1/x':
            res = CalculatorLogic.reciprocal(val);
            break;
          case '±':
            res = CalculatorLogic.negate(val);
            break;
          case '%':
            res = CalculatorLogic.percent(val);
            break;
        }

        if (res != null) {
          final formatted = CalculatorLogic.formatResult(
            res,
            precision: _settings.decimalPrecision,
          );

          _expression = _expression.isEmpty
              ? formatted
              : _expression.substring(0, _expression.length - operand.length) +
                    formatted;

          _result = formatted;
          _justEvaluated = true;
        }
      } catch (_) {
        _error = 'Invalid input';
      }

      notifyListeners();
      return;
    }

    // ─── CASE 2: Function dạng fn(...) (sin, ln, log...) ───

    if (_expression.isNotEmpty) {
      final lastChar = _expression[_expression.length - 1];
      if (_isDigitOrDot(lastChar) || lastChar == ')') {
        _expression += '×';
      }
    }

    _expression += '$fn(';

    notifyListeners();
  }

  void insertConstant(String constant) {
    appendInput(constant);
  }

  void toggleShift() {
    _shiftActive = !_shiftActive;
    notifyListeners();
  }

  // ─── Memory ───────────────────────────────────────────────────────────────

  void memoryAdd() {
    final val = _currentValue();
    if (val == null) return;
    _memory += val;
    _memoryHasValue = _memory != 0.0;
    StorageService.saveMemory(_memory);
    notifyListeners();
  }

  void memorySubtract() {
    final val = _currentValue();
    if (val == null) return;
    _memory -= val;
    _memoryHasValue = _memory != 0.0;
    StorageService.saveMemory(_memory);
    notifyListeners();
  }

  void memoryRecall() {
    final formatted = CalculatorLogic.formatResult(
      _memory,
      precision: _settings.decimalPrecision,
    );
    if (_expression.isEmpty || _justEvaluated) {
      _expression = formatted;
    } else {
      _expression += formatted;
    }
    _justEvaluated = false;
    notifyListeners();
  }

  void memoryClear() {
    _memory = 0.0;
    _memoryHasValue = false;
    StorageService.clearMemory();
    notifyListeners();
  }

  // ─── Mode ─────────────────────────────────────────────────────────────────

  Future<void> setMode(CalculatorMode mode) async {
    _mode = mode;
    _shiftActive = false;
    _settings = _settings.copyWith(lastMode: mode);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  void toggleAngleMode() {
    _angleMode = _angleMode == AngleMode.degrees
        ? AngleMode.radians
        : AngleMode.degrees;
    _settings = _settings.copyWith(angleMode: _angleMode);
    StorageService.saveSettings(_settings);
    notifyListeners();
  }

  void setProgrammerBase(ProgrammerBase base) {
    _programmerBase = base;
    notifyListeners();
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  Future<void> updateSettings(CalculatorSettings settings) async {
    _settings = settings;
    _angleMode = settings.angleMode;
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  double? _currentValue() {
    final src = _result.isNotEmpty ? _result : _expression;
    return double.tryParse(src);
  }

  bool _isDigitOrDot(String v) => RegExp(r'^[\d.]$').hasMatch(v);
  bool _isOperator(String v) => RegExp(r'^[+\-×÷*/^%]$').hasMatch(v);

  void _clearError() {
    if (_error.isNotEmpty) {
      _error = '';
    }
  }

  // ─── Restore from History ──────────────────────────────────────────────

  void restoreFromHistory(String expression, String result) {
    _expression = expression;
    _result = result;
    _justEvaluated = true;
    _clearError();
    notifyListeners();
  }
}
