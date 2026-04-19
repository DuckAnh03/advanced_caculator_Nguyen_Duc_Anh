import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_mode.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../utils/constants.dart';
import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<CalculatorProvider>().mode;

    return AnimatedSwitcher(
      duration: AppDimens.modeSwitchDuration,
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: switch (mode) {
        CalculatorMode.basic => const _BasicGrid(key: ValueKey('basic')),
        CalculatorMode.scientific => const _ScientificGrid(
          key: ValueKey('sci'),
        ),
        CalculatorMode.programmer => const _ProgrammerGrid(
          key: ValueKey('prog'),
        ),
      },
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

/// Builds a uniform grid from a list of [_BtnDef].
Widget _buildGrid({
  required BuildContext context,
  required List<_BtnDef> buttons,
  required int columns,
  double spacing = AppDimens.buttonSpacing,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final cellW = (constraints.maxWidth - spacing * (columns - 1)) / columns;
      final cellH = cellW * 0.72; // aspect ratio

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: buttons.map((b) {
          final w = b.wide ? cellW * 2 + spacing : cellW;
          return SizedBox(
            width: w,
            height: cellH,
            child: _buildBtn(context, b),
          );
        }).toList(),
      );
    },
  );
}

Widget _buildBtn(BuildContext context, _BtnDef b) {
  final calc = context.read<CalculatorProvider>();
  final hist = context.read<HistoryProvider>();

  return CalculatorButton(
    label: b.label,
    type: b.type,
    isWide: b.wide,
    isActive: b.isActive?.call(context) ?? false,
    fontSize: b.fontSize,
    onTap: () => b.onTap(calc, hist),
    onLongPress: b.onLongPress != null
        ? () => b.onLongPress!(calc, hist)
        : null,
  );
}

void _commitResult(CalculatorProvider calc, HistoryProvider hist) {
  if (calc.expression.isEmpty) return;
  final expr = calc.expression;
  calc.evaluate();
  if (!calc.hasError && calc.result.isNotEmpty) {
    hist.addEntry(expression: expr, result: calc.result, mode: calc.mode);
  }
}

// ─── Button definition ───────────────────────────────────────────────────────

class _BtnDef {
  final String label;
  final ButtonType type;
  final bool wide;
  final double fontSize;
  final bool Function(BuildContext)? isActive;
  final void Function(CalculatorProvider, HistoryProvider) onTap;
  final void Function(CalculatorProvider, HistoryProvider)? onLongPress;

  const _BtnDef({
    required this.label,
    required this.type,
    required this.onTap,
    bool wide = false,
    double fontSize = 18,
    this.isActive,
    this.onLongPress,
  }) : wide = wide,
       fontSize = fontSize;
}

// ─── Basic grid (4 × 5) ──────────────────────────────────────────────────────

class _BasicGrid extends StatelessWidget {
  const _BasicGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final buttons = <_BtnDef>[
      _BtnDef(
        label: 'C',
        type: ButtonType.clear,
        onTap: (c, _) => c.clearEntry(),
        onLongPress: (c, h) {
          c.clearEntry();
          h.clearAll();
        },
      ),
      _BtnDef(
        label: 'CE',
        type: ButtonType.clear,
        onTap: (c, _) => c.clearLastChar(),
      ),
      _BtnDef(
        label: '%',
        type: ButtonType.function,
        onTap: (c, _) => c.appendFunctionPrefix('%'),
      ),
      _BtnDef(
        label: '÷',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('÷'),
      ),

      _BtnDef(
        label: '7',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('7'),
      ),
      _BtnDef(
        label: '8',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('8'),
      ),
      _BtnDef(
        label: '9',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('9'),
      ),
      _BtnDef(
        label: '×',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('×'),
      ),

      _BtnDef(
        label: '4',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('4'),
      ),
      _BtnDef(
        label: '5',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('5'),
      ),
      _BtnDef(
        label: '6',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('6'),
      ),
      _BtnDef(
        label: '-',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('-'),
      ),

      _BtnDef(
        label: '1',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('1'),
      ),
      _BtnDef(
        label: '2',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('2'),
      ),
      _BtnDef(
        label: '3',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('3'),
      ),
      _BtnDef(
        label: '+',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('+'),
      ),

      _BtnDef(
        label: '±',
        type: ButtonType.function,
        onTap: (c, _) => c.appendFunctionPrefix('±'),
      ),
      _BtnDef(
        label: '0',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('0'),
      ),
      _BtnDef(
        label: '.',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('.'),
      ),
      _BtnDef(
        label: '=',
        type: ButtonType.equals,
        onTap: (c, h) => _commitResult(c, h),
      ),
    ];

    return _buildGrid(context: context, buttons: buttons, columns: 4);
  }
}

// ─── Scientific grid (6 × 6) ─────────────────────────────────────────────────

class _ScientificGrid extends StatelessWidget {
  const _ScientificGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final shift = calc.shiftActive;

