import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder_model.dart';
import '../widgets/cute_card.dart';
import '../widgets/bounce_button.dart';
import '../widgets/section_header.dart';
import '../widgets/cute_back_button.dart';
import '../widgets/cute_date_time_picker.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(gradient: context.gradientBackground),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const CuteBackButton(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SectionHeader(
                      title: 'Reminders',
                      emoji: '🌸',
                      actionLabel: 'Add',
                      onAction: () => _showAddSheet(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<ReminderProvider>(
                builder: (_, prov, __) {
                  if (prov.reminders.isEmpty) {
                    return _emptyState(context);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    itemCount: prov.reminders.length,
                    itemBuilder: (_, i) => _ReminderTile(
                      reminder: prov.reminders[i],
                      index: i,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

Widget _emptyState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🌸',
                style:
                    TextStyle(fontSize: 64, fontFamily: AppFonts.nclGasdrifo))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 1500.ms,
            ),
        const SizedBox(height: 16),
        Text(
          'No reminders yet bestie 🥺\nAdd one so I can bug you!',
          textAlign: TextAlign.center,
          style: AppTextStyles.body(
              color: context.textSecondary,
              fontSize: 15,
              weight: FontWeight.w500),
        ),
      ],
    ),
  );
}

void _showAddSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddReminderSheet(),
  );
}

class _ReminderTile extends StatelessWidget {
  final ReminderModel reminder;
  final int index;

  const _ReminderTile({required this.reminder, required this.index});

  static const _categoryColors = {
    'medicine': AppColors.babyPink,
    'cooking': AppColors.peach,
    'plant': AppColors.newPinkLight,
    'flight': AppColors.softLavender,
    'custom': AppColors.cream,
  };

  static const _categoryColorsDark = {
    'medicine': Color(0xFF4A2D47),
    'cooking': Color(0xFF4A3D2D),
    'plant': Color(0xFF2D4A3D),
    'flight': Color(0xFF3D2F5C),
    'custom': Color(0xFF3A3530),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colorMap = isDark ? _categoryColorsDark : _categoryColors;
    final color = colorMap[reminder.category] ??
        (isDark ? const Color(0xFF3A3530) : AppColors.cream);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CuteCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child:
                    Text(reminder.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: context.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: context.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        reminder.repeatDays.isEmpty
                            ? DateFormat('MMM d • h:mm a').format(reminder.time)
                            : DateFormat('h:mm a').format(reminder.time),
                        style: TextStyle(
                            fontSize: 12, color: context.textTertiary),
                      ),
                      const SizedBox(width: 8),
                      if (reminder.repeatDays.isNotEmpty)
                        Text(
                          _daysLabel(reminder.repeatDays),
                          style: TextStyle(
                              fontSize: 11, color: context.textTertiary),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch.adaptive(
                  value: reminder.isActive,
                  onChanged: (_) =>
                      context.read<ReminderProvider>().toggle(reminder.id),
                  activeThumbColor: context.accentPink,
                  activeTrackColor: context.accentPink.withValues(alpha: 0.5),
                ),
                GestureDetector(
                  onTap: () =>
                      context.read<ReminderProvider>().remove(reminder.id),
                  child: Icon(Icons.delete_outline,
                      size: 18, color: context.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: 60 * index)).fadeIn().slideX(
            begin: 0.1,
            end: 0,
          ),
    );
  }

  String _daysLabel(List<int> days) {
    if (days.length == 7) return 'Every day';
    const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days.map((d) => names[d]).join(' ');
  }
}

