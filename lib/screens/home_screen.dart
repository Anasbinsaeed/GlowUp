import 'dart:async';
import 'package:cuteapp/screens/fitness_screen.dart';
import 'package:cuteapp/screens/habit_screen.dart';
import 'package:cuteapp/screens/reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/reminder_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/fitness_provider.dart';
import '../providers/flight_provider.dart';
import '../providers/grocery_provider.dart';
import '../providers/shopping_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/cute_card.dart';
import '../widgets/section_header.dart';
import 'flight_detail_screen.dart';
import 'grocery_screen.dart';
import 'shopping_screen.dart';
import '../widgets/flight_countdown_card.dart';
import '../services/widget_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late ConfettiController _bloomConfetti;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _bloomConfetti = ConfettiController(duration: const Duration(seconds: 3));

    // Add observer to detect when app comes to foreground
    WidgetsBinding.instance.addObserver(this);

    // Set up a timer to refresh the UI every 10 seconds to remove past reminders
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        // Check and deactivate past one-time reminders
        context.read<ReminderProvider>().checkAndDeactivatePastReminders();

        // Trigger a rebuild to update the UI
        setState(() {});
      }
    });

    // Initial check — delay the widget render slightly so the Flutter engine
    // is fully ready, especially when launched via a homescreen widget tap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().checkAndDeactivatePastReminders();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _updateHomeWidget();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app comes to foreground, refresh immediately
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<ReminderProvider>().checkAndDeactivatePastReminders();
        setState(() {});
        _updateHomeWidget();
      }
    }
  }

  void _updateHomeWidget() {
    final reminderProv = context.read<ReminderProvider>();
    final flightProv = context.read<FlightProvider>();
    final habitProv = context.read<HabitProvider>();
    final groceryProv = context.read<GroceryProvider>();
    final fitnessProv = context.read<FitnessProvider>();

    // Push each data type — each call saves its keys and triggers the dashboard widget
    WidgetService.updateRemindersWidget(reminderProv.reminders);
    WidgetService.updateHabitsWidget(habitProv.habits);
    WidgetService.updateFlightWidget(flightProv.flights);
    WidgetService.updateGroceryWidget(groceryProv.items);
    WidgetService.updateFitnessWidget(
        fitnessProv.todayWalkKm, fitnessProv.todayLogs.length);
  }

  @override
  void dispose() {
    _bloomConfetti.dispose();
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _playBloomCelebration() {
    _bloomConfetti
      ..stop()
      ..play();
  }

  void _playSparkleAnimation() async {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _SparkleAnimationOverlay(
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Hey bestie';
    return 'Good evening';
  }

  String get _greetingEmoji {
    final h = DateTime.now().hour;
    if (h < 12) return '☀️';
    if (h < 17) return '☀️';
    return '🌙';
  }

  String get _motivationalQuote {
    final quotes = [
      "You're THAT girl 💅 slay today!",
      "Glow up era loading... 💅",
      "Soft life, hard work 🌸",
      "Main character energy only 👑",
      "Bestie you're doing amazing 💖",
      "Aaj ka plan follow karo 😡",
    ];
    return quotes[DateTime.now().day % quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.gradientBackgroundDark
                  : AppColors.gradientBackground,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Fixed header at the top
                  _buildHeader(context),
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildQuoteCard(context),
                          _buildTodayReminders(context),
                          _buildHabitSummary(context),
                          _buildListsSummary(context),
                          _buildFitnessSummary(context),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _bloomConfetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                AppColors.babyPink,
                AppColors.softLavender,
                AppColors.peach,
                AppColors.newPinkLight,
                AppColors.streakGold,
              ],
              numberOfParticles: 30,
              emissionFrequency: 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final name = context.watch<UserProvider>().name;
    final isDark = context.isDark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty
                      ? '$_greeting $name! $_greetingEmoji'
                      : '$_greeting $_greetingEmoji',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.textSecondary,
                      ),
                ).animate().fadeIn(duration: 400.ms),
                GestureDetector(
                  onTap: _playSparkleAnimation,
                  child: Text(
                    'Glowup ✨',
                    style: AppTextStyles.display(
                      fontSize: 36,
                      color: context.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _playBloomCelebration,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: context.gradientPink,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isDark ? AppColors.darkAccentPink : AppColors.babyPink)
                            .withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🌸', style: TextStyle(fontSize: 24)),
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.06, 1.06),
                  duration: 1200.ms,
                  curve: Curves.easeInOut,
                ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: CuteCard(
        gradient: isDark ? AppColors.gradientRoseDark : AppColors.gradientRose,
        child: Row(
          children: [
            const Text('💬', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _motivationalQuote,
                style: TextStyle(
                  color:
                      isDark ? AppColors.darkTextPrimary : AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
    );
  }

  Widget _buildTodayReminders(BuildContext context) {
    final reminderProv = context.watch<ReminderProvider>();
    final flightProv = context.watch<FlightProvider>();

    final now = DateTime.now();
    final next24Hours = now.add(const Duration(hours: 24));

    // Filter reminders: show one-time reminders within next 24h,
    // and repeating reminders whose next occurrence is within 24h
    final upcomingReminders = reminderProv.activeReminders.where((r) {
      final next = reminderProv.nextFireTime(r);
      if (next == null) return false;
      return next.isAfter(now) && next.isBefore(next24Hours);
    }).toList();

    // Filter flights: only those within next 24 hours
    final upcomingFlights = flightProv.upcoming.where((f) {
      final timeUntil = f.departureTime.difference(now);
      return timeUntil.inHours < 24 && timeUntil.inHours >= 0;
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: "Upcoming Reminders", emoji: '🌸'),
          const SizedBox(height: 12),
          if (upcomingReminders.isEmpty && upcomingFlights.isEmpty)
            _emptyState("No reminders in next 24h 🎉\nYou're free bestie!")
          else ...[
            // Regular reminders with animated removal
            ...upcomingReminders.asMap().entries.map((e) {
              final r = e.value;
              final timeUntil = r.time.difference(now);
              final hoursUntil = timeUntil.inHours;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  key: ValueKey(r.id),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CuteCard(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReminderScreen())),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? AppColors.darkCardElevated
                                : AppColors.cream,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(r.emoji,
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: context.textPrimary),
                              ),
                              Text(
                                DateFormat('h:mm a').format(r.time),
                                style: TextStyle(
                                    fontSize: 12, color: context.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.accentPink.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            hoursUntil < 1
                                ? '${timeUntil.inMinutes + 1}m'
                                : '${hoursUntil}h',
                            style: TextStyle(
                                fontSize: 11,
                                color: context.accentPink,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: Duration(milliseconds: 100 * e.key))
                      .fadeIn()
                      .slideX(begin: 0.1, end: 0),
                ),
              );
            }),
            // Flight reminders
            ...upcomingFlights.asMap().entries.map((e) {
              final flight = e.value;
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FlightDetailScreen(flight: flight),
                  ),
                ),
                child: FlightCountdownCard(
                  flight: flight,
                  animationDelay: 100 * (upcomingReminders.length + e.key),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildHabitSummary(BuildContext context) {
    final isDark = context.isDark;
    return Consumer<HabitProvider>(
      builder: (_, prov, __) {
        final habits = prov.habits.take(4).toList();
        final doneCount = habits.where((h) => h.isCompletedToday()).length;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Habits', emoji: '💖'),
              const SizedBox(height: 12),
              CuteCard(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HabitScreen()));
                },
                gradient: isDark
                    ? AppColors.gradientLilacMistDark
                    : AppColors.gradientLilacMist,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$doneCount/${habits.length} done today',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    letterSpacing: 1.3,
                                    color: context.textPrimary),
                              ),
                              Text(
                                doneCount == habits.length && habits.isNotEmpty
                                    ? 'Slaying 💅 all habits done!'
                                    : 'Keep going bestie ✨',
                                style: TextStyle(
                                    fontSize: 12, color: context.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (habits.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: doneCount / habits.length,
                          backgroundColor: isDark
                              ? AppColors.darkCardElevated
                                  .withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.5),
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.lilac),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFitnessSummary(BuildContext context) {
    final isDark = context.isDark;
    return Consumer<FitnessProvider>(
      builder: (_, prov, __) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Fitness', emoji: '🏃'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FitnessScreen()));
                },
                child: Row(
                  children: [
                    Expanded(
                      child: CuteCard(
                        gradient: isDark
                            ? AppColors.gradientSkyDark
                            : AppColors.gradientSky,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🚶‍♀️', style: TextStyle(fontSize: 28)),
                            const SizedBox(height: 8),
                            Text(
                              '${prov.todayWalkKm.toStringAsFixed(1)} km',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  letterSpacing: 2,
                                  color: context.textPrimary),
                            ),
                            Text('walked today',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: context.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CuteCard(
                        gradient: isDark
                            ? AppColors.gradientLemonDark
                            : AppColors.gradientLemon,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💪', style: TextStyle(fontSize: 28)),
                            const SizedBox(height: 8),
                            Text(
                              '${prov.todayLogs.length}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: context.textPrimary),
                            ),
                            Text('activities today',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: context.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 150.ms).fadeIn(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListsSummary(BuildContext context) {
    final isDark = context.isDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'My Lists', emoji: '📋'),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Grocery card
                Expanded(
                  child: Consumer<GroceryProvider>(
                    builder: (_, prov, __) {
                      final total = prov.items.length;
                      final done = prov.checked.length;
                      final unchecked = prov.unchecked.take(3).toList();
                      return CuteCard(
                        gradient: isDark
                            ? AppColors.gradientAquaDark
                            : AppColors.gradientAqua,
                        padding: const EdgeInsets.all(14),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GroceryScreen())),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('🛒',
                                    style: TextStyle(fontSize: 22)),
                                const Spacer(),
                                if (total > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.15)
                                          : Colors.white.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('$done/$total',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: context.textPrimary)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Grocery',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: context.textPrimary)),
                            Text(
                              total == 0
                                  ? 'Empty 🥺'
                                  : prov.unchecked.isEmpty
                                      ? 'All done! 💅'
                                      : '${prov.unchecked.length} left',
                              style: TextStyle(
                                  fontSize: 11, color: context.textSecondary),
                            ),
                            if (unchecked.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...unchecked.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(children: [
                                      Text(item.emoji,
                                          style: const TextStyle(fontSize: 13)),
                                      const SizedBox(width: 5),
                                      Expanded(
                                          child: Text(item.name,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: context.textSecondary),
                                              overflow: TextOverflow.ellipsis)),
                                    ]),
                                  )),
                              if (prov.unchecked.length > 3)
                                Text('+${prov.unchecked.length - 3} more',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: context.textTertiary,
                                        fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      )
                          .animate(delay: 100.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Shopping card
                Expanded(
                  child: Consumer<ShoppingProvider>(
                    builder: (_, prov, __) {
                      final total = prov.items.length;
                      final done = prov.checked.length;
                      final unchecked = prov.unchecked.take(3).toList();
                      return CuteCard(
                        gradient: isDark
                            ? AppColors.gradientCoralDark
                            : AppColors.gradientCoral,
                        padding: const EdgeInsets.all(14),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ShoppingScreen())),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('🛍️',
                                    style: TextStyle(fontSize: 22)),
                                const Spacer(),
                                if (total > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.15)
                                          : Colors.white.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text('$done/$total',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: context.textPrimary)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Shopping',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: context.textPrimary)),
                            Text(
                              total == 0
                                  ? 'Empty 🥺'
                                  : prov.unchecked.isEmpty
                                      ? 'All bought! 💅'
                                      : '${prov.unchecked.length} left',
                              style: TextStyle(
                                  fontSize: 11, color: context.textSecondary),
                            ),
                            if (unchecked.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...unchecked.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(children: [
                                      Text(item.emoji,
                                          style: const TextStyle(fontSize: 13)),
                                      const SizedBox(width: 5),
                                      Expanded(
                                          child: Text(item.name,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: context.textSecondary),
                                              overflow: TextOverflow.ellipsis)),
                                    ]),
                                  )),
                              if (prov.unchecked.length > 3)
                                Text('+${prov.unchecked.length - 3} more',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: context.textTertiary,
                                        fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      )
                          .animate(delay: 120.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _SparkleAnimationOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const _SparkleAnimationOverlay({required this.onComplete});

  @override
  State<_SparkleAnimationOverlay> createState() =>
      _SparkleAnimationOverlayState();
}

class _SparkleAnimationOverlayState extends State<_SparkleAnimationOverlay>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _positionAnimations;

  final List<String> _sparkleEmojis = ['✨', '💖', '🌸', '⭐', '💫'];
  final int _emojiCount = 20;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _controllers = List.generate(
      _emojiCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 2500),
        vsync: this,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.2,
              curve: Curves.easeIn), // Fade in first 20%
          reverseCurve: const Interval(0.8, 1.0,
              curve: Curves.easeOut), // Fade out last 20%
        ),
      );
    }).toList();

    _positionAnimations = _controllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;

      // Random start and end positions - sparkles rise up
      final startX = (index % 4) * 0.3 + 0.1; // Spread across screen width
      final startY = (index % 5) * 0.2 + 0.3; // Start from middle-bottom
      final endY = startY - 0.4; // Rise up

      return Tween<Offset>(
        begin: Offset(startX, startY),
        end: Offset(startX + (index.isEven ? 0.15 : -0.15), endY),
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );
    }).toList();
  }

  void _startAnimations() async {
    // Start animations with staggered delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 60), () {
        if (mounted) {
          _controllers[i].forward().then((_) {
            // Reverse to trigger fade out
            if (mounted) {
              _controllers[i].reverse();
            }
          });
        }
      });
    }

    // Complete after all animations (2500ms forward + 2500ms reverse + stagger delays)
    await Future.delayed(const Duration(milliseconds: 5500));
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox.expand(
        child: Stack(
          children: List.generate(_emojiCount, (index) {
            return AnimatedBuilder(
              animation: _controllers[index],
              builder: (context, child) {
                return Positioned(
                  left: _positionAnimations[index].value.dx *
                      MediaQuery.of(context).size.width,
                  top: _positionAnimations[index].value.dy *
                      MediaQuery.of(context).size.height,
                  child: FadeTransition(
                    opacity: _fadeAnimations[index],
                    child: Transform.scale(
                      scale: 0.6 + (_controllers[index].value * 0.6),
                      child: Transform.rotate(
                        angle: _controllers[index].value * 3.14 * 2,
                        child: Text(
                          _sparkleEmojis[index % _sparkleEmojis.length],
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