    final buttons = <_BtnDef>[
      // Row 1 — shift-able functions
      _BtnDef(
        label: '2nd',
        type: ButtonType.function,
        fontSize: 14,
        isActive: (_) => shift,
        onTap: (c, _) => c.toggleShift(),
      ),
      _BtnDef(
        label: shift ? 'asin' : 'sin',
        type: ButtonType.function,
        fontSize: 14,
        onTap: (c, _) => c.appendFunctionPrefix(shift ? 'asin' : 'sin'),
      ),
      _BtnDef(
        label: shift ? 'acos' : 'cos',
        type: ButtonType.function,
        fontSize: 14,
        onTap: (c, _) => c.appendFunctionPrefix(shift ? 'acos' : 'cos'),
      ),
      _BtnDef(
        label: shift ? 'atan' : 'tan',
        type: ButtonType.function,
        fontSize: 14,
        onTap: (c, _) => c.appendFunctionPrefix(shift ? 'atan' : 'tan'),
      ),
      _BtnDef(
        label: shift ? 'log₂' : 'Ln',
        type: ButtonType.function,
        fontSize: 14,
        onTap: (c, _) => c.appendFunctionPrefix(shift ? 'log2' : 'ln'),
      ),
      _BtnDef(
        label: shift ? '10ˣ' : 'log',
        type: ButtonType.function,
        fontSize: 14,
        onTap: (c, _) => c.appendFunctionPrefix(shift ? 'log2' : 'log'),
      ),

      // Row 2
      _BtnDef(
        label: shift ? 'x³' : 'x²',
        type: ButtonType.function,
        fontSize: 14,
        onTap: (c, _) => c.appendFunctionPrefix(shift ? 'x³' : 'x²'),
      ),
      _BtnDef(
        label: shift ? '∛' : '√',
        type: ButtonType.function,
        onTap: (c, _) => c.appendFunctionPrefix(shift ? '∛' : '√'),
      ),
      _BtnDef(
        label: 'xʸ',
        type: ButtonType.function,
        fontSize: 14,
        onTap: (c, _) => c.appendInput('^'),
      ),
      _BtnDef(
        label: '(',
        type: ButtonType.function,
        onTap: (c, _) => c.appendInput('('),
      ),
      _BtnDef(
        label: ')',
        type: ButtonType.function,
        onTap: (c, _) => c.appendInput(')'),
      ),
      _BtnDef(
        label: '÷',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('÷'),
      ),

      // Row 3 — memory row
      _BtnDef(
        label: 'MC',
        type: ButtonType.memory,
        fontSize: 14,
        onTap: (c, _) => c.memoryClear(),
      ),
      _BtnDef(
        label: '7',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('7'),
      ),
      _BtnDef(
        label: '8',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('8'),
      ),
      _BtnDef(
        label: '9',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('9'),
      ),
      _BtnDef(
        label: 'C',
        type: ButtonType.clear,
        onTap: (c, _) => c.clearEntry(),
      ),
      _BtnDef(
        label: '×',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('×'),
      ),

      // Row 4
      _BtnDef(
        label: 'MR',
        type: ButtonType.memory,
        fontSize: 14,
        onTap: (c, _) => c.memoryRecall(),
      ),
      _BtnDef(
        label: '4',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('4'),
      ),
      _BtnDef(
        label: '5',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('5'),
      ),
      _BtnDef(
        label: '6',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('6'),
      ),
      _BtnDef(
        label: 'CE',
        type: ButtonType.clear,
        fontSize: 14,
        onTap: (c, _) => c.clearLastChar(),
      ),
      _BtnDef(
        label: '-',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('-'),
      ),

      // Row 5
      _BtnDef(
        label: 'M+',
        type: ButtonType.memory,
        fontSize: 14,
        onTap: (c, _) => c.memoryAdd(),
      ),
      _BtnDef(
        label: '1',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('1'),
      ),
      _BtnDef(
        label: '2',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('2'),
      ),
      _BtnDef(
        label: '3',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('3'),
      ),
      _BtnDef(
        label: '%',
        type: ButtonType.function,
        onTap: (c, _) => c.appendFunctionPrefix('%'),
      ),
      _BtnDef(
        label: '+',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('+'),
      ),

      // Row 6
      _BtnDef(
        label: 'M-',
        type: ButtonType.memory,
        fontSize: 14,
        onTap: (c, _) => c.memorySubtract(),
      ),
      _BtnDef(
        label: '±',
        type: ButtonType.function,
        onTap: (c, _) => c.appendFunctionPrefix('±'),
      ),
      _BtnDef(
        label: '0',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('0'),
      ),
      _BtnDef(
        label: '.',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('.'),
      ),
      _BtnDef(
        label: 'π',
        type: ButtonType.function,
        onTap: (c, _) => c.insertConstant('π'),
      ),
      _BtnDef(
        label: '=',
        type: ButtonType.equals,
        onTap: (c, h) => _commitResult(c, h),
      ),
    ];

