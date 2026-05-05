import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../widgets/cute_card.dart';
import '../widgets/cute_snackbar.dart';
import '../widgets/bounce_button.dart';
import '../widgets/cute_date_time_picker.dart';

class WaterReminderScreen extends StatefulWidget {
  const WaterReminderScreen({super.key});

  @override
  State<WaterReminderScreen> createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen> {
  bool _enabled = false;
  int _intervalMinutes = 60;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  bool _saving = false;

  static const _prefEnabled = 'water_reminder_enabled';
  static const _prefInterval = 'water_reminder_interval';
  static const _prefStartH = 'water_reminder_start_h';
  static const _prefStartM = 'water_reminder_start_m';
  static const _prefEndH = 'water_reminder_end_h';
  static const _prefEndM = 'water_reminder_end_m';

  static const _intervals = [
    (30, '30 min'),
    (45, '45 min'),
    (60, '1 hour'),
    (90, '1.5 hours'),
    (120, '2 hours'),
    (180, '3 hours'),
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getBool(_prefEnabled) ?? false;
      _intervalMinutes = prefs.getInt(_prefInterval) ?? 60;
      _startTime = TimeOfDay(
        hour: prefs.getInt(_prefStartH) ?? 8,
        minute: prefs.getInt(_prefStartM) ?? 0,
      );
      _endTime = TimeOfDay(
        hour: prefs.getInt(_prefEndH) ?? 22,
        minute: prefs.getInt(_prefEndM) ?? 0,
      );
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, _enabled);
    await prefs.setInt(_prefInterval, _intervalMinutes);
    await prefs.setInt(_prefStartH, _startTime.hour);
    await prefs.setInt(_prefStartM, _startTime.minute);
    await prefs.setInt(_prefEndH, _endTime.hour);
    await prefs.setInt(_prefEndM, _endTime.minute);

    if (!_enabled) {
      await NotificationService().cancelWaterReminders();
      if (mounted) {
        CuteSnackbar.show(
          context,
          message: 'Water reminders turned off 🤫',
          emoji: '💧',
        );
      }
      return; // stay on screen
    }

    final notifEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (!notifEnabled) {
      if (mounted) {
        CuteSnackbar.show(
          context,
          message: 'Notifications are off in Settings 🔕\nEnable them first!',
          emoji: '⚠️',
          isError: true,
        );
      }
      return;
    }

    CuteSnackbar.show(
      context,
      message: 'Saving...',
      emoji: '💧',
      duration: const Duration(milliseconds: 600),
    );
    setState(() => _saving = true);

    await NotificationService().scheduleWaterReminders(
      intervalMinutes: _intervalMinutes,
      startTime: _startTime,
      endTime: _endTime,
    );

    setState(() => _saving = false);

    if (mounted) {
      CuteSnackbar.show(
        context,
        message: 'Water reminders set! Stay hydrated bestie 💧',
        emoji: '💧',
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await CuteDateTimePicker.showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  int get _remindersPerDay {
    final startMins = _startTime.hour * 60 + _startTime.minute;
    final endMins = _endTime.hour * 60 + _endTime.minute;
    if (endMins <= startMins) return 0;
    return ((endMins - startMins) / _intervalMinutes).floor() + 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.gradientBackground),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? AppColors.darkShadow
                                  : AppColors.shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 16, color: context.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Water Reminder 💧',
                      style: AppTextStyles.heading(
                          fontSize: 22, color: context.textPrimary),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero card
                      CuteCard(
                        gradient: isDark
                            ? AppColors.gradientSkyDark
                            : AppColors.gradientSky,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Text('💧', style: TextStyle(fontSize: 48))
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(
                                  begin: const Offset(1, 1),
                                  end: const Offset(1.1, 1.1),
                                  duration: 1500.ms,
                                ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stay Hydrated!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _enabled
                                        ? '$_remindersPerDay reminders/day • every ${_intervals.firstWhere((e) => e.$1 == _intervalMinutes).$2}'
                                        : 'Set up your hydration schedule ✨',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: context.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _enabled,
                              onChanged: (v) {
                                setState(() => _enabled = v);
                              },
                              activeThumbColor: Colors.white,
                              activeTrackColor: context.accentPink,
                              inactiveThumbColor: context.textTertiary,
                              inactiveTrackColor:
                                  isDark ? AppColors.darkCard : AppColors.cream,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      AnimatedOpacity(
                        opacity: _enabled ? 1.0 : 0.4,
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Interval selector
                            _sectionLabel('⏱️', 'REMIND ME EVERY'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _intervals.map((interval) {
                                final sel = _intervalMinutes == interval.$1;
                                return GestureDetector(
                                  onTap: _enabled
                                      ? () => setState(
                                          () => _intervalMinutes = interval.$1)
                                      : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? AppColors.chipSelected
                                          : (isDark
                                              ? AppColors.darkCard
                                              : AppColors.chipUnselected),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: sel
                                            ? const Color(0xFFB03060)
                                            : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: Text(
                                      interval.$2,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: sel
                                            ? Colors.white
                                            : context.textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            // Time range
                            _sectionLabel('🕐', 'ACTIVE HOURS'),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? AppColors.darkShadow
                                        : AppColors.shadowColor,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _timeTile(
                                    emoji: '🌅',
                                    label: 'Start Time',
                                    time: _startTime,
                                    onTap:
                                        _enabled ? () => _pickTime(true) : null,
                                    isFirst: true,
                                  ),
                                  Divider(
                                    height: 1,
                                    indent: 56,
                                    endIndent: 16,
                                    color: context.textTertiary
                                        .withValues(alpha: 0.15),
                                  ),
                                  _timeTile(
                                    emoji: '🌙',
                                    label: 'End Time',
                                    time: _endTime,
                                    onTap: _enabled
                                        ? () => _pickTime(false)
                                        : null,
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Summary card
                            if (_remindersPerDay > 0)
                              CuteCard(
                                gradient: isDark
                                    ? AppColors.gradientAquaDark
                                    : AppColors.gradientAqua,
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Text('📊',
                                        style: TextStyle(fontSize: 28)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$_remindersPerDay reminders per day',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: context.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'From ${_formatTime(_startTime)} to ${_formatTime(_endTime)}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: context.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(),
                          ],
                        ),
                      )
                          .animate(delay: 150.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 32),

                      // Save button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CuteButton(
                          label: 'Save',
                          emoji: '💧',
                          color: AppColors.chipSelected,
                          width: double.infinity,
                          onTap: _saving ? () {} : _save,
                        ).animate(delay: 200.ms).fadeIn(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String emoji, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: context.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _timeTile({
    required String emoji,
    required String label,
    required TimeOfDay time,
    required VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.textPrimary),
              ),
            ),
            Text(
              _formatTime(time),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: context.accentPink,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 18, color: context.textTertiary),
          ],
        ),
      ),
    );
  }
}
