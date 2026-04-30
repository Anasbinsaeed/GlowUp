class FitnessLog {
  final String id;
  String type; // walk, swim, exercise
  double value; // km for walk, minutes for swim/exercise
  String unit;
  String emoji;
  DateTime date;
  String? note;

  FitnessLog({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.emoji,
    required this.date,
    this.note,
  });

  static String emojiForType(String t) {
    switch (t) {
      case 'walk':
        return '🚶‍♀️';
      case 'swim':
        return '🏊‍♀️';
      case 'exercise':
        return '💪';
      case 'yoga':
        return '🧘‍♀️';
      case 'dance':
        return '💃';
      default:
        return '🏃‍♀️';
    }
  }

  static String unitForType(String t) {
    switch (t) {
      case 'walk':
        return 'km';
      default:
        return 'min';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'value': value,
        'unit': unit,
        'emoji': emoji,
        'date': date.millisecondsSinceEpoch,
        'note': note,
      };

  factory FitnessLog.fromMap(Map<String, dynamic> m) => FitnessLog(
        id: m['id'],
        type: m['type'],
        value: m['value'],
        unit: m['unit'],
        emoji: m['emoji'],
        date: DateTime.fromMillisecondsSinceEpoch(m['date']),
        note: m['note'],
      );
}

class NutritionDay {
  final String id;
  String date; // yyyy-MM-dd
  String type; // protein, diet, cheat, normal
  String emoji;
  String? note;

  NutritionDay({
    required this.id,
    required this.date,
    required this.type,
    required this.emoji,
    this.note,
  });

  static String emojiForType(String t) {
    switch (t) {
      case 'protein':
        return '🍗';
      case 'diet':
        return '🥗';
      case 'cheat':
        return '🍕';
      case 'normal':
        return '🍽️';
      case 'vegan':
        return '🌱';
      case 'keto':
        return '🥑';
      case 'fasting':
        return '⏳';
      case 'bulking':
        return '💪';
      case 'cutting':
        return '✂️';
      case 'balanced':
        return '⚖️';
      case 'smoothie':
        return '🥤';
      case 'detox':
        return '🍋';
      case 'comfort':
        return '🍜';
      case 'snacky':
        return '🍿';
      default:
        return '🍽️';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'type': type,
        'emoji': emoji,
        'note': note,
      };

  factory NutritionDay.fromMap(Map<String, dynamic> m) => NutritionDay(
        id: m['id'],
        date: m['date'],
        type: m['type'],
        emoji: m['emoji'],
        note: m['note'],
      );
}
