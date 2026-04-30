import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';
import '../models/habit_model.dart';
import '../models/flight_model.dart';
import '../models/grocery_item_model.dart';
import '../models/subscription_model.dart';
import '../models/learning_model.dart';

/// Single service that keeps the GlowupDashboardWidget in sync.
/// Call [updateDashboardWidget] whenever any data changes.
/// Individual helpers are provided so each provider can pass its own data
/// without needing to know about the others.
class WidgetService {
  static const _appGroupId = 'com.example.cuteapp';
  static const _dashboardWidgetName = 'GlowupDashboardWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  // ─── helpers called by individual providers ───────────────────────────────

  static Future<void> updateRemindersWidget(
      List<ReminderModel> reminders) async {
    final now = DateTime.now();
    final next24h = now.add(const Duration(hours: 24));

    final upcoming = reminders
        .where((r) {
          if (!r.isActive) return false;
          if (r.repeatDays.isEmpty) {
            return r.time.isAfter(now) && r.time.isBefore(next24h);
          }
          for (final day in r.repeatDays) {
            final next = _nextOccurrenceForDay(r.time, day);
            if (next.isAfter(now) && next.isBefore(next24h)) return true;
          }
          return false;
        })
        .take(2)
        .toList();

    await HomeWidget.saveWidgetData('reminder_count', upcoming.length);
    for (int i = 0; i < 2; i++) {
      if (i < upcoming.length) {
        final r = upcoming[i];
        final time = r.repeatDays.isEmpty
            ? DateFormat('h:mm a').format(r.time)
            : DateFormat('h:mm a')
                .format(_nextOccurrenceForDay(r.time, r.repeatDays.first));
        await HomeWidget.saveWidgetData(
            'reminder_${i + 1}', '${r.emoji} ${r.title} • $time');
      } else {
        await HomeWidget.saveWidgetData('reminder_${i + 1}', null);
      }
    }
    await _triggerUpdate();
  }

  static Future<void> updateHabitsWidget(List<HabitModel> habits) async {
    final done = habits.where((h) => h.isCompletedToday()).length;
    final total = habits.length;
    await HomeWidget.saveWidgetData('habits_done', done);
    await HomeWidget.saveWidgetData('habits_total', total);
    await _triggerUpdate();
  }

  static Future<void> updateFlightWidget(List<FlightModel> flights) async {
    final upcoming = flights.where((f) => f.isUpcoming).toList()
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

    if (upcoming.isEmpty) {
      await HomeWidget.saveWidgetData('flight_has_data', false);
      await HomeWidget.saveWidgetData('flight_route', null);
      await HomeWidget.saveWidgetData('flight_countdown', null);
    } else {
      final next = upcoming.first;
      final diff = next.timeUntilFlight;
      final countdown = diff.inDays >= 1
          ? '${diff.inDays}d'
          : '${diff.inHours}h ${diff.inMinutes % 60}m';
      await HomeWidget.saveWidgetData('flight_has_data', true);
      await HomeWidget.saveWidgetData(
          'flight_route', '${next.from} → ${next.to}');
      await HomeWidget.saveWidgetData('flight_countdown', countdown);
    }
    await _triggerUpdate();
  }

  static Future<void> updateGroceryWidget(
      List<GroceryItem> groceryItems) async {
    final unchecked = groceryItems.where((i) => !i.isChecked).toList();
    await HomeWidget.saveWidgetData('grocery_count', unchecked.length);
    final item1 = unchecked.isNotEmpty
        ? '${unchecked[0].emoji} ${unchecked[0].name}'
        : null;
    await HomeWidget.saveWidgetData('grocery_1', item1);
    await _triggerUpdate();
  }

  static Future<void> updateSubscriptionsWidget(
      List<SubscriptionModel> subs, String currency) async {
    final total = subs.fold<double>(0, (sum, s) => sum + s.monthlyEquivalent);
    await HomeWidget.saveWidgetData(
        'sub_monthly_total', total.toStringAsFixed(2));
    await HomeWidget.saveWidgetData('sub_currency', currency);

    final now = DateTime.now();
    SubscriptionModel? nextDue;
    int nextDays = -1;
    for (final sub in subs) {
      final days = sub.nextBillingDate.difference(now).inDays;
      if (days >= 0 && (nextDue == null || days < nextDays)) {
        nextDue = sub;
        nextDays = days;
      }
    }
    if (nextDue != null) {
      await HomeWidget.saveWidgetData(
          'sub_next_name', '${nextDue.emoji} ${nextDue.name}');
      await HomeWidget.saveWidgetData('sub_next_days', nextDays);
    } else {
      await HomeWidget.saveWidgetData('sub_next_name', null);
      await HomeWidget.saveWidgetData('sub_next_days', -1);
    }
    await _triggerUpdate();
  }

  static Future<void> updateFitnessWidget(double walkKm, int activities) async {
    await HomeWidget.saveWidgetData(
        'fitness_walk_km', walkKm.toStringAsFixed(1));
    await HomeWidget.saveWidgetData('fitness_activities', activities);
    await _triggerUpdate();
  }

  static Future<void> updateLearningWidget(List<LearningGoal> goals) async {
    final active = goals.where((g) => !g.isCompleted).toList();
    final goal = active.isNotEmpty
        ? active.first
        : (goals.isNotEmpty ? goals.first : null);
    if (goal != null) {
      final pct = (goal.progress * 100).round();
      await HomeWidget.saveWidgetData(
          'learning_goal_title', '${goal.emoji} ${goal.title}');
      await HomeWidget.saveWidgetData('learning_progress', pct);
    } else {
      await HomeWidget.saveWidgetData('learning_goal_title', null);
      await HomeWidget.saveWidgetData('learning_progress', 0);
    }
    await _triggerUpdate();
  }

  // ─── private ──────────────────────────────────────────────────────────────

  static Future<void> _triggerUpdate() async {
    try {
      await HomeWidget.updateWidget(androidName: _dashboardWidgetName);
    } catch (_) {
      // Never crash the app over a widget update failure.
    }
  }

  static DateTime _nextOccurrenceForDay(DateTime time, int targetDayOfWeek) {
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday - 1;
    int daysUntilTarget = targetDayOfWeek - currentDayOfWeek;
    if (daysUntilTarget < 0) daysUntilTarget += 7;
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day + daysUntilTarget,
      time.hour,
      time.minute,
    );
    if (daysUntilTarget == 0 && scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 7));
    }
    return scheduledTime;
  }
}
