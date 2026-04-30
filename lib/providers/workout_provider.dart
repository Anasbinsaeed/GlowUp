import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_model.dart';
import '../database/db_helper.dart';

class WorkoutProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<WorkoutPlan> _plans = [];
  List<WorkoutPlan> get plans => _plans;

  Future<void> load() async {
    await _db.ensureWorkoutTables();
    final planRows = await _db.getAll('workout_plans');
    _plans = [];
    for (final row in planRows) {
      final exerciseRows = await _db.getExercisesForPlan(row['id'] as String);
      final exercises = exerciseRows.map(WorkoutExercise.fromMap).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      _plans.add(WorkoutPlan.fromMap(row, exercises));
    }
    notifyListeners();
  }

  Future<void> addPlan(WorkoutPlan plan) async {
    await _db.insert('workout_plans', plan.toMap());
    for (final ex in plan.exercises) {
      await _db.insert('workout_exercises', ex.toMap());
    }
    _plans.add(plan);
    notifyListeners();
  }

  Future<void> updatePlan(WorkoutPlan plan) async {
    await _db.update('workout_plans', plan.toMap(), plan.id);
    // Delete old exercises and re-insert
    await _db.deleteExercisesForPlan(plan.id);
    for (final ex in plan.exercises) {
      await _db.insert('workout_exercises', ex.toMap());
    }
    final idx = _plans.indexWhere((p) => p.id == plan.id);
    if (idx != -1) _plans[idx] = plan;
    notifyListeners();
  }

  Future<void> deletePlan(String id) async {
    await _db.delete('workout_plans', id);
    await _db.deleteExercisesForPlan(id);
    _plans.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  WorkoutPlan createPlan({required String name, required String emoji}) {
    return WorkoutPlan(
      id: const Uuid().v4(),
      name: name,
      emoji: emoji,
      exercises: [],
      createdAt: DateTime.now(),
    );
  }

  WorkoutExercise createExercise({
    required String planId,
    required String name,
    required int sets,
    required int reps,
    double? weightKg,
    String? note,
    required int order,
  }) {
    return WorkoutExercise(
      id: const Uuid().v4(),
      planId: planId,
      name: name,
      sets: sets,
      reps: reps,
      weightKg: weightKg,
      note: note,
      order: order,
    );
  }

  Future<void> clearAllData() async {
    await _db.clearTable('workout_exercises');
    await _db.clearTable('workout_plans');
    _plans.clear();
    notifyListeners();
  }

  WorkoutPlan? getPlan(String id) {
    try {
      return _plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addExercise(String planId, WorkoutExercise exercise) async {
    final idx = _plans.indexWhere((p) => p.id == planId);
    if (idx == -1) return;
    _plans[idx].exercises.add(exercise);
    await _db.insert('workout_exercises', exercise.toMap());
    notifyListeners();
  }

  Future<void> deleteExercise(String planId, String exerciseId) async {
    final idx = _plans.indexWhere((p) => p.id == planId);
    if (idx == -1) return;
    _plans[idx].exercises.removeWhere((e) => e.id == exerciseId);
    await _db.delete('workout_exercises', exerciseId);
    notifyListeners();
  }

  Future<void> toggleExerciseComplete(String planId, String exerciseId) async {
    final planIdx = _plans.indexWhere((p) => p.id == planId);
    if (planIdx == -1) return;
    final exIdx =
        _plans[planIdx].exercises.indexWhere((e) => e.id == exerciseId);
    if (exIdx == -1) return;
    final ex = _plans[planIdx].exercises[exIdx];
    _plans[planIdx].exercises[exIdx] = WorkoutExercise(
      id: ex.id,
      planId: ex.planId,
      name: ex.name,
      sets: ex.sets,
      reps: ex.reps,
      weightKg: ex.weightKg,
      note: ex.note,
      order: ex.order,
      isCompleted: !ex.isCompleted,
    );
    await _db.update('workout_exercises',
        _plans[planIdx].exercises[exIdx].toMap(), exerciseId);
    notifyListeners();
  }

  Future<void> resetAllExercises(String planId) async {
    final idx = _plans.indexWhere((p) => p.id == planId);
    if (idx == -1) return;
    for (int i = 0; i < _plans[idx].exercises.length; i++) {
      final ex = _plans[idx].exercises[i];
      if (ex.isCompleted) {
        _plans[idx].exercises[i] = WorkoutExercise(
          id: ex.id,
          planId: ex.planId,
          name: ex.name,
          sets: ex.sets,
          reps: ex.reps,
          weightKg: ex.weightKg,
          note: ex.note,
          order: ex.order,
          isCompleted: false,
        );
        await _db.update(
            'workout_exercises', _plans[idx].exercises[i].toMap(), ex.id);
      }
    }
    notifyListeners();
  }
}
