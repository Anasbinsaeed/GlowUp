import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeWidgetContent extends StatelessWidget {
  final String name;
  final List<Map<String, dynamic>> reminderData;
  final List<Map<String, dynamic>> flightData;
  final List<int> habitData;
  final List<dynamic> groceryData;
  final List<dynamic> shoppingData;
  final double walkKm;
  final int activities;
  final bool isDark;

  const HomeWidgetContent({
    super.key,
    required this.name,
    required this.reminderData,
    required this.flightData,
    required this.habitData,
    required this.groceryData,
    required this.shoppingData,
    required this.walkKm,
    required this.activities,
    required this.isDark,
  });

  // Direct color values - no context needed
  Color get _textPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.textDark;
  Color get _textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.textMedium;
  Color get _textTertiary =>
      isDark ? AppColors.darkTextTertiary : AppColors.textLight;
  Color get _cardBg => isDark ? AppColors.darkCardElevated : AppColors.cream;
  Color get _accentPink =>
      isDark ? AppColors.darkAccentPink : AppColors.babyPink;

  LinearGradient get _gradientPink =>
      isDark ? AppColors.gradientPinkDark : AppColors.gradientPink;
  LinearGradient get _gradientLavender =>
      isDark ? AppColors.gradientLavenderDark : AppColors.gradientLavender;
  LinearGradient get _gradientMint =>
      isDark ? AppColors.gradientMintDark : AppColors.gradientMint;
  LinearGradient get _gradientPeach =>
      isDark ? AppColors.gradientPeachDark : AppColors.gradientPeach;

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
    try {
      return Material(
        color: Colors.transparent,
        child: Container(
          width: 400,
          height: 800,
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.gradientBackgroundDark
                : AppColors.gradientBackground,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                              style: TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Glowup ✨',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: _gradientPink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('🌸', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Quote card
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppColors.gradientRoseDark
                          : AppColors.gradientRose,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _motivationalQuote,
                            style: TextStyle(
                              color: _textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Upcoming Reminders & Flights Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Text('🌸', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'Upcoming Reminders',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (reminderData.isEmpty && flightData.isEmpty)
                        _emptyState("No reminders in next 24h 🎉")
                      else ...[
                        ...reminderData.map(_buildReminderItem),
                        ...flightData.map(_buildFlightItem),
                      ],
                    ],
                  ),
                ),

                // Habits Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Text('💖', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'Habits',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildHabitProgressCard(),
                    ],
                  ),
                ),

                // Lists Summary
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Text('📋', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'My Lists',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildListsSummary(),
                    ],
                  ),
                ),

                // Fitness Summary
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Text('🏃', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'Fitness',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFitnessSummary(),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return Material(
        child: Container(
          color: isDark ? AppColors.darkBackground : AppColors.softWhite,
          child: Center(
            child: Text(
              'Widget Error: $e',
              style: TextStyle(color: _textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildReminderItem(Map<String, dynamic> reminder) {
    try {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : AppColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  reminder['emoji']?.toString() ?? '📌',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder['title']?.toString() ?? 'Reminder',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    reminder['time']?.toString() ?? 'Time',
                    style: TextStyle(fontSize: 10, color: _textTertiary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _accentPink.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reminder['countdown']?.toString() ?? '0m',
                style: TextStyle(
                  fontSize: 9,
                  color: _accentPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildFlightItem(Map<String, dynamic> flight) {
    try {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: _gradientPeach,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : AppColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('✈️', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flight['route']?.toString() ?? 'Flight',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    flight['number']?.toString() ?? 'N/A',
                    style: TextStyle(fontSize: 10, color: _textTertiary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.streakOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                flight['countdown']?.toString() ?? '0h',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.streakOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildHabitProgressCard() {
    try {
      final doneCount = habitData.isNotEmpty ? habitData[0] : 0;
      final totalCount = habitData.length > 1 ? habitData[1] : 0;
      final progress = totalCount > 0 ? doneCount / totalCount : 0.0;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: _gradientLavender,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : AppColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$doneCount/$totalCount done today',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 1.3,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        doneCount == totalCount && totalCount > 0
                            ? 'Slaying 💅 all habits done!'
                            : 'Keep going bestie ✨',
                        style: TextStyle(fontSize: 10, color: _textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (totalCount > 0) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark
                      ? AppColors.darkCardElevated.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation(AppColors.lilac),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildListsSummary() {
    try {
      final groceryDone = groceryData.isNotEmpty ? groceryData[0] as int : 0;
      final groceryTotal = groceryData.length > 1 ? groceryData[1] as int : 0;
      final shoppingDone = shoppingData.isNotEmpty ? shoppingData[0] as int : 0;
      final shoppingTotal =
          shoppingData.length > 1 ? shoppingData[1] as int : 0;

      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: _gradientMint,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🛒', style: TextStyle(fontSize: 20)),
                      if (groceryTotal > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$groceryDone/$groceryTotal',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Grocery',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    groceryTotal == 0
                        ? 'Empty 🥺'
                        : groceryDone == groceryTotal
                            ? 'All done! 💅'
                            : '${groceryTotal - groceryDone} left',
                    style: TextStyle(fontSize: 9, color: _textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: _gradientPink,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🛍️', style: TextStyle(fontSize: 20)),
                      if (shoppingTotal > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$shoppingDone/$shoppingTotal',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Shopping',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    shoppingTotal == 0
                        ? 'Empty 🥺'
                        : shoppingDone == shoppingTotal
                            ? 'All done! 💅'
                            : '${shoppingTotal - shoppingDone} left',
                    style: TextStyle(fontSize: 9, color: _textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildFitnessSummary() {
    try {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient:
                    isDark ? AppColors.gradientSkyDark : AppColors.gradientSky,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🚶‍♀️', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 6),
                  Text(
                    '${walkKm.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    'walked',
                    style: TextStyle(fontSize: 9, color: _textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.gradientLemonDark
                    : AppColors.gradientLemon,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💪', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 6),
                  Text(
                    '$activities',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    'activities',
                    style: TextStyle(fontSize: 9, color: _textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
