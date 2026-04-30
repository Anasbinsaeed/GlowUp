import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit_model.dart';
import '../database/db_helper.dart';

class HabitProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<HabitModel> _habits = [];
  List<HabitModel> get habits => _habits;

  bool _showConfetti = false;
  bool get showConfetti => _showConfetti;

  Future<void> load() async {
    final rows = await _db.getAll('habits');
    _habits = rows.map(HabitModel.fromMap).toList();
    notifyListeners();
  }

  Future<void> add(HabitModel h) async {
    await _db.insert('habits', h.toMap());
    _habits.add(h);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await _db.delete('habits', id);
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  Future<void> toggleToday(String id) async {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx == -1) return;
    final habit = _habits[idx];
    final today = _dateKey(DateTime.now());

    if (habit.completedDates.contains(today)) {
      habit.completedDates.remove(today);
      habit.streak = _calcStreak(habit.completedDates);
    } else {
      habit.completedDates.add(today);
      habit.streak = _calcStreak(habit.completedDates);
      if (habit.streak > habit.longestStreak) {
        habit.longestStreak = habit.streak;
        _showConfetti = true;
        Future.delayed(const Duration(seconds: 3), () {
          _showConfetti = false;
          notifyListeners();
        });
      }
    }
    await _db.update('habits', habit.toMap(), id);
    notifyListeners();
  }

  int _calcStreak(List<String> dates) {
    if (dates.isEmpty) return 0;
    final sorted = dates.toList()..sort();
    int streak = 0;
    DateTime check = DateTime.now();
    for (int i = sorted.length - 1; i >= 0; i--) {
      final d = DateTime.parse(sorted[i]);
      final diff = check.difference(d).inDays;
      if (diff == 0 || diff == 1) {
        streak++;
        check = d;
      } else {
        break;
      }
    }
    return streak;
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  HabitModel createNew({
    required String title,
    required String emoji,
    required String color,
  }) {
    return HabitModel(
      id: const Uuid().v4(),
      title: title,
      emoji: emoji,
      color: color,
    );
  }

  Future<void> clearAllData() async {
    await _db.clearTable('habits');
    _habits.clear();
    _showConfetti = false;
    notifyListeners();
  }
}
