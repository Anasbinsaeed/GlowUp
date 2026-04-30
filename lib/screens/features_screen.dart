import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../widgets/cute_snackbar.dart';
import 'reminder_screen.dart';
import 'habit_screen.dart';
import 'grocery_screen.dart';
import 'shopping_screen.dart';
import 'fitness_screen.dart';
import 'flight_screen.dart';
import 'water_reminder_screen.dart';
import 'workout_planner_screen.dart';
import 'learning_screen.dart';
import 'subscription_screen.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.watch<UserProvider>().name;

    return Container(
      decoration: BoxDecoration(
        gradient: context.gradientBackground,
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, name), // 🔒 stays fixed

            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: _featureCards(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 5),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name.isNotEmpty ? 'Hey $name 🌸' : 'My Space 🌸',
              style: Theme.of(context).textTheme.headlineLarge,
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 4),
            Text(
              'Everything you need, all in one place ✨',
              style: Theme.of(context).textTheme.bodyLarge,
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  List<Widget> _featureCards(BuildContext context) {
    final isDark = context.isDark;
    final features = [
      _FeatureData(
        emoji: '🌸',
        title: 'Reminders',
        subtitle: 'Meds, plants,\ncooking & more',
        gradient: isDark ? AppColors.gradientRoseDark : AppColors.gradientRose,
        screen: const ReminderScreen(),
        delay: 0,
      ),
      _FeatureData(
        emoji: '💖',
        title: 'Habits',
        subtitle: 'Streaks, goals\n& daily wins',
        gradient: isDark
            ? AppColors.gradientLilacMistDark
            : AppColors.gradientLilacMist,
        screen: const HabitScreen(),
        delay: 60,
      ),
      _FeatureData(
        emoji: '🛒',
        title: 'Grocery',
        subtitle: 'Smart shopping\nlist bestie',
        gradient: isDark ? AppColors.gradientAquaDark : AppColors.gradientAqua,
        screen: const GroceryScreen(),
        delay: 120,
      ),
      _FeatureData(
        emoji: '🛍️',
        title: 'Shopping',
        subtitle: 'Wishlist &\nthings to buy',
        gradient:
            isDark ? AppColors.gradientCoralDark : AppColors.gradientCoral,
        screen: const ShoppingScreen(),
        delay: 300,
      ),
      _FeatureData(
        emoji: '🏃‍♀️',
        title: 'Fitness',
        subtitle: 'Workouts, walks\n& nutrition',
        gradient:
            isDark ? AppColors.gradientLemonDark : AppColors.gradientLemon,
        screen: const FitnessScreen(),
        delay: 180,
      ),
      _FeatureData(
        emoji: '✈️',
        title: 'Flights',
        subtitle: 'Boarding pass\n& countdowns',
        gradient: isDark ? AppColors.gradientSkyDark : AppColors.gradientSky,
        screen: const FlightScreen(),
        delay: 240,
      ),
      _FeatureData(
        emoji: '💧',
        title: 'Water',
        subtitle: 'Hydration\nreminders',
        gradient: isDark ? AppColors.gradientAquaDark : AppColors.gradientAqua,
        screen: const WaterReminderScreen(),
        delay: 270,
      ),
      _FeatureData(
        emoji: '💪',
        title: 'Workout',
        subtitle: 'Plans, sets\n& reps tracker',
        gradient:
            isDark ? AppColors.gradientCoralDark : AppColors.gradientCoral,
        screen: const WorkoutPlannerScreen(),
        delay: 300,
      ),
      _FeatureData(
        emoji: '📚',
        title: 'Learning',
        subtitle: 'Goals, tasks\n& progress',
        gradient: isDark ? AppColors.gradientRoseDark : AppColors.gradientRose,
        screen: const LearningScreen(),
        delay: 330,
      ),
      _FeatureData(
        emoji: '💳',
        title: 'Subscriptions',
        subtitle: 'Track bills\n& renewals',
        gradient: isDark
            ? AppColors.gradientLavenderDark
            : AppColors.gradientLavender,
        screen: const SubscriptionScreen(),
        delay: 360,
      ),
    ];

    return features.map((f) => _FeatureCard(data: f)).toList();
  }
}

class _FeatureData {
  final String emoji;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final Widget? screen;
  final int delay;

  const _FeatureData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.screen,
    required this.delay,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData data;
  const _FeatureCard({required this.data});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.data.screen == null) {
      _showComingSoon();
      return;
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.data.screen!,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showComingSoon() {
    CuteSnackbar.show(
      context,
      message: 'Coming soon bestie! Stay tuned ✨',
      emoji: '🌸',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        _onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.data.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.data.emoji, style: const TextStyle(fontSize: 36)),
                  const Spacer(),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? AppColors.darkCardElevated.withValues(alpha: 0.75)
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        size: 18, color: context.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                widget.data.title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.data.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.data.delay))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }
}
