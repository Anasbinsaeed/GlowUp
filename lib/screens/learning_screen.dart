import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/learning_model.dart';
import '../providers/learning_provider.dart';
import '../widgets/cute_card.dart';
import '../widgets/bounce_button.dart';
import '../widgets/section_header.dart';
import '../widgets/cute_back_button.dart';
import '../widgets/cute_date_time_picker.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LearningProvider()..load(),
      child: const _LearningBody(),
    );
  }
}

class _LearningBody extends StatelessWidget {
  const _LearningBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.gradientBackground),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  children: [
                    const CuteBackButton(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SectionHeader(
                        title: 'Learning',
                        emoji: '📚',
                        actionLabel: 'Add Goal',
                        onAction: () => _showAddGoalSheet(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer<LearningProvider>(
                  builder: (_, prov, __) {
                    if (prov.goals.isEmpty) return _emptyState(context);
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: prov.goals.length,
                      itemBuilder: (_, i) => _GoalCard(
                        goal: prov.goals[i],
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
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📚', style: TextStyle(fontSize: 64))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1500.ms,
              ),
          const SizedBox(height: 16),
          Text(
            'No learning goals yet bestie 🥺\nAdd one and start growing!',
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

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<LearningProvider>(),
        child: const _AddGoalSheet(),
      ),
    );
  }
}

// ─── Goal Card ────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final LearningGoal goal;
  final int index;

  const _GoalCard({required this.goal, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final progress = goal.progress;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CuteCard(
        gradient: isDark
            ? AppColors.gradientLilacMistDark
            : AppColors.gradientLilacMist,
        padding: const EdgeInsets.all(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<LearningProvider>(),
              child: _GoalDetailScreen(goal: goal),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        goal.subject,
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (goal.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('✅ Done',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.successGreen)),
                      )
                    else
                      Text(
                        '${goal.completedCount}/${goal.tasks.length}',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: context.isDark
                                ? AppColors.babyPink
                                : AppColors.darkCard),
                      ),
                    if (goal.targetDate != null)
                      Text(
                        DateFormat('MMM d').format(goal.targetDate!),
                        style: TextStyle(
                            fontSize: 10, color: context.textTertiary),
                      ),
                    GestureDetector(
                      onTap: () =>
                          context.read<LearningProvider>().deleteGoal(goal.id),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(Icons.delete_outline,
                            size: 16, color: context.textTertiary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (goal.tasks.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation(
                    goal.isCompleted
                        ? AppColors.successGreen
                        : context.accentPink,
                  ),
                  minHeight: 7,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                goal.isCompleted
                    ? 'Goal completed! You slayed 💅'
                    : '${(progress * 100).toInt()}% complete',
                style: TextStyle(fontSize: 11, color: context.textSecondary),
              ),
            ],
          ],
        ),
      ).animate(delay: Duration(milliseconds: 60 * index)).fadeIn().slideY(
            begin: 0.1,
            end: 0,
          ),
    );
  }
}

// ─── Goal Detail Screen ───────────────────────────────────────────────────────

