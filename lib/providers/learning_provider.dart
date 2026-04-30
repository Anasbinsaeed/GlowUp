import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/learning_model.dart';
import '../database/db_helper.dart';
import '../services/widget_service.dart';

class LearningProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<LearningGoal> _goals = [];
  List<LearningGoal> get goals => _goals;

  Future<void> load() async {
    await _db.ensureLearningTables();
    final goalRows = await _db.getAll('learning_goals');
    _goals = [];
    for (final row in goalRows) {
      final taskRows = await _db.getTasksForGoal(row['id'] as String);
      final tasks = taskRows.map(LearningTask.fromMap).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      _goals.add(LearningGoal.fromMap(row, tasks));
    }
    notifyListeners();
  }

  Future<void> addGoal(LearningGoal goal) async {
    await _db.insert('learning_goals', goal.toMap());
    for (final task in goal.tasks) {
      await _db.insert('learning_tasks', task.toMap());
    }
    _goals.add(goal);
    notifyListeners();
    WidgetService.updateLearningWidget(_goals);
  }

  Future<void> updateGoal(LearningGoal goal) async {
    await _db.update('learning_goals', goal.toMap(), goal.id);
    await _db.deleteTasksForGoal(goal.id);
    for (final task in goal.tasks) {
      await _db.insert('learning_tasks', task.toMap());
    }
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) _goals[idx] = goal;
    notifyListeners();
  }

  Future<void> toggleTask(String goalId, String taskId) async {
    final goalIdx = _goals.indexWhere((g) => g.id == goalId);
    if (goalIdx == -1) return;
    final taskIdx = _goals[goalIdx].tasks.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) return;
    _goals[goalIdx].tasks[taskIdx].isCompleted =
        !_goals[goalIdx].tasks[taskIdx].isCompleted;
    await _db.update(
        'learning_tasks', _goals[goalIdx].tasks[taskIdx].toMap(), taskId);
    notifyListeners();
    WidgetService.updateLearningWidget(_goals);
  }

  Future<void> deleteGoal(String id) async {
    await _db.delete('learning_goals', id);
    await _db.deleteTasksForGoal(id);
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
    WidgetService.updateLearningWidget(_goals);
  }

  LearningGoal createGoal({
    required String title,
    required String subject,
    required String emoji,
    DateTime? targetDate,
  }) {
    return LearningGoal(
      id: const Uuid().v4(),
      title: title,
      subject: subject,
      emoji: emoji,
      tasks: [],
      createdAt: DateTime.now(),
      targetDate: targetDate,
    );
  }

  LearningTask createTask({
    required String goalId,
    required String title,
    required int order,
  }) {
    return LearningTask(
      id: const Uuid().v4(),
      goalId: goalId,
      title: title,
      isCompleted: false,
      order: order,
    );
  }

  Future<void> clearAllData() async {
    await _db.clearTable('learning_tasks');
    await _db.clearTable('learning_goals');
    _goals.clear();
    notifyListeners();
  }

  LearningGoal? getGoal(String id) {
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addTask(String goalId, String title) async {
    final goalIdx = _goals.indexWhere((g) => g.id == goalId);
    if (goalIdx == -1) return;
    final task = createTask(
      goalId: goalId,
      title: title,
      order: _goals[goalIdx].tasks.length,
    );
    _goals[goalIdx].tasks.add(task);
    await _db.insert('learning_tasks', task.toMap());
    notifyListeners();
  }

  Future<void> deleteTask(String goalId, String taskId) async {
    final goalIdx = _goals.indexWhere((g) => g.id == goalId);
    if (goalIdx == -1) return;
    _goals[goalIdx].tasks.removeWhere((t) => t.id == taskId);
    await _db.delete('learning_tasks', taskId);
    notifyListeners();
  }
}
