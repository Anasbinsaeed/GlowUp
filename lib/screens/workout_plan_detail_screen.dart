import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../providers/workout_provider.dart';
import '../models/workout_model.dart';
import '../widgets/cute_card.dart';
import '../widgets/bounce_button.dart';
import '../widgets/cute_back_button.dart';

class WorkoutPlanDetailScreen extends StatelessWidget {
  final String planId;
  const WorkoutPlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, _) {
        final plan = provider.getPlan(planId);
        if (plan == null) {
          return const Scaffold(body: Center(child: Text('Plan not found')));
        }
        return _DetailView(plan: plan);
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  final WorkoutPlan plan;
  const _DetailView({required this.plan});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            context.isDark ? AppColors.darkCard : AppColors.softWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Plan?',
            style: AppTextStyles.heading(
                fontSize: 16, color: context.textPrimary)),
        content: Text(
          'This will permanently delete "${plan.name}" and all its exercises.',
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
              context.read<WorkoutProvider>().deletePlan(plan.id);
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

  void _showAddExercise(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExerciseSheet(planId: plan.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

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
                    Text(plan.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        plan.name,
                        style: AppTextStyles.heading(
                            fontSize: 18, color: context.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Delete plan button
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

              // Progress section
              if (plan.totalCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _ProgressSection(plan: plan, isDark: isDark),
                ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 12),

              // Exercise list
              Expanded(
                child: plan.exercises.isEmpty
                    ? _EmptyExercises(onAdd: () => _showAddExercise(context))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                        itemCount: plan.exercises.length,
                        itemBuilder: (context, i) {
                          return _ExerciseCard(
                            exercise: plan.exercises[i],
                            planId: plan.id,
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

      // Bottom action bar
      bottomNavigationBar: _BottomBar(
        plan: plan,
        onAddExercise: () => _showAddExercise(context),
        onReset: plan.completedCount > 0
            ? () => context.read<WorkoutProvider>().resetAllExercises(plan.id)
            : null,
      ),
    );
  }
}

// ─── Progress Section ─────────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  final WorkoutPlan plan;
  final bool isDark;
  const _ProgressSection({required this.plan, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final progress = plan.progress;
    final isComplete = progress >= 1.0;

    return CuteCard(
      gradient: isDark ? AppColors.gradientLemonDark : AppColors.gradientLemon,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isComplete ? 'Workout Complete! 🎉' : 'Progress',
                style: AppTextStyles.body(
                  fontSize: 13,
                  color: context.textPrimary,
                  weight: FontWeight.w700,
                ),
              ),
              Text(
                '${plan.completedCount}/${plan.totalCount}',
                style: AppTextStyles.body(
                    fontSize: 13, color: context.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? AppColors.successGreen : AppColors.chipSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Exercise Card ────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final String planId;
  const _ExerciseCard({required this.exercise, required this.planId});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final completed = exercise.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CuteCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => context
                  .read<WorkoutProvider>()
                  .toggleExerciseComplete(planId, exercise.id),
              child: AnimatedContainer(
                duration: 200.ms,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      completed ? AppColors.successGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: completed
                        ? AppColors.successGreen
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

            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: 200.ms,
                    style: AppTextStyles.body(
                      fontSize: 15,
                      color: completed
                          ? context.textTertiary
                          : context.textPrimary,
                      weight: FontWeight.w700,
                    ).copyWith(
                      decoration: completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: context.textTertiary,
                    ),
                    child: Text(exercise.name),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Chip(
                        label: '${exercise.sets} × ${exercise.reps}',
                        icon: Icons.repeat_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _Chip(
                        label: exercise.weightKg == null ||
                                exercise.weightKg == 0
                            ? 'Bodyweight'
                            : '${exercise.weightKg! % 1 == 0 ? exercise.weightKg!.toInt() : exercise.weightKg} kg',
                        icon:
                            exercise.weightKg == null || exercise.weightKg == 0
                                ? Icons.accessibility_new_rounded
                                : Icons.fitness_center_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  if (exercise.note != null && exercise.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      exercise.note!,
                      style: AppTextStyles.body(
                          fontSize: 11, color: context.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Delete button
            GestureDetector(
              onTap: () => context
                  .read<WorkoutProvider>()
                  .deleteExercise(planId, exercise.id),
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

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  const _Chip({required this.label, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.chipSelected.withValues(alpha: 0.15)
            : AppColors.chipUnselected,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 11,
              color:
                  isDark ? AppColors.darkAccentPink : AppColors.chipSelected),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.body(
              fontSize: 11,
              color: isDark ? AppColors.darkAccentPink : AppColors.chipSelected,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Exercises ──────────────────────────────────────────────────────────

class _EmptyExercises extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyExercises({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🤸', style: const TextStyle(fontSize: 56))
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text('No exercises yet',
              style: AppTextStyles.heading(
                  fontSize: 16, color: context.textPrimary)),
          const SizedBox(height: 6),
          Text(
            'Tap "Add Exercise" to get started!',
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
  final WorkoutPlan plan;
  final VoidCallback onAddExercise;
  final VoidCallback? onReset;
  const _BottomBar(
      {required this.plan, required this.onAddExercise, required this.onReset});

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
      child: Row(
        children: [
          if (onReset != null) ...[
            BounceButton(
              onTap: onReset!,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.chipUnselected,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Reset All',
                  style: AppTextStyles.body(
                    fontSize: 13,
                    color: AppColors.chipSelected,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: BounceButton(
              onTap: onAddExercise,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPink,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.chipSelected.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Add Exercise',
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
    );
  }
}

// ─── Add Exercise Bottom Sheet ────────────────────────────────────────────────

class _AddExerciseSheet extends StatefulWidget {
  final String planId;
  const _AddExerciseSheet({required this.planId});

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  int _sets = 3;
  int _reps = 10;
  String _weightUnit = 'kg';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final weightKg = double.tryParse(_weightCtrl.text.trim());
    final provider = context.read<WorkoutProvider>();
    final plan = provider.getPlan(widget.planId);
    final order = plan?.exercises.length ?? 0;

    final exercise = WorkoutExercise(
      id: const Uuid().v4(),
      planId: widget.planId,
      name: name,
      sets: _sets,
      reps: _reps,
      weightKg: weightKg,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      order: order,
    );

    provider.addExercise(widget.planId, exercise);
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
        child: SingleChildScrollView(
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
              Text('Add Exercise',
                  style: AppTextStyles.heading(
                      fontSize: 18, color: context.textPrimary)),
              const SizedBox(height: 20),

              // Exercise name
              _FieldLabel('Exercise name', context),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                autofocus: true,
                style: AppTextStyles.body(
                    fontSize: 15, color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. Push-ups, Squats...',
                  hintStyle: AppTextStyles.body(
                      fontSize: 14, color: context.textTertiary),
                ),
              ),
              const SizedBox(height: 20),

              // Sets & Reps row
              Row(
                children: [
                  Expanded(
                    child: _StepperField(
                      label: 'Sets',
                      value: _sets,
                      min: 1,
                      max: 10,
                      onChanged: (v) => setState(() => _sets = v),
                      isDark: isDark,
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StepperField(
                      label: 'Reps',
                      value: _reps,
                      min: 1,
                      max: 50,
                      onChanged: (v) => setState(() => _reps = v),
                      isDark: isDark,
                      context: context,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Weight
              _FieldLabel('Weight (optional)', context),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: AppTextStyles.body(
                          fontSize: 15, color: context.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Leave empty for bodyweight',
                        hintStyle: AppTextStyles.body(
                            fontSize: 13, color: context.textTertiary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // kg/lbs toggle
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCard
                          : AppColors.chipUnselected,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: ['kg', 'lbs'].map((unit) {
                        final selected = _weightUnit == unit;
                        return GestureDetector(
                          onTap: () => setState(() => _weightUnit = unit),
                          child: AnimatedContainer(
                            duration: 150.ms,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.chipSelected
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              unit,
                              style: AppTextStyles.body(
                                fontSize: 13,
                                color: selected
                                    ? Colors.white
                                    : context.textSecondary,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Note
              _FieldLabel('Note (optional)', context),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                style: AppTextStyles.body(
                    fontSize: 15, color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. Keep back straight...',
                  hintStyle: AppTextStyles.body(
                      fontSize: 14, color: context.textTertiary),
                ),
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                child: BounceButton(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPink,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.chipSelected.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Add Exercise',
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
      ),
    );
  }
}

Widget _FieldLabel(String label, BuildContext context) {
  return Text(
    label,
    style: AppTextStyles.body(fontSize: 12, color: context.textSecondary),
  );
}

// ─── Stepper Field ────────────────────────────────────────────────────────────

class _StepperField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool isDark;
  final BuildContext context;

  const _StepperField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.isDark,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body(fontSize: 12, color: context.textSecondary),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.chipUnselected,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _StepBtn(
                icon: Icons.remove_rounded,
                onTap: value > min ? () => onChanged(value - 1) : null,
                isDark: isDark,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$value',
                    style: AppTextStyles.heading(
                      fontSize: 18,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ),
              _StepBtn(
                icon: Icons.add_rounded,
                onTap: value < max ? () => onChanged(value + 1) : null,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;
  const _StepBtn(
      {required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 44,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.chipSelected.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? AppColors.chipSelected
              : (isDark ? AppColors.darkTextTertiary : AppColors.textLight),
        ),
      ),
    );
  }
}
