import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder_model.dart';
import '../database/db_helper.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';

class ReminderProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => _reminders;

  List<ReminderModel> get activeReminders =>
      _reminders.where((r) => r.isActive).toList();

  /// Returns the next fire time for a reminder (used for home screen display)
  DateTime? nextFireTime(ReminderModel reminder) {
    if (!reminder.isActive) return null;
    final now = DateTime.now();

    if (reminder.repeatDays.isEmpty) {
      // One-time: only show if in the future
      return reminder.time.isAfter(now) ? reminder.time : null;
    }

    // Repeating: find the next occurrence across all selected days
    DateTime? earliest;
    for (final day in reminder.repeatDays) {
      final next = _nextOccurrenceForDay(reminder.time, day);
      if (earliest == null || next.isBefore(earliest)) {
        earliest = next;
      }
    }
    return earliest;
  }

  Future<void> load() async {
    final rows = await _db.getAll('reminders');
    _reminders = rows.map(ReminderModel.fromMap).toList();

    // Deactivate one-time reminders that have passed
    final now = DateTime.now();
    for (final reminder in _reminders) {
      if (reminder.isActive &&
          reminder.repeatDays.isEmpty &&
          reminder.time.isBefore(now)) {
        reminder.isActive = false;
        await _db.update('reminders', reminder.toMap(), reminder.id);
      }
    }

    // Reschedule all active reminders (important for app restart/device reboot)
    for (final reminder in _reminders) {
      if (reminder.isActive) {
        await _scheduleReminderNotifications(reminder);
      }
    }

    notifyListeners();
    WidgetService.updateRemindersWidget(_reminders);
  }

  Future<void> add(ReminderModel r) async {
    await _db.insert('reminders', r.toMap());
    _reminders.add(r);
    if (r.isActive) {
      await _scheduleReminderNotifications(r);
    }
    notifyListeners();
    WidgetService.updateRemindersWidget(_reminders);
  }

  Future<void> toggle(String id) async {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    _reminders[idx].isActive = !_reminders[idx].isActive;
    await _db.update('reminders', _reminders[idx].toMap(), id);
    if (_reminders[idx].isActive) {
      await _scheduleReminderNotifications(_reminders[idx]);
    } else {
      await _cancelReminderNotifications(_reminders[idx]);
    }
    notifyListeners();
  }

  Future<void> remove(String id) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    await _cancelReminderNotifications(reminder);
    await _db.delete('reminders', id);
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  ReminderModel createNew({
    required String title,
    required String category,
    required DateTime time,
    required List<int> repeatDays,
    String? note,
  }) {
    return ReminderModel(
      id: const Uuid().v4(),
      title: title,
      category: category,
      emoji: ReminderModel.emojiForCategory(category),
      time: time,
      repeatDays: repeatDays,
      note: note,
    );
  }

  Future<void> clearAllData() async {
    for (final reminder in _reminders) {
      await _cancelReminderNotifications(reminder);
    }
    await _db.clearTable('reminders');
    _reminders.clear();
    notifyListeners();
  }

  // Schedule notifications for a reminder
  Future<void> _scheduleReminderNotifications(ReminderModel reminder) async {
    final notificationService = NotificationService();
    final now = DateTime.now();

    if (reminder.repeatDays.isEmpty) {
      // One-time reminder — use the exact stored date/time
      if (reminder.time.isAfter(now)) {
        await notificationService.scheduleReminder(
          id: _notificationIdForReminder(reminder.id, 0),
          title: reminder.title,
          category: reminder.category,
          scheduledTime: reminder.time,
          isRepeating: false,
        );
      }
    } else {
      // Repeating reminder — schedule for each selected day
      // Use dayOfWeekAndTime so Android auto-repeats weekly
      for (final dayOfWeek in reminder.repeatDays) {
        final scheduledTime = _nextOccurrenceForDay(reminder.time, dayOfWeek);
        await notificationService.scheduleReminder(
          id: _notificationIdForReminder(reminder.id, dayOfWeek),
          title: reminder.title,
          category: reminder.category,
          scheduledTime: scheduledTime,
          isRepeating: true,
        );
      }
    }
  }

  // Cancel all notifications for a reminder
  Future<void> _cancelReminderNotifications(ReminderModel reminder) async {
    final notificationService = NotificationService();
    if (reminder.repeatDays.isEmpty) {
      await notificationService.cancelReminder(
        _notificationIdForReminder(reminder.id, 0),
      );
    } else {
      for (final dayOfWeek in reminder.repeatDays) {
        await notificationService.cancelReminder(
          _notificationIdForReminder(reminder.id, dayOfWeek),
        );
      }
    }
  }

  // Calculate next occurrence for a specific day of week
  DateTime _nextOccurrenceForDay(DateTime time, int targetDayOfWeek) {
    final now = DateTime.now();
    // Flutter weekday: 1=Mon, 7=Sun. Our days: 0=Mon, 6=Sun
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

    // If it's today but time has passed, push to next week
    if (daysUntilTarget == 0 && scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 7));
    }

    return scheduledTime;
  }

  // Generate unique notification ID for reminder + day combination
  int _notificationIdForReminder(String reminderId, int dayOfWeek) {
    var hash = 0;
    for (final codeUnit in reminderId.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return 100000 + hash + dayOfWeek;
  }

  // Check and deactivate one-time reminders that have passed
  Future<void> checkAndDeactivatePastReminders() async {
    final now = DateTime.now();
    bool hasChanges = false;

    for (final reminder in _reminders) {
      if (reminder.isActive &&
          reminder.repeatDays.isEmpty &&
          reminder.time.isBefore(now)) {
        reminder.isActive = false;
        await _db.update('reminders', reminder.toMap(), reminder.id);
        await _cancelReminderNotifications(reminder);
        hasChanges = true;
      }
    }

    if (hasChanges) notifyListeners();
  }
}
