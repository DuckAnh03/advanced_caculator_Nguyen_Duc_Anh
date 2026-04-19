enum CalculatorMode { basic, scientific, programmer }

extension CalculatorModeExtension on CalculatorMode {
  String get label {
    switch (this) {
      case CalculatorMode.basic:
        return 'Basic';
      case CalculatorMode.scientific:
        return 'Scientific';
      case CalculatorMode.programmer:
        return 'Programmer';
    }
  }

  String get key {
    return toString().split('.').last;
  }

  static CalculatorMode fromKey(String key) {
    return CalculatorMode.values.firstWhere(
      (e) => e.key == key,
      orElse: () => CalculatorMode.basic,
    );
  }
}

enum AngleMode { degrees, radians }

extension AngleModeExtension on AngleMode {
  String get label => this == AngleMode.degrees ? 'DEG' : 'RAD';
  String get key => toString().split('.').last;

  static AngleMode fromKey(String key) {
    return AngleMode.values.firstWhere(
      (e) => e.key == key,
      orElse: () => AngleMode.degrees,
    );
  }
}

enum ProgrammerBase { binary, octal, decimal, hexadecimal }

extension ProgrammerBaseExtension on ProgrammerBase {
  String get label {
    switch (this) {
      case ProgrammerBase.binary:
        return 'BIN';
      case ProgrammerBase.octal:
        return 'OCT';
      case ProgrammerBase.decimal:
        return 'DEC';
      case ProgrammerBase.hexadecimal:
        return 'HEX';
    }
  }

  int get radix {
    switch (this) {
      case ProgrammerBase.binary:
        return 2;
      case ProgrammerBase.octal:
        return 8;
      case ProgrammerBase.decimal:
        return 10;
      case ProgrammerBase.hexadecimal:
        return 16;
    }
  }
}
