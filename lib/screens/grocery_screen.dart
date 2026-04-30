import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/grocery_provider.dart';
import '../models/grocery_item_model.dart';
import '../widgets/cute_card.dart';
import '../widgets/bounce_button.dart';
import '../widgets/section_header.dart';
import '../widgets/cute_back_button.dart';

class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                        title: 'Grocery List',
                        emoji: '🛒',
                        actionLabel: 'Add',
                        onAction: () => _showAddSheet(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer<GroceryProvider>(
                  builder: (_, prov, __) {
                    if (prov.items.isEmpty) return _emptyState(context);
                    return CustomScrollView(
                      slivers: [
                        if (prov.unchecked.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                              child: Text(
                                '${prov.unchecked.length} items to grab 🛍️',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: context.textSecondary),
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => _GroceryTile(
                                item: prov.unchecked[i],
                                index: i,
                              ),
                              childCount: prov.unchecked.length,
                            ),
                          ),
                        ],
                        if (prov.checked.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                              child: Row(
                                children: [
                                  Text(
                                    '✅ Got it (${prov.checked.length})',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: context.textSecondary),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: prov.clearChecked,
                                    child: Text(
                                      'Clear all',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: context.accentPink,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => _GroceryTile(
                                item: prov.checked[i],
                                index: i,
                              ),
                              childCount: prov.checked.length,
                            ),
                          ),
                        ],
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
          const Text('🛒', style: TextStyle(fontSize: 64))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 1500.ms,
              ),
          const SizedBox(height: 16),
          Text(
            'Cart is empty bestie 🥺\nAdd some items!',
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
      builder: (_) => const _AddGrocerySheet(),
    );
  }
}

class _GroceryTile extends StatelessWidget {
  final GroceryItem item;
  final int index;

  const _GroceryTile({required this.item, required this.index});

  static const _catColors = {
    'fruits': Color(0xFFFFE0E6),
    'veggies': Color(0xFFDFF5E1),
    'snacks': Color(0xFFFFEDD5),
    'dairy': Color(0xFFE8F4FF),
    'protein': Color(0xFFFFE8D5),
    'drinks': Color(0xFFE8E0FF),
    'bakery': Color(0xFFFFF3D5),
    'grains': Color(0xFFFFF0D5),
    'frozen': Color(0xFFE0F5FF),
    'canned': Color(0xFFFFE8E0),
    'spices': Color(0xFFFFE5D5),
    'sweets': Color(0xFFFFE0F5),
    'seafood': Color(0xFFE0F0FF),
    'condiments': Color(0xFFFFF5E0),
    'pasta': Color(0xFFFFF8E0),
    'cereal': Color(0xFFFFEFD5),
    'oils': Color(0xFFFFF5D5),
    'herbs': Color(0xFFE5FFE5),
    'nuts': Color(0xFFFFEAD5),
    'baby': Color(0xFFFFE8F0),
    'pet': Color(0xFFFFE8E8),
    'cleaning': Color(0xFFE0F5F5),
    'personal': Color(0xFFE8E8FF),
    'other': Color(0xFFF5F5F5),
  };

  static const _catColorsDark = {
    'fruits': Color(0xFF4A2D3D),
    'veggies': Color(0xFF2D4A3D),
    'snacks': Color(0xFF4A3D2D),
    'dairy': Color(0xFF2D3D4A),
    'protein': Color(0xFF4A3A2D),
    'drinks': Color(0xFF3D2D4A),
    'bakery': Color(0xFF4A4A2D),
    'grains': Color(0xFF4A4A2D),
    'frozen': Color(0xFF2D3D4A),
    'canned': Color(0xFF4A2D2D),
    'spices': Color(0xFF4A3D2D),
    'sweets': Color(0xFF4A2D4A),
    'seafood': Color(0xFF2D3D4A),
    'condiments': Color(0xFF4A4A2D),
    'pasta': Color(0xFF4A4A2D),
    'cereal': Color(0xFF4A3D2D),
    'oils': Color(0xFF4A4A2D),
    'herbs': Color(0xFF2D4A2D),
    'nuts': Color(0xFF4A3A2D),
    'baby': Color(0xFF4A2D3D),
    'pet': Color(0xFF4A2D2D),
    'cleaning': Color(0xFF2D4A4A),
    'personal': Color(0xFF3D3D4A),
    'other': Color(0xFF3A3A3A),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colorMap = isDark ? _catColorsDark : _catColors;
    final color = colorMap[item.category] ??
        (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5));
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      child: BounceButton(
        onTap: () => context.read<GroceryProvider>().toggle(item.id),
        child: CuteCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.isChecked
                      ? AppColors.successGreen.withValues(alpha: 0.2)
                      : color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    item.isChecked ? '✅' : item.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: item.isChecked
                            ? context.textTertiary
                            : context.textPrimary,
                        decoration:
                            item.isChecked ? TextDecoration.lineThrough : null,
                        decorationColor: context.textTertiary,
                      ),
                      child: Text(item.name),
                    ),
                    Text(
                      '${item.category} • qty: ${item.quantity}',
                      style:
                          TextStyle(fontSize: 11, color: context.textTertiary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.read<GroceryProvider>().remove(item.id),
                child: Icon(Icons.close, size: 18, color: context.textTertiary),
              ),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().slideX(
            begin: 0.1,
            end: 0,
          ),
    );
  }
}

