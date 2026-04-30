import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription_model.dart';
import '../database/db_helper.dart';
import '../services/widget_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<SubscriptionModel> _subs = [];
  List<SubscriptionModel> get subscriptions => _subs;

  List<SubscriptionModel> get dueSoon =>
      _subs.where((s) => s.isDueSoon && !s.isOverdue).toList();

  double get totalMonthly =>
      _subs.fold(0, (sum, s) => sum + s.monthlyEquivalent);

  Future<void> load() async {
    await _db.ensureSubscriptionTable();
    final rows = await _db.getAll('subscriptions');
    _subs = rows.map(SubscriptionModel.fromMap).toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    notifyListeners();
  }

  Future<void> add(SubscriptionModel sub) async {
    await _db.insert('subscriptions', sub.toMap());
    _subs.add(sub);
    _subs.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    notifyListeners();
    final currency = _subs.isNotEmpty ? _subs.first.currency : '€';
    WidgetService.updateSubscriptionsWidget(_subs, currency);
  }

  Future<void> remove(String id) async {
    await _db.delete('subscriptions', id);
    _subs.removeWhere((s) => s.id == id);
    notifyListeners();
    final currency = _subs.isNotEmpty ? _subs.first.currency : '€';
    WidgetService.updateSubscriptionsWidget(_subs, currency);
  }

  Future<void> renewSubscription(String id) async {
    final idx = _subs.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    final sub = _subs[idx];
    DateTime next;
    switch (sub.billingCycle) {
      case 'weekly':
        next = sub.nextBillingDate.add(const Duration(days: 7));
        break;
      case 'yearly':
        next = DateTime(sub.nextBillingDate.year + 1, sub.nextBillingDate.month,
            sub.nextBillingDate.day);
        break;
      default:
        next = DateTime(sub.nextBillingDate.year, sub.nextBillingDate.month + 1,
            sub.nextBillingDate.day);
    }
    _subs[idx] = SubscriptionModel(
      id: sub.id,
      name: sub.name,
      emoji: sub.emoji,
      category: sub.category,
      amount: sub.amount,
      currency: sub.currency,
      billingCycle: sub.billingCycle,
      nextBillingDate: next,
      reminderEnabled: sub.reminderEnabled,
      reminderDaysBefore: sub.reminderDaysBefore,
      note: sub.note,
    );
    await _db.update('subscriptions', _subs[idx].toMap(), id);
    _subs.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    notifyListeners();
    final currency = _subs.isNotEmpty ? _subs.first.currency : '€';
    WidgetService.updateSubscriptionsWidget(_subs, currency);
  }

  SubscriptionModel createNew({
    required String name,
    required String emoji,
    required String category,
    required double amount,
    required String currency,
    required String billingCycle,
    required DateTime nextBillingDate,
    bool reminderEnabled = true,
    int reminderDaysBefore = 3,
    String? note,
  }) {
    return SubscriptionModel(
      id: const Uuid().v4(),
      name: name,
      emoji: emoji,
      category: category,
      amount: amount,
      currency: currency,
      billingCycle: billingCycle,
      nextBillingDate: nextBillingDate,
      reminderEnabled: reminderEnabled,
      reminderDaysBefore: reminderDaysBefore,
      note: note,
    );
  }

  Future<void> clearAllData() async {
    await _db.clearTable('subscriptions');
    _subs.clear();
    notifyListeners();
  }
}
