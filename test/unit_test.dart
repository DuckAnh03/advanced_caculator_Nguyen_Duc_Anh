import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_caculator/utils/expression_parser.dart';
import 'package:advanced_caculator/utils/calculator_logic.dart';
import 'package:advanced_caculator/models/calculator_mode.dart';
import 'package:advanced_caculator/providers/calculator_provider.dart';
import 'package:advanced_caculator/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('Memory Operations', () {
    late CalculatorProvider calculator;

    setUpAll(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      // Initialize StorageService
      await StorageService.init();
    });

    setUp(() {
      calculator = CalculatorProvider();
      calculator.memoryClear(); // Start with clean memory
    });

    test('Memory Add (M+): 5 M+ 3 M+ MR = 8', () {
      // Step 1: Enter 5
      calculator.appendInput('5');
      expect(calculator.expression, '5');

      // Step 2: Press M+ (add 5 to memory)
      calculator.memoryAdd();
      expect(calculator.memory, 5.0);
      expect(calculator.memoryHasValue, true);

      // Step 3: Clear expression and enter 3
      calculator.appendInput('3');
      expect(calculator.expression, '3');

      // Step 4: Press M+ (add 3 to memory, total = 8)
      calculator.memoryAdd();
      expect(calculator.memory, 8.0);
      expect(calculator.memoryHasValue, true);

      // Step 5: Press MR (recall memory value)
      calculator.memoryRecall();
      expect(calculator.expression, '8');

      // Step 6: Verify by evaluating
      calculator.evaluate();
      expect(calculator.result, '8');
    });

    test('Memory Subtract (M-): 10 M+ 3 M- MR = 7', () {
      calculator.memoryClear();

      // Add 10 to memory
      calculator.appendInput('1');
      calculator.appendInput('0');
      calculator.memoryAdd();
      expect(calculator.memory, 10.0);

      // Clear and subtract 3 from memory
      calculator.clearAll();
      calculator.appendInput('3');
      calculator.memorySubtract();
      expect(calculator.memory, 7.0);

      // Recall and verify
      calculator.clearAll();
      calculator.memoryRecall();
      calculator.evaluate();
      expect(calculator.result, '7');
    });

    test('Memory Clear (MC)', () {
      // Add value to memory
      calculator.appendInput('5');
      calculator.memoryAdd();
      expect(calculator.memoryHasValue, true);

      // Clear memory
      calculator.memoryClear();
      expect(calculator.memory, 0.0);
      expect(calculator.memoryHasValue, false);
    });

    test('Multiple M+ operations accumulate correctly', () {
      final testCases = [
        (value: 2.0, expected: 2.0),
        (value: 3.0, expected: 5.0),
        (value: 5.0, expected: 10.0),
        (value: 7.0, expected: 17.0),
      ];

      for (var testCase in testCases) {
        calculator.clearAll();
        calculator.appendInput(testCase.value.toString());
        calculator.memoryAdd();
        expect(
          calculator.memory,
          testCase.expected,
          reason:
              'Memory should be ${testCase.expected} after adding ${testCase.value}',
        );
      }
    });
  });
}