    return _buildGrid(context: context, buttons: buttons, columns: 6);
  }
}

// ─── Programmer grid ─────────────────────────────────────────────────────────

class _ProgrammerGrid extends StatelessWidget {
  const _ProgrammerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final buttons = <_BtnDef>[
      // Base selectors
      _BtnDef(
        label: 'HEX',
        type: ButtonType.function,
        fontSize: 13,
        isActive: (ctx) =>
            ctx.watch<CalculatorProvider>().programmerBase ==
            ProgrammerBase.hexadecimal,
        onTap: (c, _) => c.setProgrammerBase(ProgrammerBase.hexadecimal),
      ),
      _BtnDef(
        label: 'DEC',
        type: ButtonType.function,
        fontSize: 13,
        isActive: (ctx) =>
            ctx.watch<CalculatorProvider>().programmerBase ==
            ProgrammerBase.decimal,
        onTap: (c, _) => c.setProgrammerBase(ProgrammerBase.decimal),
      ),
      _BtnDef(
        label: 'OCT',
        type: ButtonType.function,
        fontSize: 13,
        isActive: (ctx) =>
            ctx.watch<CalculatorProvider>().programmerBase ==
            ProgrammerBase.octal,
        onTap: (c, _) => c.setProgrammerBase(ProgrammerBase.octal),
      ),
      _BtnDef(
        label: 'BIN',
        type: ButtonType.function,
        fontSize: 13,
        isActive: (ctx) =>
            ctx.watch<CalculatorProvider>().programmerBase ==
            ProgrammerBase.binary,
        onTap: (c, _) => c.setProgrammerBase(ProgrammerBase.binary),
      ),

      // Bitwise row
      _BtnDef(
        label: 'AND',
        type: ButtonType.function,
        fontSize: 13,
        onTap: (c, _) => c.appendInput(' AND '),
      ),
      _BtnDef(
        label: 'OR',
        type: ButtonType.function,
        fontSize: 13,
        onTap: (c, _) => c.appendInput(' OR '),
      ),
      _BtnDef(
        label: 'XOR',
        type: ButtonType.function,
        fontSize: 13,
        onTap: (c, _) => c.appendInput(' XOR '),
      ),
      _BtnDef(
        label: 'NOT',
        type: ButtonType.function,
        fontSize: 13,
        onTap: (c, _) => c.appendInput('NOT '),
      ),

      // Shift row
      _BtnDef(
        label: '<<',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('<<'),
      ),
      _BtnDef(
        label: '>>',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('>>'),
      ),
      _BtnDef(
        label: 'C',
        type: ButtonType.clear,
        onTap: (c, _) => c.clearEntry(),
      ),
      _BtnDef(
        label: 'CE',
        type: ButtonType.clear,
        fontSize: 14,
        onTap: (c, _) => c.clearLastChar(),
      ),

      // Hex letters + numbers
      _BtnDef(
        label: 'A',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('A'),
      ),
      _BtnDef(
        label: 'B',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('B'),
      ),
      _BtnDef(
        label: '7',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('7'),
      ),
      _BtnDef(
        label: '8',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('8'),
      ),
      _BtnDef(
        label: '9',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('9'),
      ),
      _BtnDef(
        label: '÷',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('÷'),
      ),

      _BtnDef(
        label: 'C',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('C'),
      ),
      _BtnDef(
        label: 'D',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('D'),
      ),
      _BtnDef(
        label: '4',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('4'),
      ),
      _BtnDef(
        label: '5',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('5'),
      ),
      _BtnDef(
        label: '6',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('6'),
      ),
      _BtnDef(
        label: '×',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('×'),
      ),

      _BtnDef(
        label: 'E',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('E'),
      ),
      _BtnDef(
        label: 'F',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('F'),
      ),
      _BtnDef(
        label: '1',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('1'),
      ),
      _BtnDef(
        label: '2',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('2'),
      ),
      _BtnDef(
        label: '3',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('3'),
      ),
      _BtnDef(
        label: '-',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('-'),
      ),

      _BtnDef(
        label: '0x',
        type: ButtonType.function,
        fontSize: 14,
        onTap: (c, _) => c.appendInput('0x'),
      ),
      _BtnDef(
        label: '0',
        type: ButtonType.number,
        onTap: (c, _) => c.appendInput('0'),
      ),
      _BtnDef(
        label: '(',
        type: ButtonType.function,
        onTap: (c, _) => c.appendInput('('),
      ),
      _BtnDef(
        label: ')',
        type: ButtonType.function,
        onTap: (c, _) => c.appendInput(')'),
      ),
      _BtnDef(
        label: '+',
        type: ButtonType.operator,
        onTap: (c, _) => c.appendInput('+'),
      ),
      _BtnDef(
        label: '=',
        type: ButtonType.equals,
        onTap: (c, h) => _commitResult(c, h),
      ),
    ];

    return _buildGrid(context: context, buttons: buttons, columns: 6);
  }
}
