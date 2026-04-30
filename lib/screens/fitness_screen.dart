import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../models/fitness_model.dart';
import '../widgets/cute_card.dart';
import '../widgets/bounce_button.dart';
import '../widgets/section_header.dart';
import '../widgets/cute_back_button.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

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
                      title: 'Fitness',
                      emoji: '🏃',
                      actionLabel: 'Add Log',
                      onAction: () => _showLogSheet(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildStatsRow(),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.darkCard : AppColors.cream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: TabBar(
                  enableFeedback: false,
                  controller: _tabs,
                  indicator: BoxDecoration(
                    color: context.isDark
                        ? const Color(0xFF6A4E78)
                        : context.accentPink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: context.textSecondary,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  dividerColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: const [
                    Tab(text: '🏃 Activity'),
                    Tab(text: '🍗 Nutrition'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _ActivityTab(),
                  _NutritionTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildStatsRow() {
    return Consumer<FitnessProvider>(
      builder: (_, prov, __) {
        final isDark = context.isDark;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _StatCard(
                emoji: '🚶‍♀️',
                value: '${prov.todayWalkKm.toStringAsFixed(1)} km',
                label: 'Today',
                gradient: isDark
                    ? AppColors.gradientMintDark
                    : AppColors.gradientMint,
              ),
              const SizedBox(width: 12),
              _StatCard(
                emoji: '📅',
                value: '${prov.weeklyWalkKm.toStringAsFixed(1)} km',
                label: 'This week',
                gradient: isDark
                    ? AppColors.gradientPeachDark
                    : AppColors.gradientPeach,
              ),
              const SizedBox(width: 12),
              _StatCard(
                emoji: '💪',
                value: '${prov.todayLogs.length}',
                label: 'Activities',
                gradient: isDark
                    ? AppColors.gradientLavenderDark
                    : AppColors.gradientLavender,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LogActivitySheet(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Gradient gradient;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CuteCard(
        gradient: gradient,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 2,
                  wordSpacing: -5,
                  color: context.textPrimary),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: context.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (_, prov, __) {
        if (prov.logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏃‍♀️', style: TextStyle(fontSize: 56))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 1200.ms,
                    ),
                const SizedBox(height: 12),
                Text(
                  'No activity logged yet 🥺\nGet moving bestie!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: AppFonts.nclGasdrifo,
                      color: context.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }
        final sorted = prov.logs.toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          itemCount: sorted.length,
          itemBuilder: (_, i) => _ActivityTile(log: sorted[i], index: i),
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final FitnessLog log;
  final int index;

  const _ActivityTile({required this.log, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CuteCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.isDark
                    ? AppColors.darkCardElevated
                    : AppColors.newPinkLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(log.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.type.toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: context.textPrimary),
                  ),
                  Text(
                    DateFormat('MMM d, h:mm a').format(log.date),
                    style: TextStyle(fontSize: 11, color: context.textTertiary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.isDark
                    ? AppColors.darkCardElevated
                    : AppColors.newPinkLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${log.value} ${log.unit}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    fontSize: 13,
                    color: context.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.read<FitnessProvider>().removeLog(log.id),
              child: Icon(Icons.delete_outline,
                  size: 18, color: context.textTertiary),
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().slideX(
            begin: 0.1,
            end: 0,
          ),
    );
  }
}

class _NutritionTab extends StatefulWidget {
  @override
  State<_NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<_NutritionTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  static const _types = [
    ('protein', '🍗', 'Protein'),
    ('diet', '🥗', 'Diet'),
    ('cheat', '🍕', 'Cheat'),
    ('normal', '🍽️', 'Normal'),
    ('vegan', '🌱', 'Vegan'),
    ('keto', '🥑', 'Keto'),
    ('fasting', '⏳', 'Fasting'),
    ('bulking', '💪', 'Bulking'),
    ('cutting', '✂️', 'Cutting'),
    ('balanced', '⚖️', 'Balanced'),
    ('smoothie', '🥤', 'Smoothie'),
    ('detox', '🍋', 'Detox'),
    ('comfort', '🍜', 'Comfort'),
    ('snacky', '🍿', 'Snacky'),
  ];

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (_, prov, __) {
        final selectedKey = _dateKey(_selectedDay);
        final nd = prov.getNutritionForDate(selectedKey);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              CuteCard(
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2027, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                  onDaySelected: (sel, foc) {
                    setState(() {
                      _selectedDay = sel;
                      _focusedDay = foc;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (_, day, __) {
                      final key = _dateKey(day);
                      final n = prov.getNutritionForDate(key);
                      if (n == null) return null;
                      return Positioned(
                        bottom: 2,
                        child:
                            Text(n.emoji, style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: context.accentPink,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: context.accentLavender,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    todayTextStyle: TextStyle(
                      color: context.isDark
                          ? AppColors.darkBackground
                          : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                    weekendTextStyle: TextStyle(color: context.accentPink),
                    defaultTextStyle: TextStyle(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: context.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CuteCard(
                gradient: context.isDark
                    ? AppColors.gradientPinkDark
                    : AppColors.gradientNewPink,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d').format(_selectedDay),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: context.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nd != null
                          ? '${nd.emoji} ${nd.type} day!'
                          : 'No plan set yet 🥺',
                      style:
                          TextStyle(fontSize: 13, color: context.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _types.map((t) {
                        final sel = nd?.type == t.$1;
                        return GestureDetector(
                          onTap: () => prov.setNutritionDay(selectedKey, t.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? context.accentPink
                                  : (context.isDark
                                      ? AppColors.darkCard
                                          .withValues(alpha: 0.7)
                                      : Colors.white.withValues(alpha: 0.7)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${t.$2} ${t.$3}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    sel ? Colors.white : context.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LogActivitySheet extends StatefulWidget {
  const _LogActivitySheet();

  @override
  State<_LogActivitySheet> createState() => _LogActivitySheetState();
}

class _LogActivitySheetState extends State<_LogActivitySheet> {
  String _type = 'walk';
  double _value = 1.0;
  String _unit = 'km';

  static const _types = [
    ('walk', '🚶‍♀️', 'Walk'),
    ('swim', '🏊‍♀️', 'Swim'),
    ('exercise', '💪', 'Exercise'),
    ('yoga', '🧘‍♀️', 'Yoga'),
    ('dance', '💃', 'Dance'),
  ];

  // Define units and default values for each activity type
  static const _activityConfig = {
    'walk': {
      'units': ['km', 'm'],
      'defaultValue': 1.0,
      'step': 0.1,
      'maxValue': 50.0
    },
    'swim': {
      'units': ['min', 'hours'],
      'defaultValue': 30.0,
      'step': 5.0,
      'maxValue': 300.0
    },
    'exercise': {
      'units': ['min'],
      'defaultValue': 30.0,
      'step': 5.0,
      'maxValue': 180.0
    },
    'yoga': {
      'units': ['min'],
      'defaultValue': 20.0,
      'step': 5.0,
      'maxValue': 120.0
    },
    'dance': {
      'units': ['min'],
      'defaultValue': 15.0,
      'step': 5.0,
      'maxValue': 120.0
    },
  };

  @override
  void initState() {
    super.initState();
    _updateActivityDefaults();
  }

  void _updateActivityDefaults() {
    final config = _activityConfig[_type]!;
    final units = config['units'] as List<String>;
    _unit = units.first;
    _value = config['defaultValue'] as double;
  }

  void _incrementValue() {
    final config = _activityConfig[_type]!;
    final step = config['step'] as double;
    final maxValue = config['maxValue'] as double;

    setState(() {
      _value = double.parse(
          (_value + step).clamp(step, maxValue).toStringAsFixed(2));
    });
  }

  void _decrementValue() {
    final config = _activityConfig[_type]!;
    final step = config['step'] as double;

    setState(() {
      _value = double.parse(
          (_value - step).clamp(step, double.infinity).toStringAsFixed(2));
    });
  }

  String _getDisplayValue() {
    if (_value == _value.toInt()) {
      return _value.toInt().toString();
    }
    return _value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final config = _activityConfig[_type]!;
    final units = config['units'] as List<String>;

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
              'Log Activity 🏃',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary),
            ),
            const SizedBox(height: 20),

            // Activity Type Selection
            Text(
              'Activity Type',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((t) {
                final sel = _type == t.$1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _type = t.$1;
                      _updateActivityDefaults();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel
                          ? (context.isDark
                              ? AppColors.darkCardElevated
                              : AppColors.chipSelected)
                          : (context.isDark
                              ? AppColors.darkCard
                              : AppColors.chipUnselected),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sel
                            ? (context.isDark
                                ? AppColors.darkAccentMint
                                : AppColors.chipSelected)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${t.$2} ${t.$3}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : context.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Value and Unit Selection
            Text(
              'Amount',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary),
            ),
            const SizedBox(height: 12),

            // Value Selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.isDark
                    ? AppColors.darkCard
                    : AppColors.newPinkLight.withAlpha(150),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.chipSelected),
              ),
              child: Column(
                children: [
                  // Value with increment/decrement
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ValueButton(
                        icon: Icons.remove,
                        onTap: _decrementValue,
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          Text(
                            _getDisplayValue(),
                            style: TextStyle(
                              fontSize: 32,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            _unit,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      _ValueButton(
                        icon: Icons.add,
                        onTap: _incrementValue,
                      ),
                    ],
                  ),

                  // Unit Selection (if multiple units available)
                  if (units.length > 1) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: units.map((unit) {
                        final selected = _unit == unit;
                        return GestureDetector(
                          onTap: () => setState(() => _unit = unit),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? context.accentPink
                                  : (context.isDark
                                      ? AppColors.darkCardElevated
                                      : Colors.white.withValues(alpha: 0.7)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unit,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : context.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CuteButton(
                label: 'Log It!',
                emoji: '💪',
                width: double.infinity,
                color: AppColors.chipSelected,
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
    if (_value <= 0) return;

    // Convert value to standard unit for storage
    double finalValue = _value;

    // Convert meters to kilometers for walk
    if (_type == 'walk' && _unit == 'm') {
      finalValue = _value / 1000;
    }
    // Convert hours to minutes for swim
    else if (_type == 'swim' && _unit == 'hours') {
      finalValue = _value * 60;
    }

    // Round to 2 decimal places to avoid floating-point precision issues
    finalValue = double.parse(finalValue.toStringAsFixed(2));

    final log = context.read<FitnessProvider>().createLog(
          type: _type,
          value: finalValue,
        );
    context.read<FitnessProvider>().addLog(log);
    Navigator.pop(context);
  }
}

class _ValueButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ValueButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.accentPink.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.accentPink.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 24,
          color: context.accentPink,
        ),
      ),
    );
  }
}
