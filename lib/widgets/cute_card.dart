import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CuteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Color? color;
  final double borderRadius;
  final VoidCallback? onTap;
  final double elevation;

  const CuteCard({
    super.key,
    required this.child,
    this.padding,
    this.gradient,
    this.color,
    this.borderRadius = 24,
    this.onTap,
    this.elevation = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null
              ? (color ?? (isDark ? AppColors.darkCard : AppColors.cardWhite))
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.shadowColor,
              blurRadius: elevation,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
