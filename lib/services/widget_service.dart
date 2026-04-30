import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';
import '../models/habit_model.dart';
import '../models/flight_model.dart';
import '../models/grocery_item_model.dart';
import '../models/subscription_model.dart';
import '../models/learning_model.dart';
import '../widgets/home_widget_content.dart';

class WidgetService {
  static const _appGroupId = 'com.example.cuteapp';
  static const _remindersWidgetName = 'GlowupRemindersWidget';
  static const _habitsWidgetName = 'GlowupHabitsWidget';
  static const _flightWidgetName = 'GlowupFlightWidget';
  static const _waterWidgetName = 'GlowupWaterWidget';
  static const _groceryWidgetName = 'GlowupGroceryWidget';
  static const _subscriptionsWidgetName = 'GlowupSubscriptionsWidget';
  static const _learningWidgetName = 'GlowupLearningWidget';
  static const _fitnessWidgetName = 'GlowupFitnessWidget';
  static const _homeWidgetName = 'GlowupHomeWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Push upcoming reminders to the home screen widget
  static Future<void> updateRemindersWidget(
      List<ReminderModel> reminders) async {
    final now = DateTime.now();
    final next24h = now.add(const Duration(hours: 24));

    // Get upcoming reminders in next 24h
    final upcoming = reminders
        .where((r) {
          if (!r.isActive) return false;
          if (r.repeatDays.isEmpty) {
            return r.time.isAfter(now) && r.time.isBefore(next24h);
          }
          // For repeating, check if any day fires within 24h
          for (final day in r.repeatDays) {
            final next = _nextOccurrenceForDay(r.time, day);
            if (next.isAfter(now) && next.isBefore(next24h)) return true;
          }
          return false;
        })
        .take(3)
        .toList();

    await HomeWidget.saveWidgetData('reminder_count', upcoming.length);

    for (int i = 0; i < 3; i++) {
      if (i < upcoming.length) {
        final r = upcoming[i];
        final time = r.repeatDays.isEmpty
            ? DateFormat('h:mm a').format(r.time)
            : DateFormat('h:mm a').format(_nextOccurrenceForDay(
                r.time,
                r.repeatDays.first,
              ));
        await HomeWidget.saveWidgetData(
          'reminder_${i + 1}',
          '${r.emoji} ${r.title} • $time',
        );
      } else {
        await HomeWidget.saveWidgetData('reminder_${i + 1}', null);
      }
    }

    await HomeWidget.updateWidget(
      androidName: _remindersWidgetName,
    );
  }

  /// Push habit progress to the home screen widget
  static Future<void> updateHabitsWidget(List<HabitModel> habits) async {
    final done = habits.where((h) => h.isCompletedToday()).length;
    final total = habits.length;

    await HomeWidget.saveWidgetData('habits_done', done);
    await HomeWidget.saveWidgetData('habits_total', total);

    for (int i = 0; i < 2; i++) {
      if (i < habits.length) {
        final h = habits[i];
        final isDone = h.isCompletedToday();
        await HomeWidget.saveWidgetData(
          'habit_${i + 1}',
          '${isDone ? "✅" : h.emoji} ${h.title}',
        );
      } else {
        await HomeWidget.saveWidgetData('habit_${i + 1}', null);
      }
    }

    await HomeWidget.updateWidget(
      androidName: _habitsWidgetName,
    );
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

  /// Push next upcoming flight data to the home screen widget
  static Future<void> updateFlightWidget(List<FlightModel> flights) async {
    final upcoming = flights.where((f) => f.isUpcoming).toList()
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

    if (upcoming.isEmpty) {
      await HomeWidget.saveWidgetData('flight_has_data', false);
      await HomeWidget.saveWidgetData('flight_route', null);
      await HomeWidget.saveWidgetData('flight_number', null);
      await HomeWidget.saveWidgetData('flight_countdown', null);
    } else {
      final next = upcoming.first;
      final diff = next.timeUntilFlight;
      String countdown;
      if (diff.inDays >= 1) {
        countdown = '${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
      } else {
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        countdown = '${hours}h ${minutes}m';
      }

      await HomeWidget.saveWidgetData('flight_has_data', true);
      await HomeWidget.saveWidgetData(
          'flight_route', '${next.from} → ${next.to}');
      await HomeWidget.saveWidgetData('flight_number', next.flightNumber);
      await HomeWidget.saveWidgetData('flight_countdown', countdown);
    }

    await HomeWidget.updateWidget(androidName: _flightWidgetName);
  }

  /// Push water intake data to the home screen widget
  static Future<void> updateWaterWidget(int glasses, int goal) async {
    await HomeWidget.saveWidgetData('water_glasses', glasses);
    await HomeWidget.saveWidgetData('water_goal', goal);
    await HomeWidget.updateWidget(androidName: _waterWidgetName);
  }

  /// Read water data from SharedPreferences and push to widget
  static Future<void> updateWaterWidgetFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final glasses = prefs.getInt('water_glasses') ?? 0;
    final goal = prefs.getInt('water_goal') ?? 8;
    await updateWaterWidget(glasses, goal);
  }

