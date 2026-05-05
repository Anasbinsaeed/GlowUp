import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/grocery_provider.dart';
import '../providers/fitness_provider.dart';
import '../providers/flight_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/learning_provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/cute_alert_dialog.dart';
import '../widgets/cute_snackbar.dart';
import '../services/notification_service.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  late ConfettiController _bloomConfetti;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _bloomConfetti = ConfettiController(duration: const Duration(seconds: 3));
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

  @override
  Widget build(BuildContext context) {
    final name = context.watch<UserProvider>().name;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(gradient: context.gradientBackground),
          child: SafeArea(
            child: Column(
              children: [
                // Fixed header
                _buildHeader(context, name),
                // Scrollable content
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                          child: _buildProfileCard(context, name)),
                      SliverToBoxAdapter(
                          child: _buildSection(
                        context,
                        title: 'App',
                        emoji: '🌸',
                        delay: 100,
                        tiles: [
                          _SettingsTile(
                            emoji: '🔔',
                            title: 'Notifications',
                            subtitle: 'Manage your cute reminders',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const NotificationSettingsScreen(),
                              ),
                            ),
                          ),
                          _SettingsTile(
                            emoji: '🎨',
                            title: 'Appearance',
                            subtitle: 'Dark, Light, or System',
                            onTap: () => _showAppearanceSettings(context),
                          ),
                          _SettingsTile(
                            emoji: '🌍',
                            title: 'Language',
                            subtitle: 'English (more coming soon)',
                            onTap: () => _showComingSoon(context),
                          ),
                        ],
                      )),
                      SliverToBoxAdapter(
                          child: _buildSection(
                        context,
                        title: 'Account',
                        emoji: '💖',
                        delay: 200,
                        tiles: [
                          _SettingsTile(
                            emoji: '✏️',
                            title: 'Edit Name',
                            subtitle: name.isNotEmpty
                                ? 'Hi $name 👋'
                                : 'Set your name',
                            onTap: () => _showEditName(context),
                          ),
                          _SettingsTile(
                            emoji: '💰',
                            title: 'Currency',
                            subtitle: context.watch<UserProvider>().currency,
                            onTap: () => _showCurrencyPicker(context),
                          ),
                          _SettingsTile(
                            emoji: '🗑️',
                            title: 'Clear All Data',
                            subtitle: 'Start fresh (cannot be undone)',
                            onTap: () => _showClearData(context),
                            isDestructive: true,
                          ),
                        ],
                      )),
                      SliverToBoxAdapter(
                          child: _buildSection(
                        context,
                        title: 'Legal & Info',
                        emoji: '📋',
                        delay: 300,
                        tiles: [
                          _SettingsTile(
                            emoji: '🔒',
                            title: 'Privacy Policy',
                            subtitle: 'Your data stays on your device',
                            onTap: () => _showPrivacyPolicy(context),
                          ),
                          _SettingsTile(
                            emoji: '📄',
                            title: 'Terms of Use',
                            subtitle: 'Be kind, have fun, glow up',
                            onTap: () => _showTerms(context),
                          ),
                          _SettingsTile(
                            emoji: '💌',
                            title: 'About Glowup',
                            subtitle: 'Made with love & pink vibes',
                            onTap: () => _showAbout(context),
                          ),
                        ],
                      )),
                      SliverToBoxAdapter(child: _buildVersionFooter()),
                      const SliverToBoxAdapter(
                          child: SizedBox(
                        height: 100,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ConfettiWidget(
            confettiController: _bloomConfetti,
            blastDirectionality: BlastDirectionality.directional,
            blastDirection: -1.57, // upward
            emissionFrequency: 0.04,
            numberOfParticles: 12,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Color(0xFFFFFFFF),
              Color(0xFFFFF0F5),
              Color(0xFFFFC1CC),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        'Settings ⚙️',
        style: Theme.of(context).textTheme.displayMedium,
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildProfileCard(BuildContext context, String name) {
    final isDark = context.isDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: GestureDetector(
        onTap: _playBloomCelebration,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient:
                isDark ? AppColors.gradientPinkDark : AppColors.gradientNewPink,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.darkShadow : AppColors.shadowColor,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCardElevated.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🌸', style: TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Bestie 💕',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Living your best glow-up life ✨',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
            .animate(delay: 50.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String emoji,
    required List<_SettingsTile> tiles,
    required int delay,
  }) {
    final isDark = context.isDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: context.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDark ? AppColors.darkShadow : AppColors.shadowColor,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: tiles.asMap().entries.map((e) {
                final isLast = e.key == tiles.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 60,
                        endIndent: 20,
                        color: context.textTertiary.withValues(alpha: 0.2),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      )
          .animate(delay: Duration(milliseconds: delay))
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.08, end: 0),
    );
  }

  Widget _buildVersionFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Builder(builder: (context) {
        return Column(
          children: [
            Text('🌸 Glowup 🌸',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textTertiary)),
            SizedBox(height: 4),
            Text('Version 1.0.0 • Made with 💖',
                style: TextStyle(fontSize: 12, color: context.textTertiary)),
            SizedBox(height: 4),
            Text(
                '© ${DateTime.now().year} Anas Bin Saeed • All Rights Reserved.',
                style: TextStyle(fontSize: 12, color: context.textTertiary)),
          ],
        ).animate(delay: 400.ms).fadeIn();
      }),
    );
  }

  void _showComingSoon(BuildContext context) {
    CuteSnackbar.show(
      context,
      message: 'Coming soon bestie! Stay tuned ✨',
      emoji: '🌸',
    );
  }

  void _showAppearanceSettings(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🎨', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(
                  'Appearance',
                  style: AppTextStyles.heading(
                    fontSize: 22,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ThemeOption(
              title: 'Light Mode',
              subtitle: 'Soft pastels & bright vibes',
              icon: '☀️',
              isSelected: themeProvider.isLightMode,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              title: 'Dark Mode',
              subtitle: 'Easy on the eyes, cozy vibes',
              icon: '🌙',
              isSelected: themeProvider.isDarkMode,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              title: 'System',
              subtitle: 'Follows your device setting',
              icon: '📱',
              isSelected: themeProvider.isSystemMode,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditName(BuildContext context) {
    final ctrl = TextEditingController(text: context.read<UserProvider>().name);
    final isDark = context.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.gradientLavenderDark
                : AppColors.gradientNewPink,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: context.accentPink.withValues(alpha: 0.35),
              width: 1.4,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              // Title
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color:
                          (isDark ? AppColors.darkCardElevated : Colors.white)
                              .withValues(alpha: 0.72),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('✏️', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Name',
                    style: AppTextStyles.heading(
                      fontSize: 22,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'How should Glowup call you, bestie?',
                style: AppTextStyles.body(
                  fontSize: 14,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // Text field
              TextField(
                controller: ctrl,
                autofocus: true,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) async {
                  final name = ctrl.text.trim();
                  await context.read<UserProvider>().saveName(name);
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                    CuteSnackbar.show(
                      context,
                      message: name.isNotEmpty
                          ? 'Name updated to $name 💖'
                          : 'Name cleared 🌸',
                      emoji: '✏️',
                    );
                  }
                },
                decoration: const InputDecoration(hintText: 'Your name 🌸'),
              ),
              const SizedBox(height: 20),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style:
                            AppTextStyles.button(color: context.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = ctrl.text.trim();
                        await context.read<UserProvider>().saveName(name);
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                          CuteSnackbar.show(
                            context,
                            message: name.isNotEmpty
                                ? 'Name updated to $name 💖'
                                : 'Name cleared 🌸',
                            emoji: '✏️',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.accentPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Save 💖'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final isDark = context.isDark;
    final current = context.read<UserProvider>().currency;

    const currencies = [
      ('\$', 'USD', '🇺🇸'),
      ('€', 'EUR', '🇪🇺'),
      ('£', 'GBP', '🇬🇧'),
      ('₹', 'INR', '🇮🇳'),
      ('¥', 'JPY', '🇯🇵'),
      ('AED', 'AED', '🇦🇪'),
      ('Rs', 'PKR', '🇵🇰'),
      ('C\$', 'CAD', '🇨🇦'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheetState) {
          String selected = current;
          return Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 16),
                Text('Currency 💰',
                    style: AppTextStyles.heading(
                        fontSize: 20, color: context.textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: currencies.map((c) {
                    final sel = selected == c.$1;
                    return GestureDetector(
                      onTap: () async {
                        setSheetState(() => selected = c.$1);
                        final age = context.read<UserProvider>().age ?? 20;
                        await context
                            .read<UserProvider>()
                            .saveDetails(age: age, currency: c.$1);
                        if (sheetCtx.mounted) {
                          Navigator.pop(sheetCtx);
                          CuteSnackbar.show(
                            context,
                            message: 'Currency updated to ${c.$1} (${c.$2}) 💰',
                            emoji: c.$3,
                          );
                        }
                      },
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
                            Text(c.$3, style: const TextStyle(fontSize: 18)),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showClearData(BuildContext context) {
    showCuteAlertDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => CuteAlertDialog(
        emoji: '🗑️',
        title: 'Clear all data?',
        message:
            'This will delete everything — reminders, habits, grocery list, fitness logs, flights, your name, all of it. The app will restart from the beginning. No take-backs bestie 😭\n\nAre you absolutely sure?',
        confirmText: 'Yes, delete',
        cancelText: 'Nope, keep it!',
        isDestructive: true,
        onCancel: () => Navigator.pop(dialogContext),
        onConfirm: () async {
          Navigator.pop(dialogContext); // Close dialog first
          await _clearAllDataAndRestart(context);
        },
      ),
    );
  }

  Future<void> _clearAllDataAndRestart(BuildContext context) async {
    try {
      // Show crying emoji animation first
      await _showCryingAnimation(context);

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: context.accentPink),
                const SizedBox(height: 16),
                Text(
                  'Clearing data...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Clear all provider data
      await context.read<UserProvider>().clearAllData();

      // Clear other providers if they exist
      try {
        await context.read<ReminderProvider>().clearAllData();
      } catch (e) {
        // Provider might not be available
      }

      try {
        await context.read<HabitProvider>().clearAllData();
      } catch (e) {
        // Provider might not be available
      }

      try {
        await context.read<GroceryProvider>().clearAllData();
      } catch (e) {
        // Provider might not be available
      }

      try {
        await context.read<FitnessProvider>().clearAllData();
      } catch (e) {
        // Provider might not be available
      }

      try {
        await context.read<FlightProvider>().clearAllData();
      } catch (e) {
        // Provider might not be available
      }

      try {
        await context.read<WorkoutProvider>().clearAllData();
      } catch (e) {
        // Provider might not be available
      }

      try {
        await context.read<LearningProvider>().clearAllData();
      } catch (e) {
        // Provider might not be available
      }

      try {
        await context.read<SubscriptionProvider>().clearAllData();
      } catch (e) {
        // Provider might not be available
      }

      // Reset theme to system default
      try {
        await context.read<ThemeProvider>().clearAllData();
      } catch (e) {
        // Provider might not be available
      }

      // Cancel all scheduled notifications
      try {
        await NotificationService().cancelAll();
      } catch (e) {
        // Notification service might not be initialized
      }

      // Wait a moment for all operations to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to onboarding and clear all navigation history
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding',
          (route) => false,
        );
      }
    } catch (e) {
      // If something goes wrong, close loading and show error
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        CuteSnackbar.show(
          context,
          message: 'Oops! Something went wrong 😬',
          isError: true,
        );
      }
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    _showInfoSheet(
      context,
      title: 'Privacy Policy',
      emoji: '🔒',
      content: '''Your privacy is everything to us 💖

Glowup is 100% offline. All your data — reminders, habits, grocery lists, fitness logs, everything — lives only on your device. We never collect, store, or share any of your personal information.

No accounts. No cloud sync. No tracking. No ads. Just you and your glow-up journey 🌸

What we store locally:
• Your name (in app storage)
• Your reminders & habits
• Your grocery & fitness data
• Your flight details

None of this ever leaves your phone. Ever. Pinky promise 🤙

If you uninstall the app, all data is permanently deleted.

Questions? We're just a cute app, not a corporation 💅''',
    );
  }

  void _showTerms(BuildContext context) {
    _showInfoSheet(
      context,
      title: 'Terms of Use',
      emoji: '📄',
      content: '''By using Glowup, you agree to:

✨ Use it to actually glow up (mandatory)
💖 Be kind to yourself — no negative self-talk allowed
🌸 Take your meds when reminded (we're serious about this one)
🏃‍♀️ Actually go on that walk you keep postponing
🛒 Not add "chocolate" to the grocery list every single day (okay fine, we can't stop you)
✈️ Not miss your flight even though we reminded you 3 times

In all seriousness — this app is provided as-is, for personal use only. We're not responsible for missed flights, forgotten meds, or unwatered plants if you ignore the reminders 🌱

Use it, love it, glow up 💅''',
    );
  }

  void _showAbout(BuildContext context) {
    _showInfoSheet(
      context,
      title: 'About Glowup',
      emoji: '🌸',
      content: '''Made with love, pink vibes, and way too much coffee ☕

Glowup was born from a simple idea: what if your productivity app actually felt like a warm hug instead of a corporate spreadsheet? 🤗

We believe that staying on top of your life shouldn't feel like a chore. It should feel cute, fun, and maybe a little bit extra — because you deserve that energy every single day 💅

Glowup is your soft-life companion. She reminds you to take your meds without judgment, cheers you on when you hit a streak, and never, ever makes you feel bad for having a cheat day 🍕

Features built with love:
🌸 Smart Reminders — with personality
💖 Habit Tracker — with confetti
🛒 Grocery List — with sparkles
🏃‍♀️ Fitness Tracker — with encouragement
✈️ Flight Reminders — with boarding pass vibes

This app is for every girl who's trying her best, one day at a time. You're doing amazing, bestie. Keep going 🔥

Version 1.0.0
Made with 💖 for the girlies

© ${DateTime.now().year} Anas Bin Saeed • All Rights Reserved.''',
    );
  }

  void _showInfoSheet(BuildContext context,
      {required String title, required String emoji, required String content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(title,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondary,
                      height: 1.7,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCryingAnimation(BuildContext context) async {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CryingAnimationOverlay(
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 1800));
  }
}

class _SettingsTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.errorRed.withValues(alpha: 0.1)
                    : (isDark ? AppColors.darkCardElevated : AppColors.cream),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDestructive
                          ? AppColors.errorRed
                          : context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:
                        TextStyle(fontSize: 12, color: context.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.textTertiary.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (context.isDark ? AppColors.darkCardElevated : AppColors.cream)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? context.accentPink
                : (context.isDark
                    ? AppColors.darkCard
                    : AppColors.textLight.withValues(alpha: 0.3)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: context.accentPink,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

// I put some images inside assets/images folder, use app-icon.png for app icon, and Change the complete app name to 'Glowup!', and use other images for notification icons

class _CryingAnimationOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const _CryingAnimationOverlay({required this.onComplete});

  @override
  State<_CryingAnimationOverlay> createState() =>
      _CryingAnimationOverlayState();
}

class _CryingAnimationOverlayState extends State<_CryingAnimationOverlay>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _positionAnimations;

  final List<String> _cryingEmojis = ['😭', '😢', '🥺', '😿', '💔'];
  final int _emojiCount = 15;

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
        duration: Duration(milliseconds: 1200 + (index * 50)),
        vsync: this,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
        ),
      );
    }).toList();

    _positionAnimations = _controllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;

      // Random start and end positions
      final startX = (index % 3) * 0.4 + 0.1; // Spread across screen width
      final startY = (index % 4) * 0.25 + 0.1; // Spread across screen height
      final endY = startY + 0.3; // Fall down

      return Tween<Offset>(
        begin: Offset(startX, startY),
        end: Offset(startX + (index.isEven ? 0.1 : -0.1), endY),
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
  }

  void _startAnimations() async {
    // Start animations with staggered delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }

    // Complete after all animations
    await Future.delayed(const Duration(milliseconds: 1800));
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
      color: Colors.black.withValues(alpha: 0.3),
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
                      scale: 0.8 + (_controllers[index].value * 0.4),
                      child: Text(
                        _cryingEmojis[index % _cryingEmojis.length],
                        style: const TextStyle(fontSize: 40),
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
