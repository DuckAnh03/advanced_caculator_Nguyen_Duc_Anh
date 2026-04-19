import 'dart:math' as math;
import '../models/calculator_mode.dart';

/// Pure calculation logic — no Flutter / UI dependencies.
/// All methods are static so they can be tested without instantiation.
class CalculatorLogic {
  CalculatorLogic._();

  // ─── Basic Operations ────────────────────────────────────────────────────

  static double add(double a, double b) => a + b;
  static double subtract(double a, double b) => a - b;
  static double multiply(double a, double b) => a * b;

  static double divide(double a, double b) {
    if (b == 0) throw CalculatorException('Division by zero');
    return a / b;
  }

  static double modulo(double a, double b) {
    if (b == 0) throw CalculatorException('Modulo by zero');
    return a % b;
  }

  // ─── Trigonometric ───────────────────────────────────────────────────────

  /// Convert input to radians if needed, then apply [fn].
  static double _trig(
    double value,
    AngleMode mode,
    double Function(double) fn,
  ) {
    final rad = mode == AngleMode.degrees ? _toRadians(value) : value;
    return fn(rad);
  }

  static double sin(double value, AngleMode mode) =>
      _trig(value, mode, math.sin);

  static double cos(double value, AngleMode mode) =>
      _trig(value, mode, math.cos);

  static double tan(double value, AngleMode mode) {
    // tan(90°) is undefined
    if (mode == AngleMode.degrees && value % 180 == 90) {
      throw CalculatorException(
        'tan is undefined at ${value.toStringAsFixed(0)}°',
      );
    }
    return _trig(value, mode, math.tan);
  }

  static double asin(double value, AngleMode mode) {
    if (value < -1 || value > 1) {
      throw CalculatorException('asin domain error: value must be in [-1, 1]');
    }
    final result = math.asin(value);
    return mode == AngleMode.degrees ? _toDegrees(result) : result;
  }

  static double acos(double value, AngleMode mode) {
    if (value < -1 || value > 1) {
      throw CalculatorException('acos domain error: value must be in [-1, 1]');
    }
    final result = math.acos(value);
    return mode == AngleMode.degrees ? _toDegrees(result) : result;
  }

  static double atan(double value, AngleMode mode) {
    final result = math.atan(value);
    return mode == AngleMode.degrees ? _toDegrees(result) : result;
  }

  // ─── Logarithmic ─────────────────────────────────────────────────────────

  static double ln(double value) {
    if (value <= 0) {
      throw CalculatorException('ln domain error: value must be > 0');
    }
    return math.log(value);
  }

  static double log10(double value) {
    if (value <= 0) {
      throw CalculatorException('log domain error: value must be > 0');
    }
    return math.log(value) / math.ln10;
  }

  static double log2(double value) {
    if (value <= 0) {
      throw CalculatorException('log₂ domain error: value must be > 0');
    }
    return math.log(value) / math.ln2;
  }

  // ─── Power & Root ────────────────────────────────────────────────────────

  static double square(double value) => value * value;
  static double cube(double value) => value * value * value;

  static double power(double base, double exponent) =>
      math.pow(base, exponent).toDouble();

  static double sqrt(double value) {
    if (value < 0) {
      throw CalculatorException('√ domain error: value must be ≥ 0');
    }
    return math.sqrt(value);
  }

  static double cbrt(double value) {
    // Supports negative numbers: ∛(-8) = -2
    if (value < 0) return -math.pow(-value, 1 / 3).toDouble();
    return math.pow(value, 1 / 3).toDouble();
  }

  static double nthRoot(double value, double n) {
    if (n == 0) throw CalculatorException('0th root is undefined');
    if (value < 0 && n % 2 == 0) {
      throw CalculatorException('Even root of negative number');
    }
    if (value < 0) return -math.pow(-value, 1 / n).toDouble();
    return math.pow(value, 1 / n).toDouble();
  }

  // ─── Constants ───────────────────────────────────────────────────────────

  static const double pi = math.pi;
  static const double e = math.e;

  // ─── Misc ────────────────────────────────────────────────────────────────

  static double negate(double value) => -value;

  static double percent(double value) => value / 100;

  static double factorial(double value) {
    if (value < 0) {
      throw CalculatorException('Factorial of negative number is undefined');
    }
    if (value != value.floorToDouble()) {
      throw CalculatorException('Factorial requires an integer');
    }
    if (value > 170) {
      throw CalculatorException('Factorial overflow (max: 170!)');
    }
    int n = value.toInt();
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  static double reciprocal(double value) {
    if (value == 0) throw CalculatorException('Division by zero');
    return 1 / value;
  }

  // ─── Programmer Mode ─────────────────────────────────────────────────────

  static int bitwiseAnd(int a, int b) => a & b;
  static int bitwiseOr(int a, int b) => a | b;
  static int bitwiseXor(int a, int b) => a ^ b;
  static int bitwiseNot(int a) => ~a;
  static int shiftLeft(int a, int n) => a << n;
  static int shiftRight(int a, int n) => a >> n;

  static String toBase(int value, ProgrammerBase base) {
    switch (base) {
      case ProgrammerBase.binary:
        return value.toRadixString(2).toUpperCase();
      case ProgrammerBase.octal:
        return value.toRadixString(8).toUpperCase();
      case ProgrammerBase.decimal:
        return value.toString();
      case ProgrammerBase.hexadecimal:
        return '0x${value.toRadixString(16).toUpperCase()}';
    }
  }

  static int fromBase(String value, ProgrammerBase base) {
    final cleaned = value.toLowerCase().replaceFirst('0x', '');
    final parsed = int.tryParse(cleaned, radix: base.radix);
    if (parsed == null) {
      throw CalculatorException('Invalid number for ${base.label} base');
    }
    return parsed;
  }

  // ─── Formatting ──────────────────────────────────────────────────────────

  /// Format [value] to at most [precision] decimal places,
  /// removing unnecessary trailing zeros.
  static String formatResult(double value, {int precision = 10}) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    // Use scientific notation for very large or very small numbers
    final abs = value.abs();
    if (abs != 0 && (abs >= 1e15 || abs < 1e-9)) {
      return _formatScientific(value, precision);
    }

    // Remove trailing zeros
    final formatted = value.toStringAsFixed(precision);
    if (formatted.contains('.')) {
      return formatted
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return formatted;
  }

  static String _formatScientific(double value, int precision) {
    final str = value.toStringAsExponential(precision);
    // Clean trailing zeros in mantissa
    return str.replaceAll(RegExp(r'0+e'), 'e').replaceAll(RegExp(r'\.e'), 'e');
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static double _toRadians(double degrees) => degrees * math.pi / 180;
  static double _toDegrees(double radians) => radians * 180 / math.pi;

  /// Returns true if [value] is effectively an integer (e.g. 3.0000000001).
  static bool isEffectivelyInteger(double value, {double tolerance = 1e-10}) {
    return (value - value.roundToDouble()).abs() < tolerance;
  }

  /// Clean floating-point artefacts (e.g. 0.1 + 0.2 = 0.30000000000000004).
  static double cleanFloatingPoint(double value, {int precision = 10}) {
    return double.parse(value.toStringAsFixed(precision));
  }
}

// ─── Custom Exception ─────────────────────────────────────────────────────────

class CalculatorException implements Exception {
  final String message;
  const CalculatorException(this.message);

  @override
  String toString() => message;
}
