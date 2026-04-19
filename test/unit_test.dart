import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_caculator/utils/expression_parser.dart';
import 'package:advanced_caculator/utils/calculator_logic.dart';
import 'package:advanced_caculator/models/calculator_mode.dart';

void main() {
  group('Calculator Tests', () {
    test('Basic arithmetic operations', () {
      expect(ExpressionParser.evaluate('5+3'), '8');
      expect(ExpressionParser.evaluate('10-4'), '6');
      expect(ExpressionParser.evaluate('6*7'), '42');
      expect(ExpressionParser.evaluate('15÷3'), '5');
    });

    test('Order of operations', () {
      expect(ExpressionParser.evaluate('2+3×4'), '14');
      expect(ExpressionParser.evaluate('(2+3)×4'), '20');
    });

    test('Scientific functions', () {
      expect(ExpressionParser.evaluate('sin(30)'), '0.5');
      expect(ExpressionParser.evaluate('√16'), '4');
    });

    test('Edge cases', () {
      expect(
        () => ExpressionParser.evaluate('5÷0'),
        throwsA(isA<CalculatorException>()),
      );
      expect(
        () => ExpressionParser.evaluate('√(-4)'),
        throwsA(isA<CalculatorException>()),
      );
    });
  });
}
