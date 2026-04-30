import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../widgets/bounce_button.dart';
import 'onboarding_details_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() {
      final hasText = _nameCtrl.text.trim().isNotEmpty;
      if (hasText != _hasInput) setState(() => _hasInput = hasText);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _continue() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    await context.read<UserProvider>().saveName(name);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OnboardingDetailsScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final textTertiary = context.textTertiary;
    final cardColor = context.cardColor;
    final accentPink = context.accentPink;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.gradientBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              32,
              MediaQuery.of(context).size.height * 0.08,
              32,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top emoji cluster
                Center(
                  child: _EmojiCluster(),
                ),
                const SizedBox(height: 40),

                // Welcome text
                Text(
                  'Hey bestie! 🎀',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(
                      begin: 0.3,
                      end: 0,
                    ),
                const SizedBox(height: 10),
                Text(
                  "Welcome to Glowup ✨\nYour personal cute companion\nfor your best life 💖",
                  style: TextStyle(
                    fontSize: 16,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 500.ms).slideY(
                      begin: 0.3,
                      end: 0,
                    ),
                const SizedBox(height: 48),

                // Feature pills
                _FeaturePills()
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms),
                const SizedBox(height: 48),

                // Name input
                Text(
                  "What should I call you? 🥺",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameCtrl,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Your name here 💕',
                    hintStyle: TextStyle(color: textTertiary),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Text('🌸', style: TextStyle(fontSize: 20)),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: accentPink.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: accentPink,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  onSubmitted: (_) => _continue(),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                const SizedBox(height: 24),

                // CTA button
                AnimatedOpacity(
                  opacity: _hasInput ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 300),
                  child: CuteButton(
                    label: "Next",
                    color: const Color(0xFFFD4C79),
                    width: double.infinity,
                    onTap: _continue,
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Your data stays on your device 🔒',
                    style: TextStyle(
                      fontSize: 11,
                      color: textTertiary,
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmojiCluster extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final iconGlow = context.isDark
        ? AppColors.darkShadow
        : AppColors.babyPink.withValues(alpha: 0.5);

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: context.gradientPink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconGlow,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          const Text('🌸', style: TextStyle(fontSize: 56))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                duration: 1400.ms,
                curve: Curves.easeInOut,
              ),
          Positioned(
            top: 8,
            right: 8,
            child: const Text('✨', style: TextStyle(fontSize: 24))
                .animate(delay: 400.ms, onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.3, 1.3),
                  duration: 1000.ms,
                ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: const Text('💖', style: TextStyle(fontSize: 22))
                .animate(delay: 700.ms, onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 1200.ms,
                ),
          ),
          Positioned(
            top: 12,
            left: 10,
            child: const Text('🎀', style: TextStyle(fontSize: 18))
                .animate(delay: 200.ms, onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.2, 1.2),
                  duration: 1100.ms,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 800.ms,
        );
  }
}

class _FeaturePills extends StatelessWidget {
  static const _features = [
    ('💊', 'Reminders'),
    ('💖', 'Habits'),
    ('🛒', 'Grocery'),
    ('🏃', 'Fitness'),
    ('✈️', 'Flights'),
    ('🔥', 'Streaks'),
  ];

  @override
  Widget build(BuildContext context) {
    final pillShadow = context.isDark
        ? AppColors.darkShadow.withValues(alpha: 0.3)
        : AppColors.shadowColor;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _features.asMap().entries.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: pillShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.value.$1, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                e.value.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: 80 * e.key))
            .fadeIn()
            .slideX(begin: 0.2, end: 0);
      }).toList(),
    );
  }
}
