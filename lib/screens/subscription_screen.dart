import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/subscription_model.dart';
import '../providers/subscription_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/cute_card.dart';
import '../widgets/bounce_button.dart';
import '../widgets/section_header.dart';
import '../widgets/cute_back_button.dart';
import '../widgets/cute_date_time_picker.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

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
                        title: 'Subscriptions',
                        emoji: '💳',
                        actionLabel: 'Add',
                        onAction: () => _showAddSheet(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer<SubscriptionProvider>(
                  builder: (_, prov, __) {
                    if (prov.subscriptions.isEmpty) return _emptyState(context);
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _SummaryCard(provider: prov)),
                        if (prov.dueSoon.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text('⚠️ Due Soon',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: context.textSecondary)),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) =>
                                  _SubTile(sub: prov.dueSoon[i], index: i),
                              childCount: prov.dueSoon.length,
                            ),
                          ),
                        ],
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text('📋 All Subscriptions',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: context.textSecondary)),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) =>
                                _SubTile(sub: prov.subscriptions[i], index: i),
                            childCount: prov.subscriptions.length,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
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
          const Text('💳', style: TextStyle(fontSize: 64))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1500.ms),
          const SizedBox(height: 16),
          Text(
            'No subscriptions yet bestie 🥺\nTrack what you pay for!',
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

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SubscriptionProvider>(),
        child: const _AddSubSheet(),
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final SubscriptionProvider provider;
  const _SummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final subs = provider.subscriptions;
    final total = provider.totalMonthly;

    // Detect if all subs use same currency
    final currencies = subs.map((s) => s.currency).toSet();
    final currency = currencies.length == 1 ? currencies.first : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: CuteCard(
        gradient: isDark
            ? AppColors.gradientLilacMistDark
            : AppColors.gradientLilacMist,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Text('💳', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$currency${total.toStringAsFixed(0)}/month',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: context.textPrimary),
                  ),
                  Text(
                    '${provider.subscriptions.length} active subscription${provider.subscriptions.length == 1 ? '' : 's'}',
                    style:
                        TextStyle(fontSize: 13, color: context.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currency${(total * 12).toStringAsFixed(0)}/year',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: context.accentPink),
                ),
                Text('yearly total',
                    style:
                        TextStyle(fontSize: 10, color: context.textTertiary)),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
    );
  }
}

// ─── Subscription Tile ────────────────────────────────────────────────────────

class _SubTile extends StatelessWidget {
  final SubscriptionModel sub;
  final int index;
  const _SubTile({required this.sub, required this.index});

  static const _catColors = {
    'streaming': Color(0xFFFFE0E6),
    'software': Color(0xFFE8E0FF),
    'fitness': Color(0xFFDFF5E1),
    'music': Color(0xFFFFEDD5),
    'gaming': Color(0xFFE0F0FF),
    'news': Color(0xFFFFF3D5),
    'cloud': Color(0xFFE0F5F5),
    'other': Color(0xFFF5F5F5),
  };

  static const _catColorsDark = {
    'streaming': Color(0xFF4A2D3D),
    'software': Color(0xFF3D2D4A),
    'fitness': Color(0xFF2D4A3D),
    'music': Color(0xFF4A3D2D),
    'gaming': Color(0xFF2D3D4A),
    'news': Color(0xFF4A4A2D),
    'cloud': Color(0xFF2D4A4A),
    'other': Color(0xFF3A3A3A),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colorMap = isDark ? _catColorsDark : _catColors;
    final bgColor = colorMap[sub.category] ??
        (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5));
    final daysUntil = sub.nextBillingDate.difference(DateTime.now()).inDays;
    final isOverdue = sub.isOverdue;
    final isDueSoon = sub.isDueSoon && !isOverdue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: CuteCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(14)),
              child: Center(
                  child: Text(sub.emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sub.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: context.textPrimary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${sub.currency}${sub.amount.toStringAsFixed(0)} / ${sub.billingLabel}',
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? AppColors.errorRed.withValues(alpha: 0.15)
                              : isDueSoon
                                  ? AppColors.streakGold.withValues(alpha: 0.2)
                                  : context.accentPink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOverdue
                              ? 'Overdue!'
                              : isDueSoon
                                  ? 'Due in $daysUntil days'
                                  : DateFormat('MMM d')
                                      .format(sub.nextBillingDate),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isOverdue
                                ? AppColors.errorRed
                                : isDueSoon
                                    ? AppColors.streakGold
                                    : context.accentPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () =>
                      context.read<SubscriptionProvider>().remove(sub.id),
                  child: Icon(Icons.delete_outline,
                      size: 18, color: context.textTertiary),
                ),
                const SizedBox(height: 6),
                if (isOverdue || isDueSoon)
                  GestureDetector(
                    onTap: () => context
                        .read<SubscriptionProvider>()
                        .renewSubscription(sub.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('✓ Renew',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.successGreen)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 50 * index))
          .fadeIn()
          .slideX(begin: 0.1, end: 0),
    );
  }
}

