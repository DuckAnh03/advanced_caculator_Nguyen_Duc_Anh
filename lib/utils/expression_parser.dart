import 'package:math_expressions/math_expressions.dart';
import '../models/calculator_mode.dart';
import 'calculator_logic.dart';

/// Parses and evaluates mathematical expression strings.
/// Wraps the `math_expressions` package and adds preprocessing
/// for implicit multiplication, constants, and angle conversion.
class ExpressionParser {
  ExpressionParser._();

  static final Parser _parser = Parser();

  // ─── Main Entry Point ────────────────────────────────────────────────────

  /// Evaluates [expression] and returns the result as a formatted string.
  /// Throws [CalculatorException] on parse or evaluation errors.
  static String evaluate(
    String expression, {
    AngleMode angleMode = AngleMode.degrees,
    int precision = 10,
  }) {
    final prepared = _preprocess(expression, angleMode);

    try {
      final exp = _parser.parse(prepared);
      final context = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, context) as double;

      if (result.isNaN || result.isInfinite) {
        throw CalculatorException(
          result.isNaN ? 'Math Error' : (result > 0 ? '∞' : '-∞'),
        );
      }

      final cleaned = CalculatorLogic.cleanFloatingPoint(
        result,
        precision: precision,
      );
      return CalculatorLogic.formatResult(cleaned, precision: precision);
    } on CalculatorException {
      rethrow;
    } catch (e) {
      throw CalculatorException('Invalid expression');
    }
  }

  // ─── Preprocessing ───────────────────────────────────────────────────────

  /// Transforms a user-facing expression string into one the parser accepts.
  static String _preprocess(String expression, AngleMode angleMode) {
    String s = expression.trim();

    // Replace display symbols with parser-compatible ones
    s = s.replaceAll('×', '*');
    s = s.replaceAll('÷', '/');
    s = s.replaceAll('−', '-'); // minus sign vs hyphen
    s = s.replaceAll('%', '/100');
    s = s.replaceAll('π', '${CalculatorLogic.pi}');

    // Replace √ with sqrt() function
    s = _replaceSqrt(s);

    // Replace ∛ with cbrt() function
    s = _replaceCbrt(s);

    // Trig / log functions with angle conversion BEFORE replacing 'e'
    // so that function names like ln() and log() aren't corrupted
    s = _expandFunctions(s, angleMode);

    // Replace 'e' after function expansion to avoid corrupting function names
    s = s.replaceAll('e', '${CalculatorLogic.e}'); // Euler's number

    // Implicit multiplication: 2π → 2*π, (3)(4) → (3)*(4), 2( → 2*(
    s = _addImplicitMultiplication(s);

    return s;
  }

  /// Inserts `*` for implicit multiplication patterns.
  static String _addImplicitMultiplication(String s) {
    // digit followed by '(' → digit * (
    s = s.replaceAllMapped(RegExp(r'(\d)(\()'), (m) => '${m[1]}*${m[2]}');
    // ')' followed by digit or '(' → ) * digit  or  ) * (
    s = s.replaceAllMapped(RegExp(r'(\))(\d|\()'), (m) => '${m[1]}*${m[2]}');
    return s;
  }

  /// Helper to find matching closing parenthesis
  static int _findMatchingParen(String s, int startIndex) {
    int depth = 1;
    int i = startIndex + 1;
    while (i < s.length && depth > 0) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') depth--;
      i++;
    }
    return i - 1;
  }

  /// Replace √(...) with sqrt(...) or √number with sqrt(number)
  static String _replaceSqrt(String s) {
    // Handle √(...) pattern
    s = s.replaceAllMapped(RegExp(r'√\(([^)]+)\)'), (m) => 'sqrt(${m[1]})');

    // Handle √number pattern (e.g., √16 → sqrt(16))
    s = s.replaceAllMapped(RegExp(r'√(\d+(?:\.\d+)?)'), (m) => 'sqrt(${m[1]})');

    return s;
  }

  /// Replace ∛(...) with cbrt(...) or ∛number with cbrt(number)
  static String _replaceCbrt(String s) {
    // Handle ∛(...) pattern
    s = s.replaceAllMapped(RegExp(r'∛\(([^)]+)\)'), (m) => 'cbrt(${m[1]})');

    // Handle ∛number pattern (e.g., ∛27 → cbrt(27))
    s = s.replaceAllMapped(RegExp(r'∛(\d+(?:\.\d+)?)'), (m) => 'cbrt(${m[1]})');

    return s;
  }

  /// Replace log(...) with (ln(...)/ln(10)) for base-10 logarithm
  static String _replaceLog10(String s) {
    var result = '';
    var i = 0;
    const logStr = 'log(';
    const lnDivisor = 'ln(10)';

    while (i < s.length) {
      if (i + 3 < s.length && s.substring(i, i + 4) == logStr) {
        int closeParen = _findMatchingParen(s, i + 3);
        String arg = s.substring(i + 4, closeParen);
        result += '(ln($arg)/$lnDivisor)';
        i = closeParen + 1;
      } else {
        result += s[i];
        i++;
      }
    }
    return result;
  }

  /// Replaces named functions with their numeric equivalents,
  /// applying degree→radian conversion where needed.
  static String _expandFunctions(String s, AngleMode angleMode) {
    // For functions that need angle conversion, wrap the argument.
    // e.g. sin(45) → sin(45 * π/180)  when in degrees mode.
    if (angleMode == AngleMode.degrees) {
      final degToRad = '*(${CalculatorLogic.pi}/180)';
      final trigFunctions = ['sin', 'cos', 'tan'];
      for (final fn in trigFunctions) {
        // Match fn( ... ) — simple single-level parentheses
        s = s.replaceAllMapped(
          RegExp('$fn\\(([^)]+)\\)'),
          (m) => '$fn((${m[1]})$degToRad)',
        );
      }

      // Inverse trig: result is in radians, convert back to degrees
      final radToDeg = '*(180/${CalculatorLogic.pi})';
      final invFunctions = ['asin', 'acos', 'atan'];
      for (final fn in invFunctions) {
        s = s.replaceAllMapped(
          RegExp('$fn\\(([^)]+)\\)'),
          (m) => '($fn(${m[1]})$radToDeg)',
        );
      }
    }

    // cbrt(x) = x^(1/3) - cube root (not directly supported)
    s = s.replaceAllMapped(
      RegExp(r'cbrt\(([^)]+)\)'),
      (m) => 'pow(${m[1]},1/3)',
    );

    // log(x) = log base 10 of x; convert to ln(x)/ln(10)
    s = _replaceLog10(s);

    // log2(x) = log base 2 of x; convert to ln(x)/ln(2)
    s = s.replaceAllMapped(
      RegExp(r'log2\(([^)]+)\)'),
      (m) => '(ln(${m[1]})/ln(2))',
    );

    return s;
  }

  // ─── Validation & Utility ────────────────────────────────────────────────

  /// Returns true if parentheses in [expression] are balanced.
  static bool isBalanced(String expression) {
    int depth = 0;
    for (final ch in expression.runes) {
      if (ch == '('.codeUnitAt(0)) depth++;
      if (ch == ')'.codeUnitAt(0)) depth--;
      if (depth < 0) return false;
    }
    return depth == 0;
  }

  /// Appends closing parentheses until the expression is balanced.
  static String autoClose(String expression) {
    int depth = 0;
    for (final ch in expression.runes) {
      if (ch == '('.codeUnitAt(0)) depth++;
      if (ch == ')'.codeUnitAt(0)) depth--;
    }
    return expression + (')' * depth.clamp(0, 20));
  }

  /// Returns the last number token from [expression], or empty string.
  static String lastNumber(String expression) {
    final match = RegExp(r'[\d.]+$').firstMatch(expression);
    return match?.group(0) ?? '';
  }

  /// Returns true if [expression] ends with an operator.
  static bool endsWithOperator(String expression) {
    return RegExp(r'[+\-*/^%]$').hasMatch(expression.trim());
  }

  /// Returns true if [expression] ends with a digit or closing paren.
  static bool canAppendEquals(String expression) {
    return RegExp(r'[\d)π]$').hasMatch(expression.trim());
  }
}
