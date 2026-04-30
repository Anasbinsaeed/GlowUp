class SubscriptionModel {
  final String id;
  String name;
  String emoji;
  String category;
  double amount;
  String currency;
  String billingCycle; // monthly, yearly, weekly
  DateTime nextBillingDate;
  bool reminderEnabled;
  int reminderDaysBefore;
  String? note;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.amount,
    required this.currency,
    required this.billingCycle,
    required this.nextBillingDate,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 3,
    this.note,
  });

  double get monthlyEquivalent {
    switch (billingCycle) {
      case 'weekly':
        return amount * 4.33;
      case 'yearly':
        return amount / 12;
      default:
        return amount;
    }
  }

  String get billingLabel {
    switch (billingCycle) {
      case 'weekly':
        return 'Weekly';
      case 'yearly':
        return 'Yearly';
      default:
        return 'Monthly';
    }
  }

  bool get isDueSoon {
    final daysUntil = nextBillingDate.difference(DateTime.now()).inDays;
    return daysUntil <= reminderDaysBefore && daysUntil >= 0;
  }

  bool get isOverdue => nextBillingDate.isBefore(DateTime.now());

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'category': category,
        'amount': amount,
        'currency': currency,
        'billingCycle': billingCycle,
        'nextBillingDate': nextBillingDate.millisecondsSinceEpoch,
        'reminderEnabled': reminderEnabled ? 1 : 0,
        'reminderDaysBefore': reminderDaysBefore,
        'note': note,
      };

  factory SubscriptionModel.fromMap(Map<String, dynamic> m) =>
      SubscriptionModel(
        id: m['id'],
        name: m['name'],
        emoji: m['emoji'],
        category: m['category'],
        amount: (m['amount'] as num).toDouble(),
        currency: m['currency'],
        billingCycle: m['billingCycle'],
        nextBillingDate:
            DateTime.fromMillisecondsSinceEpoch(m['nextBillingDate'] as int),
        reminderEnabled: m['reminderEnabled'] == 1,
        reminderDaysBefore: m['reminderDaysBefore'] as int,
        note: m['note'],
      );
}
