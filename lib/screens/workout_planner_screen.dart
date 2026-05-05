import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/workout_model.dart';
import '../providers/workout_provider.dart';
import '../widgets/cute_card.dart';
import '../widgets/bounce_button.dart';
import '../widgets/section_header.dart';
import '../widgets/cute_back_button.dart';

class WorkoutPlannerScreen extends StatelessWidget {
  const WorkoutPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider()..load(),
      child: const _WorkoutPlannerBody(),
    );
  }
}

class _WorkoutPlannerBody extends StatelessWidget {
  const _WorkoutPlannerBody();

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
                        title: 'Workout Planner',
                        emoji: '💪',
                        actionLabel: 'New Plan',
                        onAction: () => _showAddPlanSheet(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer<WorkoutProvider>(
                  builder: (_, prov, __) {
                    if (prov.plans.isEmpty) return _emptyState(context);
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: prov.plans.length,
                      itemBuilder: (_, i) => _PlanCard(
                        plan: prov.plans[i],
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
          const Text('💪', style: TextStyle(fontSize: 64))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1500.ms,
              ),
          const SizedBox(height: 16),
          Text(
            'No workout plans yet bestie 🥺\nCreate one and start slaying!',
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

  void _showAddPlanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<WorkoutProvider>(),
        child: const _AddPlanSheet(),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final WorkoutPlan plan;
  final int index;

  const _PlanCard({required this.plan, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CuteCard(
        gradient: isDark
            ? AppColors.gradientLavenderDark
            : const LinearGradient(
                colors: [Color(0xFFEDD9FF), Color(0xFFD4B8E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        padding: const EdgeInsets.all(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<WorkoutProvider>(),
              child: _PlanDetailScreen(plan: plan),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(plan.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        '${plan.exercises.length} exercise${plan.exercises.length == 1 ? '' : 's'}',
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondary),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      context.read<WorkoutProvider>().deletePlan(plan.id),
                  child: Icon(Icons.delete_outline,
                      size: 20, color: context.textTertiary),
                ),
              ],
            ),
            if (plan.exercises.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: plan.exercises.take(4).map((ex) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${ex.name} ${ex.setsRepsLabel}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary),
                    ),
                  );
                }).toList()
                  ..addAll(plan.exercises.length > 4
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: context.accentPink.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+${plan.exercises.length - 4} more',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: context.accentPink),
                            ),
                          )
                        ]
                      : []),
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

// ─── Plan Detail Screen ───────────────────────────────────────────────────────

class _PlanDetailScreen extends StatefulWidget {
  final WorkoutPlan plan;
  const _PlanDetailScreen({required this.plan});

  @override
  State<_PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<_PlanDetailScreen> {
  late WorkoutPlan _plan;

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  children: [
                    const CuteBackButton(),
                    const SizedBox(width: 16),
                    Text(_plan.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _plan.name,
                        style: AppTextStyles.heading(
                            fontSize: 20, color: context.textPrimary),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAddExerciseSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: context.gradientPink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Add',
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
              const SizedBox(height: 16),
              Expanded(
                child: _plan.exercises.isEmpty
                    ? Center(
                        child: Text(
                          'No exercises yet 🥺\nTap Add to start!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: context.textSecondary, fontSize: 15),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: _plan.exercises.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final ex = _plan.exercises.removeAt(oldIndex);
                            _plan.exercises.insert(newIndex, ex);
                            for (int i = 0; i < _plan.exercises.length; i++) {
                              _plan.exercises[i] = WorkoutExercise(
                                id: _plan.exercises[i].id,
                                planId: _plan.exercises[i].planId,
                                name: _plan.exercises[i].name,
                                sets: _plan.exercises[i].sets,
                                reps: _plan.exercises[i].reps,
                                weightKg: _plan.exercises[i].weightKg,
                                note: _plan.exercises[i].note,
                                order: i,
                              );
                            }
                          });
                          context.read<WorkoutProvider>().updatePlan(_plan);
                        },
                        itemBuilder: (_, i) {
                          final ex = _plan.exercises[i];
                          return _ExerciseTile(
                            key: ValueKey(ex.id),
                            exercise: ex,
                            index: i,
                            isDark: isDark,
                            onDelete: () {
                              setState(() {
                                _plan.exercises.removeAt(i);
                              });
                              context.read<WorkoutProvider>().updatePlan(_plan);
                            },
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

  void _showAddExerciseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExerciseSheet(
        onAdd: (ex) {
          setState(() {
            _plan.exercises.add(ex);
          });
          context.read<WorkoutProvider>().updatePlan(_plan);
        },
        planId: _plan.id,
        order: _plan.exercises.length,
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final WorkoutExercise exercise;
  final int index;
  final bool isDark;
  final VoidCallback onDelete;

  const _ExerciseTile({
    super.key,
    required this.exercise,
    required this.index,
    required this.isDark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CuteCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Drag handle
            Icon(Icons.drag_handle, color: context.textTertiary, size: 20),
            const SizedBox(width: 12),
            // Number badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: context.gradientPink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: context.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _badge(context, '${exercise.sets} sets'),
                      const SizedBox(width: 6),
                      _badge(context, '${exercise.reps} reps'),
                      if (exercise.weightKg != null) ...[
                        const SizedBox(width: 6),
                        _badge(context,
                            '${exercise.weightKg!.toStringAsFixed(1)} kg'),
                      ],
                    ],
                  ),
                  if (exercise.note != null && exercise.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        exercise.note!,
                        style: TextStyle(
                            fontSize: 11, color: context.textTertiary),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close, size: 18, color: context.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.accentPink.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: context.accentPink),
      ),
    );
  }
}

// ─── Add Plan Sheet ───────────────────────────────────────────────────────────

class _AddPlanSheet extends StatefulWidget {
  const _AddPlanSheet();

  @override
  State<_AddPlanSheet> createState() => _AddPlanSheetState();
}

class _AddPlanSheetState extends State<_AddPlanSheet> {
  final _nameCtrl = TextEditingController();
  bool _nameError = false;
  String _emoji = '💪';

  static const _emojis = [
    '💪',
    '🏋️',
    '🤸',
    '🏃',
    '🚴',
    '🧘',
    '⚽',
    '🏊',
    '🥊',
    '🎯',
    '🔥',
    '⚡',
    '🌟',
    '💥',
    '🏆',
    '🎽',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
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
            Text('New Workout Plan 💪',
                style: AppTextStyles.heading(
                    fontSize: 22, color: context.textPrimary)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (_nameError) setState(() => _nameError = false);
              },
              decoration: InputDecoration(
                hintText: _nameError
                    ? 'Plan name is required ⚠️'
                    : 'Plan name (e.g. Push Day)',
                hintStyle: _nameError
                    ? const TextStyle(color: AppColors.errorRed)
                    : null,
                enabledBorder: _nameError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.errorRed, width: 1.5))
                    : null,
                focusedBorder: _nameError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.errorRed, width: 2))
                    : null,
              ),
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
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CuteButton(
                label: 'Create Plan',
                emoji: '💪',
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
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    final plan = context.read<WorkoutProvider>().createPlan(
          name: _nameCtrl.text.trim(),
          emoji: _emoji,
        );
    context.read<WorkoutProvider>().addPlan(plan);
    Navigator.pop(context);
  }
}

// ─── Add Exercise Sheet ───────────────────────────────────────────────────────

class _AddExerciseSheet extends StatefulWidget {
  final void Function(WorkoutExercise) onAdd;
  final String planId;
  final int order;

  const _AddExerciseSheet({
    required this.onAdd,
    required this.planId,
    required this.order,
  });

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _nameError = false;
  int _sets = 3;
  int _reps = 10;
  double? _weight;
  bool _hasWeight = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
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
            Text('Add Exercise 🏋️',
                style: AppTextStyles.heading(
                    fontSize: 22, color: context.textPrimary)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (_nameError) setState(() => _nameError = false);
              },
              decoration: InputDecoration(
                hintText: _nameError
                    ? 'Exercise name is required ⚠️'
                    : 'Exercise name (e.g. Push-ups)',
                hintStyle: _nameError
                    ? const TextStyle(color: AppColors.errorRed)
                    : null,
                enabledBorder: _nameError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.errorRed, width: 1.5))
                    : null,
                focusedBorder: _nameError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.errorRed, width: 2))
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Sets × Reps
            Row(
              children: [
                Expanded(
                  child: _CounterField(
                    label: 'Sets',
                    emoji: '🔢',
                    value: _sets,
                    min: 1,
                    max: 20,
                    onChanged: (v) => setState(() => _sets = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CounterField(
                    label: 'Reps',
                    emoji: '🔄',
                    value: _reps,
                    min: 1,
                    max: 100,
                    onChanged: (v) => setState(() => _reps = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Weight toggle
            Row(
              children: [
                Text('Add weight?',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: context.textPrimary)),
                const Spacer(),
                Switch(
                  value: _hasWeight,
                  onChanged: (v) => setState(() {
                    _hasWeight = v;
                    if (!v) _weight = null;
                  }),
                  activeThumbColor: context.accentPink,
                ),
              ],
            ),

            if (_hasWeight) ...[
              const SizedBox(height: 8),
              _CounterField(
                label: 'Weight (kg)',
                emoji: '⚖️',
                value: (_weight ?? 10).toInt(),
                min: 1,
                max: 500,
                onChanged: (v) => setState(() => _weight = v.toDouble()),
              ),
            ],

            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                  hintText: 'Note (optional, e.g. slow tempo)'),
            ),
            const SizedBox(height: 24),

            // Preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.accentPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: context.accentPink.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('💪', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(
                    _nameCtrl.text.isEmpty
                        ? 'Exercise preview'
                        : '${_nameCtrl.text}  $_sets×$_reps${_weight != null ? ' × ${_weight!.toStringAsFixed(1)}kg' : ''}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: context.textPrimary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            CuteButton(
              label: 'Add Exercise',
              emoji: '💪',
              color: AppColors.chipSelected,
              width: double.infinity,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    final ex = WorkoutExercise(
      id: UniqueKey().toString(),
      planId: widget.planId,
      name: _nameCtrl.text.trim(),
      sets: _sets,
      reps: _reps,
      weightKg: _hasWeight ? _weight : null,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      order: widget.order,
    );
    widget.onAdd(ex);
    Navigator.pop(context);
  }
}

class _CounterField extends StatelessWidget {
  final String label;
  final String emoji;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _CounterField({
    required this.label,
    required this.emoji,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkCard : AppColors.newPinkLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$emoji $label',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: value > min ? () => onChanged(value - 1) : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.accentPink.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.remove,
                      size: 16,
                      color: context.isDark
                          ? AppColors.newPinkLight
                          : AppColors.darkCard),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$value',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: context.textPrimary),
                ),
              ),
              GestureDetector(
                onTap: value < max ? () => onChanged(value + 1) : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.accentPink.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add,
                      size: 16,
                      color: context.isDark
                          ? AppColors.newPinkLight
                          : AppColors.darkCard),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
