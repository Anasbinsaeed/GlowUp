class LearningGoal {
  final String id;
  String title;
  String subject;
  String emoji;
  List<LearningTask> tasks;
  DateTime createdAt;
  DateTime? targetDate;

  LearningGoal({
    required this.id,
    required this.title,
    required this.subject,
    required this.emoji,
    required this.tasks,
    required this.createdAt,
    this.targetDate,
  });

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  double get progress => tasks.isEmpty ? 0 : completedCount / tasks.length;
  int get totalCount => tasks.length;
  bool get isCompleted => tasks.isNotEmpty && completedCount == tasks.length;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subject': subject,
        'emoji': emoji,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'targetDate': targetDate?.millisecondsSinceEpoch,
      };

  factory LearningGoal.fromMap(
          Map<String, dynamic> m, List<LearningTask> tasks) =>
      LearningGoal(
        id: m['id'],
        title: m['title'],
        subject: m['subject'],
        emoji: m['emoji'],
        tasks: tasks,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
        targetDate: m['targetDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(m['targetDate'] as int)
            : null,
      );
}

class LearningTask {
  final String id;
  final String goalId;
  String title;
  bool isCompleted;
  int order;

  LearningTask({
    required this.id,
    required this.goalId,
    required this.title,
    required this.isCompleted,
    required this.order,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'goalId': goalId,
        'title': title,
        'isCompleted': isCompleted ? 1 : 0,
        'sortOrder': order,
      };

  factory LearningTask.fromMap(Map<String, dynamic> m) => LearningTask(
        id: m['id'],
        goalId: m['goalId'],
        title: m['title'],
        isCompleted: m['isCompleted'] == 1,
        order: m['sortOrder'] as int,
      );
}
