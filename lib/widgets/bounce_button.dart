import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;

  const BounceButton({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.92,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scaleAnim, child: widget.child),
    );
  }
}

class CuteButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final String? emoji;
  final double? width;
  final bool outlined;

  const CuteButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
    this.emoji,
    this.width,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.chipSelected;
    const textCol = Colors.white;

    return BounceButton(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : bg,
          borderRadius: BorderRadius.circular(20),
          border: outlined ? Border.all(color: bg, width: 2) : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emoji != null) ...[
              // Add shadow to emoji for better visibility
              Stack(
                children: [
                  // Shadow layer
                  Text(
                    emoji!,
                    style: TextStyle(
                      fontSize: 16,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3
                        ..color = context.isDark
                            ? Colors.black.withValues(alpha: 0.8)
                            : Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                  // Main emoji
                  Text(
                    emoji!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: outlined ? bg : textCol,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 2,
                fontFamily: AppFonts.nclGasdrifo,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
