class WorkoutPlan {
  final String id;
  String name;
  String emoji;
  List<WorkoutExercise> exercises;
  DateTime createdAt;

  WorkoutPlan({
    required this.id,
    required this.name,
    required this.emoji,
    required this.exercises,
    required this.createdAt,
  });

  int get totalCount => exercises.length;
  int get completedCount => exercises.where((e) => e.isCompleted).length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory WorkoutPlan.fromMap(
          Map<String, dynamic> m, List<WorkoutExercise> exercises) =>
      WorkoutPlan(
        id: m['id'],
        name: m['name'],
        emoji: m['emoji'],
        exercises: exercises,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt']),
      );
}

class WorkoutExercise {
  final String id;
  final String planId;
  String name;
  int sets;
  int reps;
  double? weightKg;
  String? note;
  int order;
  bool isCompleted;
  // Convenience aliases used by detail screen
  double get weight => weightKg ?? 0.0;
  String get weightUnit => 'kg';

  WorkoutExercise({
    required this.id,
    required this.planId,
    required this.name,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.note,
    required this.order,
    this.isCompleted = false,
  });

  String get setsRepsLabel {
    final weight =
        weightKg != null ? ' × ${weightKg!.toStringAsFixed(1)}kg' : '';
    return '$sets×$reps$weight';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'planId': planId,
        'name': name,
        'sets': sets,
        'reps': reps,
        'weightKg': weightKg,
        'note': note,
        'sortOrder': order,
        'isCompleted': isCompleted ? 1 : 0,
      };

  factory WorkoutExercise.fromMap(Map<String, dynamic> m) => WorkoutExercise(
        id: m['id'],
        planId: m['planId'],
        name: m['name'],
        sets: m['sets'] as int,
        reps: m['reps'] as int,
        weightKg: m['weightKg'] as double?,
        note: m['note'],
        order: (m['sortOrder'] ?? m['order'] ?? 0) as int,
        isCompleted: (m['isCompleted'] ?? 0) == 1,
      );
}