  /// Push grocery list data to the home screen widget
  static Future<void> updateGroceryWidget(
      List<GroceryItem> groceryItems) async {
    final unchecked = groceryItems.where((i) => !i.isChecked).toList();
    await HomeWidget.saveWidgetData('grocery_count', unchecked.length);

    for (int i = 0; i < 2; i++) {
      if (i < unchecked.length) {
        final item = unchecked[i];
        await HomeWidget.saveWidgetData(
          'grocery_${i + 1}',
          '${item.emoji} ${item.name}${item.quantity > 1 ? ' ×${item.quantity}' : ''}',
        );
      } else {
        await HomeWidget.saveWidgetData('grocery_${i + 1}', null);
      }
    }

    await HomeWidget.updateWidget(androidName: _groceryWidgetName);
  }

  /// Push subscriptions data to the home screen widget
  static Future<void> updateSubscriptionsWidget(
      List<SubscriptionModel> subs, String currency) async {
    final total = subs.fold<double>(0, (sum, s) => sum + s.monthlyEquivalent);
    await HomeWidget.saveWidgetData(
        'sub_monthly_total', total.toStringAsFixed(2));
    await HomeWidget.saveWidgetData('sub_currency', currency);

    // Find the next due subscription
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

    await HomeWidget.updateWidget(androidName: _subscriptionsWidgetName);
  }

  /// Push learning goal progress to the home screen widget
  static Future<void> updateLearningWidget(List<LearningGoal> goals) async {
    // Use the first incomplete goal, or the first goal if all complete
    final active = goals.where((g) => !g.isCompleted).toList();
    final goal = active.isNotEmpty
        ? active.first
        : (goals.isNotEmpty ? goals.first : null);

    if (goal != null) {
      final progressPct = (goal.progress * 100).round();
      await HomeWidget.saveWidgetData(
          'learning_goal_title', '${goal.emoji} ${goal.title}');
      await HomeWidget.saveWidgetData('learning_done', goal.completedCount);
      await HomeWidget.saveWidgetData('learning_total', goal.totalCount);
      await HomeWidget.saveWidgetData('learning_progress', progressPct);
    } else {
      await HomeWidget.saveWidgetData('learning_goal_title', null);
      await HomeWidget.saveWidgetData('learning_done', 0);
      await HomeWidget.saveWidgetData('learning_total', 0);
      await HomeWidget.saveWidgetData('learning_progress', 0);
    }

    await HomeWidget.updateWidget(androidName: _learningWidgetName);
  }

  /// Push fitness data to the home screen widget
  static Future<void> updateFitnessWidget(double walkKm, int activities) async {
    await HomeWidget.saveWidgetData(
        'fitness_walk_km', walkKm.toStringAsFixed(1));
    await HomeWidget.saveWidgetData('fitness_activities', activities);
    await HomeWidget.updateWidget(androidName: _fitnessWidgetName);
  }

  /// Update the big home screen widget by rendering it to an image
  static Future<void> updateHomeWidget({
    required String name,
    required List<Map<String, dynamic>> reminders,
    required List<Map<String, dynamic>> flights,
    required List<int> habits,
    required List<dynamic> grocery,
    required List<dynamic> shopping,
    required double walkKm,
    required int activities,
    required bool isDark,
  }) async {
    try {
      // Save data for the widget
      await HomeWidget.saveWidgetData('home_name', name);
      await HomeWidget.saveWidgetData('home_reminders_count', reminders.length);
      await HomeWidget.saveWidgetData('home_flights_count', flights.length);
      await HomeWidget.saveWidgetData('home_habits_done', habits[0]);
      await HomeWidget.saveWidgetData('home_habits_total', habits[1]);
      await HomeWidget.saveWidgetData('home_grocery_done', grocery[0]);
      await HomeWidget.saveWidgetData('home_grocery_total', grocery[1]);
      await HomeWidget.saveWidgetData('home_shopping_done', shopping[0]);
      await HomeWidget.saveWidgetData('home_shopping_total', shopping[1]);
      await HomeWidget.saveWidgetData('home_walk_km', walkKm);
      await HomeWidget.saveWidgetData('home_activities', activities);
      await HomeWidget.saveWidgetData('home_is_dark', isDark);

      // Convert flight objects to simple maps
      final simpleFlights = flights.map((f) {
        try {
          final flight = f['flight'];
          return {
            'route': '${flight.from} → ${flight.to}',
            'number': flight.flightNumber,
            'countdown': _calculateFlightCountdown(flight.departureTime),
          };
        } catch (e) {
          return {
            'route': 'Flight',
            'number': 'N/A',
            'countdown': '0h',
          };
        }
      }).toList();

      // Render the widget to image
      await HomeWidget.renderFlutterWidget(
        HomeWidgetContent(
          name: name,
          reminderData: reminders,
          flightData: simpleFlights,
          habitData: habits,
          groceryData: grocery,
          shoppingData: shopping,
          walkKm: walkKm,
          activities: activities,
          isDark: isDark,
        ),
        key: 'home_widget',
        logicalSize: const Size(400, 800),
      );

      await HomeWidget.updateWidget(androidName: _homeWidgetName);
    } catch (e) {
      print('Error updating home widget: $e');
    }
  }

  static String _calculateFlightCountdown(DateTime departureTime) {
    final timeUntil = departureTime.difference(DateTime.now());
    if (timeUntil.inDays >= 1) {
      return '${timeUntil.inDays}d ${timeUntil.inHours % 24}h';
    } else {
      final hours = timeUntil.inHours;
      final minutes = timeUntil.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }
  }
}