class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet();

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _titleCtrl = TextEditingController();
  bool _titleError = false;
  String _category = 'custom';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  final List<int> _selectedDays = [];
  bool _isRepeating = false; // false = one-time on date, true = repeat weekly

  static const _categories = [
    ('medicine', '💊', 'Medicine'),
    ('workout', '💪', 'Workout'),
    ('water', '💧', 'Water'),
    ('cooking', '🍳', 'Cooking'),
    ('plant', '🌱', 'Plants'),
    ('study', '📚', 'Study'),
    ('meeting', '👥', 'Meeting'),
    ('call', '📞', 'Call'),
    ('shopping', '🛍️', 'Shopping'),
    ('pet', '🐾', 'Pet Care'),
    ('skincare', '✨', 'Skincare'),
    ('sleep', '😴', 'Sleep'),
    ('flight', '✈️', 'Flight'),
    ('custom', '🌸', 'Custom'),
  ];

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'New Reminder 🌸',
              style: AppTextStyles.heading(
                  fontSize: 22, color: context.textPrimary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_titleError) setState(() => _titleError = false);
              },
              decoration: InputDecoration(
                hintText: _titleError
                    ? 'Title is required ⚠️'
                    : 'What should I remind you? 🥺',
                hintStyle: _titleError
                    ? const TextStyle(color: AppColors.errorRed)
                    : null,
                enabledBorder: _titleError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.errorRed, width: 1.5))
                    : null,
                focusedBorder: _titleError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.errorRed, width: 2))
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text('Category',
                style: AppTextStyles.label(
                    fontSize: 14, color: context.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final selected = _category == cat.$1;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.chipSelected
                          : (context.isDark
                              ? AppColors.darkCard
                              : AppColors.chipUnselected),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? AppColors.chipSelected
                            : context.textTertiary.withValues(alpha: 0.0),
                      ),
                    ),
                    child: Text(
                      '${cat.$2} ${cat.$3}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : context.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Schedule type toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _isRepeating = false;
                      _selectedDays.clear();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isRepeating
                            ? AppColors.chipSelected
                            : (context.isDark
                                ? AppColors.darkCard
                                : AppColors.chipUnselected),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '📅 One-time',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: !_isRepeating
                                ? Colors.white
                                : context.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isRepeating = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isRepeating
                            ? AppColors.chipSelected
                            : (context.isDark
                                ? AppColors.darkCard
                                : AppColors.chipUnselected),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '🔁 Repeat',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isRepeating
                                ? Colors.white
                                : context.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date picker (one-time only)
            if (!_isRepeating) ...[
              Text('Date',
                  style: AppTextStyles.label(
                      fontSize: 14, color: context.textPrimary)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final d = await CuteDateTimePicker.showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (d != null) setState(() => _selectedDate = d);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? AppColors.darkCard
                        : AppColors.newPinkLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Text('📅', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Text(
                        _isToday(_selectedDate)
                            ? 'Today'
                            : _isTomorrow(_selectedDate)
                                ? 'Tomorrow'
                                : DateFormat('EEE, MMM d, yyyy')
                                    .format(_selectedDate),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: context.textPrimary),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right,
                          size: 18, color: context.textTertiary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Time picker
            Text('Time',
                style: AppTextStyles.label(
                    fontSize: 14, color: context.textPrimary)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final t = await CuteDateTimePicker.showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (t != null) setState(() => _time = t);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? AppColors.darkCard
                      : AppColors.newPinkLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('⏰', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Text(
                      _time.format(context),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: context.textPrimary),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right,
                        size: 18, color: context.textTertiary),
                  ],
                ),
              ),
            ),

            // Repeat days (repeat mode only)
            if (_isRepeating) ...[
              const SizedBox(height: 16),
              Text('Repeat on',
                  style: AppTextStyles.label(
                      fontSize: 14, color: context.textPrimary)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final sel = _selectedDays.contains(i);
                  return GestureDetector(
                    onTap: () => setState(() {
                      sel ? _selectedDays.remove(i) : _selectedDays.add(i);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: sel
                            ? context.accentPink
                            : (context.isDark
                                ? AppColors.darkCard
                                : AppColors.chipUnselected),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _dayNames[i].substring(0, 1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : context.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CuteButton(
                label: 'Save Reminder',
                emoji: '🌸',
                color: AppColors.chipSelected,
                width: double.infinity,
                onTap: _save,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _titleError = true);
      return;
    }
    final time = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _time.hour,
      _time.minute,
    );
    final reminder = context.read<ReminderProvider>().createNew(
          title: _titleCtrl.text.trim(),
          category: _category,
          time: time,
          repeatDays: _isRepeating ? _selectedDays : [],
        );
    context.read<ReminderProvider>().add(reminder);
    Navigator.pop(context);
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isTomorrow(DateTime d) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return d.year == tomorrow.year &&
        d.month == tomorrow.month &&
        d.day == tomorrow.day;
  }
}
