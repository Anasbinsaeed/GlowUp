import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/fitness_model.dart';
import '../database/db_helper.dart';
import '../services/widget_service.dart';

class FitnessProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<FitnessLog> _logs = [];
  List<NutritionDay> _nutritionDays = [];

  List<FitnessLog> get logs => _logs;
  List<NutritionDay> get nutritionDays => _nutritionDays;

  List<FitnessLog> get todayLogs {
    final today = _dateKey(DateTime.now());
    return _logs.where((l) => _dateKey(l.date) == today).toList();
  }

  double get todayWalkKm {
    return todayLogs
        .where((l) => l.type == 'walk')
        .fold(0.0, (sum, l) => sum + l.value);
  }

  double get weeklyWalkKm {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _logs
        .where((l) => l.type == 'walk' && l.date.isAfter(weekAgo))
        .fold(0.0, (sum, l) => sum + l.value);
  }

  Future<void> load() async {
    final logRows = await _db.getAll('fitness_logs');
    _logs = logRows.map(FitnessLog.fromMap).toList();
    final nutRows = await _db.getAll('nutrition_days');
    _nutritionDays = nutRows.map(NutritionDay.fromMap).toList();
    notifyListeners();
  }

  Future<void> addLog(FitnessLog log) async {
    await _db.insert('fitness_logs', log.toMap());
    _logs.add(log);
    notifyListeners();
    WidgetService.updateFitnessWidget(todayWalkKm, todayLogs.length);
  }

  Future<void> removeLog(String id) async {
    await _db.delete('fitness_logs', id);
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
    WidgetService.updateFitnessWidget(todayWalkKm, todayLogs.length);
  }

  Future<void> setNutritionDay(String date, String type) async {
    final existing = _nutritionDays.indexWhere((n) => n.date == date);
    final nd = NutritionDay(
      id: existing >= 0 ? _nutritionDays[existing].id : const Uuid().v4(),
      date: date,
      type: type,
      emoji: NutritionDay.emojiForType(type),
    );
    if (existing >= 0) {
      _nutritionDays[existing] = nd;
      await _db.update('nutrition_days', nd.toMap(), nd.id);
    } else {
      _nutritionDays.add(nd);
      await _db.insert('nutrition_days', nd.toMap());
    }
    notifyListeners();
  }

  NutritionDay? getNutritionForDate(String date) {
    try {
      return _nutritionDays.firstWhere((n) => n.date == date);
    } catch (_) {
      return null;
    }
  }

  FitnessLog createLog({
    required String type,
    required double value,
  }) {
    return FitnessLog(
      id: const Uuid().v4(),
      type: type,
      value: value,
      unit: FitnessLog.unitForType(type),
      emoji: FitnessLog.emojiForType(type),
      date: DateTime.now(),
    );
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> clearAllData() async {
    await _db.clearTable('fitness_logs');
    await _db.clearTable('nutrition_days');
    _logs.clear();
    _nutritionDays.clear();
    notifyListeners();
  }
}
