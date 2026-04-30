import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class CuteBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CuteBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem('🏠', 'Home'),
    _NavItem('🌸', 'My Space'),
    _NavItem('⚙️', 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Padding(
      // Float above the bottom edge
      padding: EdgeInsets.fromLTRB(
        60,
        0,
        60,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          // Pill shape
          borderRadius: BorderRadius.circular(50),
          // Frosted fill
          color: isDark
              ? AppColors.darkCard.withValues(alpha: 0.96)
              : Colors.white.withValues(alpha: 0.96),
          // Girly gradient border via gradient + inner white
          border: Border.all(
            color: Colors.transparent,
            width: 0,
          ),
          boxShadow: [
            // Depth shadow
            BoxShadow(
              color: (isDark
                      ? AppColors.darkAccentLavender
                      : AppColors.softLavender)
                  .withValues(alpha: 0.5),
              blurRadius: 12,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _GradientBorderWrapper(
          borderRadius: 50,
          gradient: isDark
              ? const LinearGradient(
                  colors: [
                    Color(0xFF4F415F),
                    Color(0xFF5B4B6F),
                    Color(0xFF6A567E),
                    Color(0xFF5B4B6F),
                    Color(0xFF4F415F),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFFFFB3C6),
                    Color(0xFFE6CCFF),
                    Color(0xFFFFD6E0),
                    Color(0xFFBFEDCA),
                    Color(0xFFFFB3C6),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderWidth: 1.8,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? (isDark
                              ? const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 97, 59, 93),
                                    Color.fromARGB(255, 76, 48, 70),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 255, 243, 243),
                                    Color.fromARGB(255, 255, 213, 223),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ))
                          : null,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: selected ? 23 : 19,
                          ),
                          child: Text(_items[i].emoji),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontFamily: AppFonts.nclGasdrifo,
                            fontSize: 9.5,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? (isDark
                                    ? AppColors.darkAccentPink
                                    : AppColors.roseGold)
                                : (isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.textLight),
                            letterSpacing: 1,
                          ),
                          child: Text(_items[i].label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(
          begin: 0.3,
          end: 0,
          curve: Curves.easeOutBack,
        );
  }
}

// Paints a gradient border around any child using a CustomPainter
class _GradientBorderWrapper extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Gradient gradient;
  final double borderWidth;

  const _GradientBorderWrapper({
    required this.child,
    required this.borderRadius,
    required this.gradient,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientBorderPainter(
        borderRadius: borderRadius,
        gradient: gradient,
        borderWidth: borderWidth,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final Gradient gradient;
  final double borderWidth;

  _GradientBorderPainter({
    required this.borderRadius,
    required this.gradient,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter old) =>
      old.borderRadius != borderRadius || old.borderWidth != borderWidth;
}

class _NavItem {
  final String emoji;
  final String label;
  const _NavItem(this.emoji, this.label);
}
