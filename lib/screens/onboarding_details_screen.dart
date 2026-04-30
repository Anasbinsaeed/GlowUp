import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../widgets/bounce_button.dart';
import 'welcome_screen.dart';

class OnboardingDetailsScreen extends StatefulWidget {
  const OnboardingDetailsScreen({super.key});

  @override
  State<OnboardingDetailsScreen> createState() =>
      _OnboardingDetailsScreenState();
}

class _OnboardingDetailsScreenState extends State<OnboardingDetailsScreen> {
  int _age = 20;
  String _currency = '\$';

  static const _currencies = [
    ('\$', 'USD', '🇺🇸'),
    ('€', 'EUR', '🇪🇺'),
    ('£', 'GBP', '🇬🇧'),
    ('₹', 'INR', '🇮🇳'),
    ('¥', 'JPY', '🇯🇵'),
    ('AED', 'AED', '🇦🇪'),
    ('Rs', 'PKR', '🇵🇰'),
    ('₩', 'KRW', '🇰🇷'),
    ('A\$', 'AUD', '🇦🇺'),
    ('C\$', 'CAD', '🇨🇦'),
  ];

  void _continue() async {
    await context.read<UserProvider>().saveDetails(
          age: _age,
          currency: _currency,
        );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = context.read<UserProvider>().name;
    final isDark = context.isDark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.gradientBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              32,
              MediaQuery.of(context).size.height * 0.06,
              32,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: context.gradientPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🌟', style: TextStyle(fontSize: 40)),
                    ),
                  ).animate().fadeIn(duration: 500.ms).scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut),
                ),
                const SizedBox(height: 32),

                Text(
                  'Almost there${name.isNotEmpty ? ', $name' : ''}! 🎀',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Just a couple more things to\npersonalize your experience ✨',
                  style: TextStyle(
                    fontSize: 15,
                    color: context.textSecondary,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 40),

                // Age section
                Text(
                  'How old are you? 🎂',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 16),

                // Age selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: context.accentPink.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AgeButton(
                        icon: Icons.remove_rounded,
                        onTap: _age > 10 ? () => setState(() => _age--) : null,
                        accentPink: context.accentPink,
                      ),
                      const SizedBox(width: 32),
                      Column(
                        children: [
                          Text(
                            '$_age',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: context.accentPink,
                            ),
                          ),
                          Text(
                            'years old',
                            style: TextStyle(
                                fontSize: 13, color: context.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      _AgeButton(
                        icon: Icons.add_rounded,
                        onTap: _age < 100 ? () => setState(() => _age++) : null,
                        accentPink: context.accentPink,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 36),

                // Currency section
                Text(
                  'Your preferred currency 💰',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 4),
                Text(
                  'Used for subscriptions & expenses',
                  style: TextStyle(fontSize: 12, color: context.textTertiary),
                ).animate().fadeIn(delay: 550.ms),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _currencies.map((c) {
                    final sel = _currency == c.$1;
                    return GestureDetector(
                      onTap: () => setState(() => _currency = c.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.chipSelected
                              : (isDark
                                  ? AppColors.darkCard
                                  : AppColors.chipUnselected),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: sel
                                ? const Color(0xFFB03060)
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.$3, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.$1,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: sel
                                        ? Colors.white
                                        : context.textPrimary,
                                  ),
                                ),
                                Text(
                                  c.$2,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: sel
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : context.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 40),

                CuteButton(
                  label: "Let's glow up!",
                  color: const Color(0xFFFD4C79),
                  emoji: '✨',
                  width: double.infinity,
                  onTap: _continue,
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Your data stays on your device 🔒',
                    style: TextStyle(fontSize: 11, color: context.textTertiary),
                  ),
                ).animate().fadeIn(delay: 750.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color accentPink;

  const _AgeButton({
    required this.icon,
    required this.onTap,
    required this.accentPink,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color:
              enabled ? accentPink.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? accentPink.withValues(alpha: 0.4)
                : context.textTertiary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 24,
          color: enabled ? accentPink : context.textTertiary,
        ),
      ),
    );
  }
}