class _AddGrocerySheet extends StatefulWidget {
  const _AddGrocerySheet();

  @override
  State<_AddGrocerySheet> createState() => _AddGrocerySheetState();
}

class _AddGrocerySheetState extends State<_AddGrocerySheet> {
  final _nameCtrl = TextEditingController();
  bool _nameError = false;
  String _category = 'other';
  int _qty = 1;

  static const _categories = [
    ('fruits', '🍓', 'Fruits'),
    ('veggies', '🥦', 'Veggies'),
    ('snacks', '🍿', 'Snacks'),
    ('dairy', '🥛', 'Dairy'),
    ('protein', '🍗', 'Protein'),
    ('drinks', '🧃', 'Drinks'),
    ('bakery', '🥐', 'Bakery'),
    ('grains', '🌾', 'Grains'),
    ('frozen', '🧊', 'Frozen'),
    ('canned', '🥫', 'Canned'),
    ('spices', '🧂', 'Spices'),
    ('sweets', '🍬', 'Sweets'),
    ('seafood', '🦐', 'Seafood'),
    ('condiments', '🍯', 'Condiments'),
    ('pasta', '🍝', 'Pasta'),
    ('cereal', '🥣', 'Cereal'),
    ('oils', '🫒', 'Oils'),
    ('herbs', '🌿', 'Herbs'),
    ('nuts', '🥜', 'Nuts'),
    ('baby', '🍼', 'Baby Food'),
    ('pet', '🐾', 'Pet Food'),
    ('cleaning', '🧹', 'Cleaning'),
    ('personal', '🧴', 'Personal Care'),
    ('other', '🛒', 'Other'),
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
            Text(
              'Add to Cart 🛒',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_nameError) setState(() => _nameError = false);
              },
              decoration: InputDecoration(
                hintText: _nameError
                    ? 'Item name is required ⚠️'
                    : 'What do you need? 🥺',
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
            Text('Category',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: context.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final sel = _category == cat.$1;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.chipSelected
                          : (context.isDark
                              ? AppColors.darkCard
                              : AppColors.chipUnselected),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${cat.$2} ${cat.$3}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : context.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Quantity',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: context.textPrimary)),
                const Spacer(),
                _QtyButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (_qty > 1) setState(() => _qty--);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$_qty',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: context.textPrimary),
                  ),
                ),
                _QtyButton(
                  icon: Icons.add,
                  onTap: () => setState(() => _qty++),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CuteButton(
                label: 'Add to List',
                emoji: '🛒',
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
    final item = context.read<GroceryProvider>().createNew(
          name: _nameCtrl.text.trim(),
          category: _category,
          quantity: _qty,
        );
    context.read<GroceryProvider>().add(item);
    Navigator.pop(context);
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.accentPink.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: context.accentPink),
      ),
    );
  }
}
