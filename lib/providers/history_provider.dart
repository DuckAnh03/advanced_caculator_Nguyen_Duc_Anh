import 'package:flutter/material.dart';
import '../models/calculation_history.dart';
import '../models/calculator_mode.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<CalculationHistory> _history = [];
  int _maxSize;

  HistoryProvider({int maxSize = 50}) : _maxSize = maxSize {
    _history = StorageService.loadHistory();
  }

  // ─── Getters ────────────────────────────────────────────────────────────

  List<CalculationHistory> get history => List.unmodifiable(_history);

  /// Last 3 entries for the swipeable preview panel.
  List<CalculationHistory> get recentPreview => _history.take(3).toList();

  bool get isEmpty => _history.isEmpty;
  int get count => _history.length;

  // ─── Actions ────────────────────────────────────────────────────────────

  Future<void> addEntry({
    required String expression,
    required String result,
    required CalculatorMode mode,
  }) async {
    final entry = CalculationHistory.create(
      expression: expression,
      result: result,
      mode: mode,
    );

    _history.insert(0, entry); // newest first

    // Trim to max size
    if (_history.length > _maxSize) {
      _history = _history.sublist(0, _maxSize);
    }

    await StorageService.saveHistory(_history);
    notifyListeners();
  }

  Future<void> removeEntry(String id) async {
    _history.removeWhere((e) => e.id == id);
    await StorageService.saveHistory(_history);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _history = [];
    await StorageService.clearHistory();
    notifyListeners();
  }

  void updateMaxSize(int newSize) {
    _maxSize = newSize;
    if (_history.length > _maxSize) {
      _history = _history.sublist(0, _maxSize);
      StorageService.saveHistory(_history);
      notifyListeners();
    }
  }
}
