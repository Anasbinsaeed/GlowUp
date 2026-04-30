import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _alertChannelBaseName = 'CuteApp Alerts';
  static const _countdownChannelId = 'cuteapp_countdown_v2';
  static const _countdownChannelName = 'CuteApp Flight Countdown';

  // Returns the channel ID for the currently selected tone
  // Each tone gets its own channel so Android respects the sound change
  static String _channelIdForTone(String toneId) => 'cuteapp_alerts_$toneId';

  // Callback for notification taps
  static void Function(String?)? onNotificationTap;

  Future<void> init() async {
    // Initialize timezones
    tz.initializeTimeZones();

    // Set local timezone - use system's current offset
    final now = DateTime.now();
    final offsetInHours = now.timeZoneOffset.inHours;
    final offsetInMinutes = now.timeZoneOffset.inMinutes % 60;

    // Find a timezone location that matches the current offset
    try {
      // Try common timezone names based on offset
      final locations = tz.timeZoneDatabase.locations;
      tz.Location? matchingLocation;

      for (final location in locations.values) {
        final tzNow = tz.TZDateTime.now(location);
        if (tzNow.timeZoneOffset == now.timeZoneOffset) {
          matchingLocation = location;
          break;
        }
      }

      if (matchingLocation != null) {
        tz.setLocalLocation(matchingLocation);
        print(
            '✅ Timezone set to: ${matchingLocation.name} (UTC${offsetInHours >= 0 ? '+' : ''}$offsetInHours:${offsetInMinutes.abs().toString().padLeft(2, '0')})');
      } else {
        // Fallback: use local timezone
        tz.setLocalLocation(tz.local);
        print(
            '✅ Timezone set to local (UTC${offsetInHours >= 0 ? '+' : ''}$offsetInHours:${offsetInMinutes.abs().toString().padLeft(2, '0')})');
      }
    } catch (e) {
      print('⚠️ Failed to set timezone, using local: $e');
      tz.setLocalLocation(tz.local);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (onNotificationTap != null) {
          onNotificationTap!(response.payload);
        }
      },
    );

    // Create high-priority notification channel for Android
    // Read saved tone preference
    final prefs = await SharedPreferences.getInstance();
    final toneId = prefs.getString('notification_tone') ?? 'default';
    final soundFile = _soundFileForTone(toneId);
    final channelId = _channelIdForTone(toneId);

    final channel = AndroidNotificationChannel(
      channelId,
      _alertChannelBaseName,
      description:
          'Important reminders and alerts that require immediate attention',
      importance: Importance.max,
      playSound: toneId != 'silent',
      sound: soundFile != null
          ? RawResourceAndroidNotificationSound(soundFile)
          : null, // null = system default
      enableVibration: true,
      enableLights: true,
      ledColor: const Color(0xFFE8547A),
      showBadge: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Create ongoing countdown notification channel for flights
    const AndroidNotificationChannel countdownChannel =
        AndroidNotificationChannel(
      _countdownChannelId,
      _countdownChannelName,
      description: 'Ongoing flight countdown timers',
      importance: Importance.high,
      playSound: false,
      enableVibration: false,
      enableLights: false,
      showBadge: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(countdownChannel);

    print('✅ Notification service initialized with high-priority channels');
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Request notification permission
    final notifGranted = await android?.requestNotificationsPermission();
    print(
        '📱 Notification permission: ${notifGranted == true ? "GRANTED" : "DENIED"}');

    // Request exact alarm permission (critical for scheduled notifications)
    final alarmGranted = await android?.requestExactAlarmsPermission();
    print(
        '⏰ Exact alarm permission: ${alarmGranted == true ? "GRANTED" : "DENIED"}');

    if (notifGranted != true || alarmGranted != true) {
      print(
          '⚠️ WARNING: Permissions not fully granted. Notifications may not work!');
    }
  }

  Future<NotificationDetails> _details() async {
    final prefs = await SharedPreferences.getInstance();
    final toneId = prefs.getString('notification_tone') ?? 'default';
    final channelId = _channelIdForTone(toneId);
    final isSilent = toneId == 'silent';

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _alertChannelBaseName,
        channelDescription: 'Important reminders and alerts',
        importance: Importance.max,
        priority: Priority.max,
        playSound: !isSilent,
        enableVibration: true,
        enableLights: true,
        ledColor: const Color(0xFFE8547A),
        ledOnMs: 1000,
        ledOffMs: 500,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        styleInformation: const DefaultStyleInformation(true, true),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  // Cute notification messages per category
  static String cuteMessage(String category, String title) {
    switch (category) {
      case 'medicine':
        return "Hey cutie 🥺 time for your meds ($title), don't act like you didn't see this 💊";
      case 'workout':
        return "Bestie 💪 time to get that summer body! Let's do: $title. No excuses! 🔥";
      case 'water':
        return "Hydrate or diedrate bestie 💧 Drink water NOW! Your skin will thank you ✨";
      case 'cooking':
        return "Bestie 🍳 your kitchen is calling! Time to cook: $title. Gordon Ramsay is watching 👀";
      case 'plant':
        return "Your plants are thirstier than your ex 😭🌱 Water them NOW ($title)!";
      case 'study':
        return "Study time bestie 📚 Let's get that A+ on: $title. You got this! 🎓";
      case 'meeting':
        return "Meeting alert 👥 Time for: $title. Don't be late or they'll judge you 😬";
      case 'call':
        return "Ring ring 📞 Time to call: $title. Stop procrastinating bestie! 💅";
      case 'shopping':
        return "Shopping time 🛍️ Don't forget to buy: $title. Treat yourself queen! 👑";
      case 'pet':
        return "Your fur baby needs you 🐾 Time for: $title. They're waiting! 🥺";
      case 'skincare':
        return "Glow up time ✨ Do your skincare routine: $title. Glass skin loading... 💖";
      case 'sleep':
        return "Bedtime bestie 😴 Time to sleep: $title. Beauty sleep is real! 🌙";
      case 'flight':
        return "✈️ Girlie get up! Your flight reminder: $title. Don't miss it or cry later 😭";
      case 'morning':
        return "Good morning sunshine ☀️ Rise and slay! Here's your glow-up plan for today 💅";
      default:
        return "Psst! 🌸 Don't forget: $title. You got this bestie ✨";
    }
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String category,
    required DateTime scheduledTime,
    bool isRepeating = false,
  }) async {
    // Check if notifications are enabled
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    if (!enabled) return;

    final body = cuteMessage(category, title);

    // Only schedule if the time is in the future
    if (scheduledTime.isBefore(DateTime.now())) {
      print('⚠️ Skipping notification - time is in the past: $scheduledTime');
      return;
    }

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    print('📅 Scheduling notification:');
    print('   ID: $id');
    print('   Title: $title');
    print('   Category: $category');
    print('   Scheduled for: $scheduledTime');
    print('   TZ Scheduled: $tzScheduledTime');
    print('   Is Repeating: $isRepeating');
    print('   Current time: ${DateTime.now()}');

    try {
      await _plugin.zonedSchedule(
        id,
        '${_emojiForCategory(category)} Reminder!',
        body,
        tzScheduledTime,
        await _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // For repeating reminders, match day of week and time to repeat weekly
        matchDateTimeComponents:
            isRepeating ? DateTimeComponents.dayOfWeekAndTime : null,
      );
      print('✅ Notification scheduled successfully!');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  // Schedule flight countdown notifications at key milestones
  Future<void> scheduleFlightCountdownNotifications({
    required String flightId,
    required String flightNumber,
    required String route,
    required DateTime departureTime,
  }) async {
    // Check if notifications are enabled
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    if (!enabled) return;

    final now = DateTime.now();
    final baseId = _stableIdForFlight(flightId);

    // Cancel any existing notifications for this flight
    await cancelFlightNotifications(flightId);

    print('✈️ Scheduling flight notifications for $flightNumber');
    print('   Departure: $departureTime');
    print('   Current: $now');

    // Schedule notification at 5 hours before (4:59:59)
    final fiveHoursBefore = departureTime.subtract(const Duration(hours: 5));
    if (fiveHoursBefore.isAfter(now)) {
      await _plugin.zonedSchedule(
        baseId + 1000,
        '⏰ Flight Countdown Started!',
        '$flightNumber ($route) is in 5 hours or less. Time to start preparing! ✈️',
        tz.TZDateTime.from(fiveHoursBefore, tz.local),
        await _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'flight:$flightId',
      );
      // Start persistent countdown notification exactly at the 5-hour mark.
      await _plugin.zonedSchedule(
        baseId + 3000,
        '✈️ $flightNumber',
        '$route • Countdown started',
        tz.TZDateTime.from(fiveHoursBefore, tz.local),
        _flightCountdownDetails(
          departureTime,
          timeoutAfterMs: 18000000, // 5 hours
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'flight:$flightId',
      );
    } else if (departureTime.isAfter(now)) {
      // If already within 5 hours, show the persistent countdown immediately.
      print('   📍 Already within 5 hours, showing countdown now');
      await showOngoingFlightCountdown(
        id: baseId + 3000,
        flightId: flightId,
        flightNumber: flightNumber,
        route: route,
        departureTime: departureTime,
      );
    }

    // Schedule notification at 3 hours before (2:59:59)
    final threeHoursBefore = departureTime.subtract(const Duration(hours: 3));
    if (threeHoursBefore.isAfter(now)) {
      await _plugin.zonedSchedule(
        baseId + 2000,
        '🚨 URGENT: Flight Departure Soon!',
        'Only 3 hours left until your flight $flightNumber ($route)! Get ready NOW! 🛫',
        tz.TZDateTime.from(threeHoursBefore, tz.local),
        await _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'flight:$flightId',
      );
    }

    // Schedule notification at 1 hour before
    final oneHourBefore = departureTime.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(now)) {
      await _plugin.zonedSchedule(
        baseId + 4000,
        '⚠️ Final Call: 1 Hour Left!',
        'Your flight $flightNumber ($route) departs in 1 hour! Head to the airport NOW! 🚨',
        tz.TZDateTime.from(oneHourBefore, tz.local),
        await _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'flight:$flightId',
      );
    }

    // Schedule notification at departure time
    if (departureTime.isAfter(now)) {
      await _plugin.zonedSchedule(
        baseId,
        '✈️ Flight Departure Time!',
        'Your flight $flightNumber ($route) is departing NOW! 🛫',
        tz.TZDateTime.from(departureTime, tz.local),
        await _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'flight:$flightId',
      );
    }
  }

  // Cancel all notifications for a specific flight
  Future<void> cancelFlightNotifications(String flightId) async {
    final baseId = _stableIdForFlight(flightId);
    await _plugin.cancel(baseId); // Departure notification
    await _plugin.cancel(baseId + 1000); // 5-hour notification
    await _plugin.cancel(baseId + 2000); // 3-hour notification
    await _plugin.cancel(baseId + 3000); // Ongoing notification
    await _plugin.cancel(baseId + 4000); // 1-hour notification
  }

  int flightBaseNotificationId(String flightId) => _stableIdForFlight(flightId);

  Future<void> notifyFlightDepartureNow({
    required String flightId,
    required String flightNumber,
    required String route,
  }) async {
    final baseId = _stableIdForFlight(flightId);
    // Prevent duplicate "departure" notifications when app is active.
    await _plugin.cancel(baseId);
    await _plugin.cancel(baseId + 3000);
    await showInstant(
      id: baseId,
      title: '✈️ Flight Departure Time!',
      body: 'Your flight $flightNumber ($route) is departing NOW! 🛫',
    );
  }

  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      await _details(),
    );
  }

  // Test notification - shows immediately
  Future<void> showTestNotification() async {
    await showInstant(
      id: 99999,
      title: '🌸 Test Notification',
      body: 'If you see this, notifications are working! ✨',
    );
  }

  Future<void> showOngoingFlightCountdown({
    required int id,
    required String flightId,
    required String flightNumber,
    required String route,
    required DateTime departureTime,
  }) async {
    final timeoutAfterMs =
        departureTime.difference(DateTime.now()).inMilliseconds;

    await _plugin.show(
      id,
      '✈️ $flightNumber',
      '$route • Tap to open flight details',
      _flightCountdownDetails(
        departureTime,
        timeoutAfterMs: timeoutAfterMs > 0 ? timeoutAfterMs : 1,
      ),
      payload: 'flight:$flightId',
    );
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Water Reminder ───────────────────────────────────────────────────────

  static const _waterBaseId = 900000;
  static const _waterChannelId = 'cuteapp_water';
  static const _waterChannelName = 'Water Reminders';
  static const _waterMessages = [
    "Hydrate or diedrate bestie 💧 Drink water NOW!",
    "Your skin is literally begging you 🥺 Drink water!",
    "Main character energy = staying hydrated 💅",
    "Bestie it's water o'clock! 💧 Drink up!",
    "Glass skin loading... 💧 Drink your water!",
    "Your plants get watered, why don't you? 🌱💧",
    "Sip sip bestie! 💧 Hydration check!",
    "Water is free therapy bestie 💧 Drink it!",
  ];

  Future<void> scheduleWaterReminders({
    required int intervalMinutes,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    // Cancel existing water reminders
    await cancelWaterReminders();

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    if (!enabled) return;

    // Create water channel if not exists
    const channel = AndroidNotificationChannel(
      _waterChannelId,
      _waterChannelName,
      description: 'Hourly water drinking reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final now = DateTime.now();
    int notifId = _waterBaseId;
    int msgIndex = 0;

    // Schedule notifications from startTime to endTime at intervalMinutes
    DateTime current = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );

    // If start is already past today, start from tomorrow
    if (current.isBefore(now)) {
      current = current.add(const Duration(days: 1));
    }
    // Schedule up to 64 notifications (Android limit)
    int count = 0;
    while (count < 64) {
      final scheduledEnd = DateTime(
        current.year,
        current.month,
        current.day,
        endTime.hour,
        endTime.minute,
      );

      if (current.hour > scheduledEnd.hour ||
          (current.hour == scheduledEnd.hour &&
              current.minute > scheduledEnd.minute)) {
        // Past end time for today, jump to next day start
        current = DateTime(
          current.year,
          current.month,
          current.day + 1,
          startTime.hour,
          startTime.minute,
        );
        continue;
      }

      if (current.isAfter(now)) {
        await _plugin.zonedSchedule(
          notifId++,
          '💧 Water Time!',
          _waterMessages[msgIndex % _waterMessages.length],
          tz.TZDateTime.from(current, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _waterChannelId,
              _waterChannelName,
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              category: AndroidNotificationCategory.reminder,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: false,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        msgIndex++;
        count++;
      }

      current = current.add(Duration(minutes: intervalMinutes));
    }
  }

  Future<void> cancelWaterReminders() async {
    for (int i = _waterBaseId; i < _waterBaseId + 64; i++) {
      await _plugin.cancel(i);
    }
  }

  String _emojiForCategory(String cat) {
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

  NotificationDetails _flightCountdownDetails(
    DateTime departureTime, {
    required int timeoutAfterMs,
  }) {
    final androidDetails = AndroidNotificationDetails(
      _countdownChannelId,
      _countdownChannelName,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      onlyAlertOnce: true,
      icon: '@mipmap/ic_launcher',
      channelShowBadge: true,
      silent: true,
      showWhen: true,
      when: departureTime.millisecondsSinceEpoch,
      usesChronometer: true,
      chronometerCountDown: true,
      // Progress bar removed — Android cannot update it without the app running.
      // The native chronometer countdown works perfectly without the app.
      showProgress: false,
      timeoutAfter: timeoutAfterMs,
      category: AndroidNotificationCategory.transport,
      visibility: NotificationVisibility.public,
      ticker: 'Flight countdown in progress',
      styleInformation: const DefaultStyleInformation(true, true),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
      interruptionLevel: InterruptionLevel.passive,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  int _stableIdForFlight(String flightId) {
    var hash = 0;
    for (final codeUnit in flightId.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return 500000 + hash;
  }

  // Maps tone ID to Android raw resource filename (no extension)
  String? _soundFileForTone(String toneId) {
    switch (toneId) {
      case 'default':
        return null; // system default
      case 'silent':
        return null; // handled via playSound: false
      case 'sparkle':
        return 'sparkle';
      case 'bloom':
        return 'bloom';
      case 'chime':
        return 'chime';
      case 'bubble':
        return 'bubble';
      case 'pop':
        return 'pop';
      case 'crystal':
        return 'crystal';
      case 'breeze':
        return 'breeze';
      case 'drip':
        return 'drip';
      case 'glow':
        return 'glow';
      case 'soft':
        return 'soft';
      default:
        return null;
    }
  }

  // Call this when the user changes the tone — creates a new channel with the new sound
  // (Android ignores sound changes on existing channels, so we use a unique ID per tone)
  Future<void> reinitChannel() async {
    final prefs = await SharedPreferences.getInstance();
    final toneId = prefs.getString('notification_tone') ?? 'default';
    final soundFile = _soundFileForTone(toneId);
    final isSilent = toneId == 'silent';
    final channelId = _channelIdForTone(toneId);

    final channel = AndroidNotificationChannel(
      channelId,
      _alertChannelBaseName,
      description: 'Important reminders and alerts',
      importance: Importance.max,
      playSound: !isSilent,
      sound: soundFile != null
          ? RawResourceAndroidNotificationSound(soundFile)
          : null,
      enableVibration: true,
      enableLights: true,
      ledColor: const Color(0xFFE8547A),
      showBadge: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}