// ─── Add Subscription Sheet ───────────────────────────────────────────────────

class _AddSubSheet extends StatefulWidget {
  const _AddSubSheet();

  @override
  State<_AddSubSheet> createState() => _AddSubSheetState();
}

class _AddSubSheetState extends State<_AddSubSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _emoji = '💳';
  String _category = 'streaming';
  late String _currency;
  String _billingCycle = 'monthly';
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    // Default to user's preferred currency from onboarding
    _currency = context.read<UserProvider>().currency;
  }

  bool _reminderEnabled = true;
  int _reminderDaysBefore = 3;
  bool _nameError = false;
  bool _amountError = false;

  static const _categories = [
    ('streaming', '📺', 'Streaming'),
    ('software', '💻', 'Software'),
    ('fitness', '🏋️', 'Fitness'),
    ('music', '🎵', 'Music'),
    ('gaming', '🎮', 'Gaming'),
    ('news', '📰', 'News'),
    ('cloud', '☁️', 'Cloud'),
    ('other', '💳', 'Other'),
  ];

  static const _cycles = [
    ('weekly', 'Weekly'),
    ('monthly', 'Monthly'),
    ('yearly', 'Yearly'),
  ];

  static const _currencies = [
    '\$',
    '€',
    '£',
    '₹',
    '¥',
    'AED',
    'Rs',
    '₩',
    'A\$',
    'C\$'
  ];

  static const _emojis = [
    '💳',
    '📺',
    '🎵',
    '💻',
    '🎮',
    '📰',
    '☁️',
    '🏋️',
    '🎬',
    '📚',
    '🎧',
    '🌐',
    '🔒',
    '📱',
    '🛡️',
    '⭐',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final nameEmpty = _nameCtrl.text.trim().isEmpty;
    final amountEmpty = _amountCtrl.text.trim().isEmpty ||
        double.tryParse(_amountCtrl.text.trim()) == null;
    if (nameEmpty || amountEmpty) {
      setState(() {
        _nameError = nameEmpty;
        _amountError = amountEmpty;
      });
      return;
    }
    final amount = double.parse(_amountCtrl.text.trim());
    final sub = context.read<SubscriptionProvider>().createNew(
          name: _nameCtrl.text.trim(),
          emoji: _emoji,
          category: _category,
          amount: amount,
          currency: _currency,
          billingCycle: _billingCycle,
          nextBillingDate: _nextBillingDate,
          reminderEnabled: _reminderEnabled,
          reminderDaysBefore: _reminderDaysBefore,
        );
    context.read<SubscriptionProvider>().add(sub);
    Navigator.pop(context);
  }

  void _showEmojiPicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _emojis.map((e) {
            final sel = _emoji == e;
            return GestureDetector(
              onTap: () {
                setState(() => _emoji = e);
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.chipSelected
                      : (isDark
                          ? AppColors.darkCard
                          : AppColors.chipUnselected),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? const Color(0xFFB03060) : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                child: Center(
                    child: Text(e, style: const TextStyle(fontSize: 24))),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 14),
            Text('New Subscription 💳',
                style: AppTextStyles.heading(
                    fontSize: 20, color: context.textPrimary)),
            const SizedBox(height: 14),

            // Name + emoji button in one row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) {
                      if (_nameError) setState(() => _nameError = false);
                    },
                    decoration: InputDecoration(
                      hintText: _nameError
                          ? 'Service name is required ⚠️'
                          : 'Service name (e.g. Netflix)',
                      hintStyle: _nameError
                          ? const TextStyle(color: AppColors.errorRed)
                          : null,
                      enabledBorder: _nameError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.errorRed, width: 1.5),
                            )
                          : null,
                      focusedBorder: _nameError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.errorRed, width: 2),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showEmojiPicker(context, isDark),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppColors.darkCard : AppColors.newPinkLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: context.accentPink.withValues(alpha: 0.1)),
                    ),
                    child: Center(
                        child:
                            Text(_emoji, style: const TextStyle(fontSize: 26))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category
            Text('Category',
                style: AppTextStyles.label(
                    fontSize: 13, color: context.textPrimary)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _categories.map((cat) {
                final sel = _category == cat.$1;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.chipSelected
                          : (isDark
                              ? AppColors.darkCard
                              : AppColors.chipUnselected),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            sel ? const Color(0xFFB03060) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${cat.$2} ${cat.$3}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : context.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Amount + Currency + Billing cycle in one row
            Row(
              children: [
                // Currency — tap to cycle
                GestureDetector(
                  onTap: () {
                    final idx = _currencies.indexOf(_currency);
                    setState(() => _currency =
                        _currencies[(idx + 1) % _currencies.length]);
                  },
                  child: Container(
                    width: 56,
                    height: 52,
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppColors.darkCard : AppColors.newPinkLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: context.accentPink.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        _currency,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      if (_amountError) setState(() => _amountError = false);
                    },
                    decoration: InputDecoration(
                      hintText: _amountError ? 'Enter amount ⚠️' : '0.00',
                      hintStyle: _amountError
                          ? const TextStyle(color: AppColors.errorRed)
                          : null,
                      enabledBorder: _amountError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.errorRed, width: 1.5),
                            )
                          : null,
                      focusedBorder: _amountError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.errorRed, width: 2),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Billing cycle compact toggle
                Container(
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkCard : AppColors.chipUnselected,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _cycles.map((cycle) {
                      final sel = _billingCycle == cycle.$1;
                      return GestureDetector(
                        onTap: () => setState(() => _billingCycle = cycle.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.chipSelected
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cycle.$2,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: sel ? Colors.white : context.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Next billing date
            GestureDetector(
              onTap: () async {
                final d = await CuteDateTimePicker.showDatePicker(
                  context: context,
                  initialDate: _nextBillingDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                );
                if (d != null) setState(() => _nextBillingDate = d);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.newPinkLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Next billing: ${DateFormat('MMM d, yyyy').format(_nextBillingDate)}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: context.textPrimary),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: context.textTertiary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Reminder toggle (compact)
            Row(
              children: [
                Text('Remind me',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: context.textPrimary)),
                if (_reminderEnabled) ...[
                  const SizedBox(width: 8),
                  Text(
                    '$_reminderDaysBefore day${_reminderDaysBefore == 1 ? '' : 's'} before',
                    style: TextStyle(fontSize: 12, color: context.accentPink),
                  ),
                ],
                const Spacer(),
                Switch(
                  value: _reminderEnabled,
                  onChanged: (v) => setState(() => _reminderEnabled = v),
                  activeColor: Colors.white,
                  activeTrackColor: context.accentPink,
                  inactiveThumbColor: context.textTertiary,
                  inactiveTrackColor:
                      isDark ? AppColors.darkCard : AppColors.cream,
                ),
              ],
            ),
            if (_reminderEnabled)
              Slider(
                value: _reminderDaysBefore.toDouble(),
                min: 1,
                max: 14,
                divisions: 13,
                activeColor: context.accentPink,
                inactiveColor: context.accentPink.withValues(alpha: 0.2),
                onChanged: (v) =>
                    setState(() => _reminderDaysBefore = v.toInt()),
              ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CuteButton(
                label: 'Add Subscription',
                emoji: '💳',
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
}