class _GoalDetailScreen extends StatelessWidget {
  final LearningGoal goal;
  const _GoalDetailScreen({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningProvider>(
      builder: (_, prov, __) {
        final current =
            prov.goals.firstWhere((g) => g.id == goal.id, orElse: () => goal);
        final isDark = context.isDark;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: context.gradientBackground),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Row(
                      children: [
                        const CuteBackButton(),
                        const SizedBox(width: 12),
                        Text(current.emoji,
                            style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current.title,
                                style: AppTextStyles.heading(
                                    fontSize: 18, color: context.textPrimary),
                              ),
                              Text(current.subject,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondary)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showAddTaskSheet(context, current),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: context.gradientPink,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Add Task',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress bar
                  if (current.tasks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: current.progress,
                              backgroundColor: isDark
                                  ? AppColors.darkCard
                                  : AppColors.chipUnselected,
                              valueColor: AlwaysStoppedAnimation(
                                current.isCompleted
                                    ? AppColors.successGreen
                                    : context.accentPink,
                              ),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${current.completedCount}/${current.tasks.length} tasks done',
                                style: TextStyle(
                                    fontSize: 12, color: context.textSecondary),
                              ),
                              Text(
                                '${(current.progress * 100).toInt()}%',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: context.accentPink),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: current.tasks.isEmpty
                        ? Center(
                            child: Text(
                              'No tasks yet 🥺\nTap Add Task to add one!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: context.textSecondary, fontSize: 15),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: current.tasks.length,
                            itemBuilder: (_, i) {
                              final task = current.tasks[i];
                              return _TaskTile(
                                task: task,
                                goalId: current.id,
                                index: i,
                              )
                                  .animate(
                                      delay: Duration(milliseconds: 40 * i))
                                  .fadeIn()
                                  .slideX(begin: 0.05, end: 0);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddTaskSheet(BuildContext context, LearningGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<LearningProvider>(),
        child: _AddTaskSheet(goal: goal),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final LearningTask task;
  final String goalId;
  final int index;

  const _TaskTile({
    required this.task,
    required this.goalId,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () =>
            context.read<LearningProvider>().toggleTask(goalId, task.id),
        child: CuteCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? AppColors.successGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColors.successGreen
                        : context.textTertiary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: task.isCompleted
                        ? context.textTertiary
                        : context.textPrimary,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: context.textTertiary,
                  ),
                  child: Text(task.title),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add Goal Sheet ───────────────────────────────────────────────────────────

class _AddGoalSheet extends StatefulWidget {
  const _AddGoalSheet();

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  bool _titleError = false;
  String _emoji = '📚';
  DateTime? _targetDate;

  static const _emojis = [
    '📚',
    '🎓',
    '💻',
    '🎨',
    '🎵',
    '🌍',
    '🔬',
    '📐',
    '✍️',
    '🧠',
    '🎯',
    '🚀',
    '💡',
    '🌱',
    '🏆',
    '⭐',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
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
            Text('New Learning Goal 📚',
                style: AppTextStyles.heading(
                    fontSize: 22, color: context.textPrimary)),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (_titleError) setState(() => _titleError = false);
              },
              decoration: InputDecoration(
                hintText: _titleError
                    ? 'Goal title is required ⚠️'
                    : 'Goal title (e.g. Learn Flutter)',
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
            const SizedBox(height: 12),
            TextField(
              controller: _subjectCtrl,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              decoration:
                  const InputDecoration(hintText: 'Subject (e.g. Programming)'),
            ),
            const SizedBox(height: 16),
            Text('Pick an emoji',
                style: AppTextStyles.label(
                    fontSize: 14, color: context.textPrimary)),
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
                      border: Border.all(
                        color:
                            sel ? const Color(0xFFB03060) : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 22))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Target date (optional)
            GestureDetector(
              onTap: () async {
                final d = await CuteDateTimePicker.showDatePicker(
                  context: context,
                  initialDate: _targetDate ??
                      DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                );
                if (d != null) setState(() => _targetDate = d);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? AppColors.darkCard
                      : AppColors.newPinkLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _targetDate == null
                            ? 'Set target date (optional)'
                            : 'Target: ${DateFormat('MMM d, yyyy').format(_targetDate!)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _targetDate == null
                              ? context.textTertiary
                              : context.textPrimary,
                        ),
                      ),
                    ),
                    if (_targetDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _targetDate = null),
                        child: Icon(Icons.close,
                            size: 16, color: context.textTertiary),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CuteButton(
                label: 'Create Goal',
                emoji: '📚',
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
    final goal = context.read<LearningProvider>().createGoal(
          title: _titleCtrl.text.trim(),
          subject: _subjectCtrl.text.trim().isEmpty
              ? 'General'
              : _subjectCtrl.text.trim(),
          emoji: _emoji,
          targetDate: _targetDate,
        );
    context.read<LearningProvider>().addGoal(goal);
    Navigator.pop(context);
  }
}

// ─── Add Task Sheet ───────────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  final LearningGoal goal;
  const _AddTaskSheet({required this.goal});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _taskCtrl = TextEditingController();

  @override
  void dispose() {
    _taskCtrl.dispose();
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
          const SizedBox(height: 20),
          Text('Add Task ✅',
              style: AppTextStyles.heading(
                  fontSize: 22, color: context.textPrimary)),
          const SizedBox(height: 16),
          TextField(
            controller: _taskCtrl,
            autofocus: true,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _save(),
            decoration: const InputDecoration(
                hintText: 'Task description (e.g. Watch tutorial)'),
          ),
          const SizedBox(height: 24),
          CuteButton(
            label: 'Add Task',
            emoji: '✅',
            color: AppColors.chipSelected,
            width: double.infinity,
            onTap: _save,
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_taskCtrl.text.trim().isEmpty) return;
    final task = context.read<LearningProvider>().createTask(
          goalId: widget.goal.id,
          title: _taskCtrl.text.trim(),
          order: widget.goal.tasks.length,
        );
    final updatedGoal = LearningGoal(
      id: widget.goal.id,
      title: widget.goal.title,
      subject: widget.goal.subject,
      emoji: widget.goal.emoji,
      tasks: [...widget.goal.tasks, task],
      createdAt: widget.goal.createdAt,
      targetDate: widget.goal.targetDate,
    );
    context.read<LearningProvider>().updateGoal(updatedGoal);
    Navigator.pop(context);
  }
}
