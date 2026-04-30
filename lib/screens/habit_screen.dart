import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_theme.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import '../widgets/cute_card.dart';
import '../widgets/bounce_button.dart';
import '../widgets/section_header.dart';
import '../widgets/cute_back_button.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                            title: 'Habits',
                            emoji: '💖',
                            actionLabel: 'Add',
                            onAction: () => _showAddSheet(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Consumer<HabitProvider>(
                      builder: (_, prov, __) {
                        if (prov.showConfetti) {
                          _confetti.play();
                        }
                        if (prov.habits.isEmpty) return _emptyState(context);
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          itemCount: prov.habits.length,
                          itemBuilder: (_, i) => _HabitTile(
                            habit: prov.habits[i],
                            index: i,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
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

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💖', style: TextStyle(fontSize: 64))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1200.ms,
              ),
          const SizedBox(height: 16),
          Text(
            'No habits yet 🥺\nStart your glow-up journey!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: AppFonts.nclGasdrifo,
                color: context.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500),
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
      builder: (_) => const _AddHabitSheet(),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final HabitModel habit;
  final int index;

  const _HabitTile({required this.habit, required this.index});

  static const _encouragements = [
    'Slaying 💅',
    "You're THAT girl ✨",
    'Keep going bestie 🔥',
    'Iconic behavior 👑',
    'Main character 🌸',
  ];

  @override
  Widget build(BuildContext context) {
    final done = habit.isCompletedToday();
    final color = Color(int.parse('0xFF${habit.color}'));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: BounceButton(
        onTap: () => context.read<HabitProvider>().toggleToday(habit.id),
        child: CuteCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Completion circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: done
                      ? color.withValues(alpha: 0.9)
                      : color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: done ? color : color.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: done
                      ? const Text('✅', style: TextStyle(fontSize: 24))
                      : Text(habit.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: context.textPrimary,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: context.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (done)
                      Text(
                        _encouragements[index % _encouragements.length],
                        style: TextStyle(
                            fontSize: 12,
                            color: context.accentPink,
                            fontWeight: FontWeight.w600),
                      )
                    else
                      Text(
                        'Tap to complete 🌸',
                        style: TextStyle(
                            fontSize: 12, color: context.textTertiary),
                      ),
                  ],
                ),
              ),
              // Streak badge
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: habit.streak > 0
                          ? const LinearGradient(
                              colors: [Color(0xFFFF8C42), Color(0xFFFFD700)],
                            )
                          : null,
                      color: habit.streak == 0
                          ? (context.isDark
                              ? AppColors.darkCard
                              : AppColors.cream)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          habit.streak > 0 ? '🔥' : '💤',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.streak}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: habit.streak > 0
                                ? Colors.white
                                : context.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => context.read<HabitProvider>().remove(habit.id),
                    child: Icon(Icons.delete_outline,
                        size: 16, color: context.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: 60 * index)).fadeIn().slideX(
            begin: 0.1,
            end: 0,
          ),
    );
  }
}

class _AddHabitSheet extends StatefulWidget {
  const _AddHabitSheet();

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _titleCtrl = TextEditingController();
  bool _titleError = false;
  String _emoji = '🌸';
  String _color = 'FFC0CB';

  static const _emojis = [
    '🌸',
    '💊',
    '🏃',
    '📚',
    '💧',
    '🧘',
    '🍎',
    '😴',
    '💪',
    '🌱',
    '✍️',
    '🎵',
    '🧴',
    '☀️',
    '🥗',
    '💖',
  ];

  static const _colors = [
    'FFC0CB',
    'E6CCFF',
    'DFF5E1',
    'FFD9C0',
    'FFD700',
    'B8E0FF',
    'FFB3C6',
    'C8F7C5',
  ];

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
              'New Habit 💖',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary),
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
                    : 'e.g. Drink water, Morning walk...',
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
            Text('Pick an emoji',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: context.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((e) {
                final sel = _emoji == e;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.chipSelected
                          : (context.isDark
                              ? AppColors.darkCard
                              : AppColors.chipUnselected),
                      borderRadius: BorderRadius.circular(12),
                      border: sel
                          ? Border.all(
                              color: const Color(0xFFB03060), width: 2.5)
                          : Border.all(color: Colors.transparent, width: 2.5),
                    ),
                    child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 22))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Pick a color',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: context.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((c) {
                final sel = _color == c;
                final col = Color(int.parse('0xFF$c'));
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: col,
                      borderRadius: BorderRadius.circular(10),
                      border: sel
                          ? Border.all(color: const Color(0xFFB03060), width: 3)
                          : Border.all(color: Colors.transparent, width: 3),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CuteButton(
                label: 'Add Habit',
                emoji: '💖',
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
    final habit = context.read<HabitProvider>().createNew(
          title: _titleCtrl.text.trim(),
          emoji: _emoji,
          color: _color,
        );
    context.read<HabitProvider>().add(habit);
    Navigator.pop(context);
  }
}
