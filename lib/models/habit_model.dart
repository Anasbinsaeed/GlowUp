class HabitModel {
  final String id;
  String title;
  String emoji;
  String color; // hex
  int streak;
  int longestStreak;
  List<String> completedDates; // 'yyyy-MM-dd'
  DateTime createdAt;

  HabitModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    this.streak = 0,
    this.longestStreak = 0,
    List<String>? completedDates,
    DateTime? createdAt,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool isCompletedToday() {
    final today = _dateKey(DateTime.now());
    return completedDates.contains(today);
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'color': color,
        'streak': streak,
        'longestStreak': longestStreak,
        'completedDates': completedDates.join(','),
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory HabitModel.fromMap(Map<String, dynamic> m) => HabitModel(
        id: m['id'],
        title: m['title'],
        emoji: m['emoji'],
        color: m['color'],
        streak: m['streak'],
        longestStreak: m['longestStreak'],
        completedDates: (m['completedDates'] as String)
            .split(',')
            .where((e) => e.isNotEmpty)
            .toList(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt']),
      );
}
