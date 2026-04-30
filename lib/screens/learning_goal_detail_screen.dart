import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/learning_provider.dart';
import '../models/learning_model.dart';
import '../widgets/cute_card.dart';
import '../widgets/bounce_button.dart';
import '../widgets/cute_back_button.dart';

class LearningGoalDetailScreen extends StatelessWidget {
  final String goalId;
  const LearningGoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningProvider>(
      builder: (context, provider, _) {
        final goal = provider.getGoal(goalId);
        if (goal == null) {
          return const Scaffold(body: Center(child: Text('Goal not found')));
        }
        return _DetailView(goal: goal);
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  final LearningGoal goal;
  const _DetailView({required this.goal});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            context.isDark ? AppColors.darkCard : AppColors.softWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Goal?',
          style:
              AppTextStyles.heading(fontSize: 16, color: context.textPrimary),
        ),
        content: Text(
          'This will permanently delete "${goal.title}" and all its tasks.',
          style: AppTextStyles.body(fontSize: 13, color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.body(
                    fontSize: 13, color: context.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LearningProvider>().deleteGoal(goal.id);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: AppTextStyles.body(
                    fontSize: 13, color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  void _showAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(goalId: goal.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final progress = goal.progress;
    final isComplete = progress >= 1.0 && goal.totalCount > 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.gradientBackground),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    const CuteBackButton(),
                    const SizedBox(width: 14),
                    Text(goal.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: AppTextStyles.heading(
                            fontSize: 18, color: context.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.errorRed, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Meta info + progress card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CuteCard(
                  gradient: isDark
                      ? AppColors.gradientLilacMistDark
                      : AppColors.gradientLilacMist,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Subject badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              goal.subject,
                              style: AppTextStyles.label(
                                fontSize: 11,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                          if (goal.targetDate != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 11, color: context.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM d, yyyy')
                                        .format(goal.targetDate!),
                                    style: AppTextStyles.label(
                                      fontSize: 11,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (isComplete)
                            Text('🎉', style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      if (goal.totalCount > 0) ...[
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isComplete ? 'Goal Complete! 🎉' : 'Progress',
                              style: AppTextStyles.body(
                                fontSize: 13,
                                color: context.textPrimary,
                                weight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${goal.completedCount}/${goal.totalCount}',
                              style: AppTextStyles.body(
                                  fontSize: 13, color: context.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isComplete
                                  ? AppColors.successGreen
                                  : AppColors.chipSelected,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 12),

              // Task list
              Expanded(
                child: goal.tasks.isEmpty
                    ? _EmptyTasks(onAdd: () => _showAddTask(context))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                        itemCount: goal.tasks.length,
                        itemBuilder: (context, i) {
                          return _TaskCard(
                            task: goal.tasks[i],
                            goalId: goal.id,
                          )
                              .animate(delay: (i * 50).ms)
                              .fadeIn(duration: 250.ms)
                              .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 250.ms,
                                  curve: Curves.easeOut);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomBar(
        onAddTask: () => _showAddTask(context),
      ),
    );
  }
}

// ─── Task Card ────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final LearningTask task;
  final String goalId;
  const _TaskCard({required this.task, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CuteCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () =>
                  context.read<LearningProvider>().toggleTask(goalId, task.id),
              child: AnimatedContainer(
                duration: 200.ms,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      completed ? AppColors.chipSelected : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: completed
                        ? AppColors.chipSelected
                        : context.textTertiary,
                    width: 2,
                  ),
                ),
                child: completed
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 14),

            // Task title
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: 200.ms,
                style: AppTextStyles.body(
                  fontSize: 15,
                  color: completed ? context.textTertiary : context.textPrimary,
                  weight: FontWeight.w600,
                ).copyWith(
                  decoration: completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: context.textTertiary,
                ),
                child: Text(task.title),
              ),
            ),

            // Delete button
            GestureDetector(
              onTap: () =>
                  context.read<LearningProvider>().deleteTask(goalId, task.id),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.errorRed, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty Tasks ──────────────────────────────────────────────────────────────

class _EmptyTasks extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyTasks({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 56))
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style:
                AppTextStyles.heading(fontSize: 16, color: context.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Break your goal into small steps 🌸',
            style:
                AppTextStyles.body(fontSize: 13, color: context.textSecondary),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final VoidCallback onAddTask;
  const _BottomBar({required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.softWhite,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BounceButton(
        onTap: onAddTask,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.gradientLilacMistDark
                : AppColors.gradientLilacMist,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCFB3F5).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Add Task',
              style: AppTextStyles.body(
                fontSize: 15,
                color: Colors.white,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Add Task Bottom Sheet ────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  final String goalId;
  const _AddTaskSheet({required this.goalId});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;
    context.read<LearningProvider>().addTask(widget.goalId, title);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.softWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Task ✏️',
              style: AppTextStyles.heading(
                  fontSize: 18, color: context.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              autofocus: true,
              style:
                  AppTextStyles.body(fontSize: 15, color: context.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Read chapter 3, Watch tutorial...',
                hintStyle: AppTextStyles.body(
                    fontSize: 14, color: context.textTertiary),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: BounceButton(
                onTap: _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppColors.gradientLilacMistDark
                        : AppColors.gradientLilacMist,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCFB3F5).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Add Task',
                      style: AppTextStyles.body(
                        fontSize: 15,
                        color: Colors.white,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
