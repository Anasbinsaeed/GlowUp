class ReminderModel {
  final String id;
  String title;
  String category; // medicine, cooking, plant, custom
  String emoji;
  DateTime time;
  List<int> repeatDays; // 0=Mon ... 6=Sun
  bool isActive;
  String? note;

  ReminderModel({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.time,
    required this.repeatDays,
    this.isActive = true,
    this.note,
  });

  static String emojiForCategory(String cat) {
    switch (cat) {
      case 'medicine':
        return '💊';
      case 'workout':
        return '💪';
      case 'water':
        return '💧';
      case 'cooking':
        return '🍳';
      case 'plant':
        return '🌱';
      case 'study':
        return '📚';
      case 'meeting':
        return '👥';
      case 'call':
        return '📞';
      case 'shopping':
        return '🛍️';
      case 'pet':
        return '🐾';
      case 'skincare':
        return '✨';
      case 'sleep':
        return '😴';
      case 'flight':
        return '✈️';
      default:
        return '🌸';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'emoji': emoji,
        'time': time.millisecondsSinceEpoch,
        'repeatDays': repeatDays.join(','),
        'isActive': isActive ? 1 : 0,
        'note': note,
      };

  factory ReminderModel.fromMap(Map<String, dynamic> m) => ReminderModel(
        id: m['id'],
        title: m['title'],
        category: m['category'],
        emoji: m['emoji'],
        time: DateTime.fromMillisecondsSinceEpoch(m['time']),
        repeatDays: (m['repeatDays'] as String)
            .split(',')
            .where((e) => e.isNotEmpty)
            .map(int.parse)
            .toList(),
        isActive: m['isActive'] == 1,
        note: m['note'],
      );
}
