import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class CuteAlertDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String emoji;
  final Widget? content;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool isConfirmEnabled;

  const CuteAlertDialog({
    super.key,
    required this.title,
    this.message,
    this.emoji = '🌸',
    this.content,
    required this.confirmText,
    this.cancelText,
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.isConfirmEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final confirmColor =
        isDestructive ? AppColors.errorRed : context.accentPink;
    final titleColor = isDestructive ? AppColors.errorRed : context.textPrimary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.gradientLavenderDark
              : AppColors.gradientNewPink,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: (isDestructive ? AppColors.errorRed : context.accentPink)
                .withValues(alpha: 0.35),
            width: 1.4,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color:
                          (isDark ? AppColors.darkCardElevated : Colors.white)
                              .withValues(alpha: 0.72),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.heading(
                        fontSize: 22,
                        color: titleColor,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message!,
                  style: AppTextStyles.body(
                    fontSize: 14,
                    color: context.textSecondary,
                  ),
                ),
              ],
              if (content != null) ...[
                const SizedBox(height: 16),
                content!,
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  if (cancelText != null) ...[
                    Expanded(
                      child: TextButton(
                        onPressed:
                            onCancel ?? () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          cancelText!,
                          style: AppTextStyles.button(
                              color: context.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isConfirmEnabled ? onConfirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor:
                            isDark ? AppColors.darkBackground : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(confirmText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 220.ms, curve: Curves.easeOutCubic).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
            duration: 260.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}

Future<T?> showCuteAlertDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (ctx) {
      // showDialog rebuilds on MediaQuery changes (keyboard open/close)
      final mq = MediaQuery.of(ctx);
      final keyboardHeight = mq.viewInsets.bottom;
      final navHeight = mq.padding.bottom + 68 + 16;
      final bottomPad = keyboardHeight > 0 ? keyboardHeight + 16.0 : navHeight;

      return AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.fromLTRB(16, mq.padding.top + 16, 16, bottomPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: builder(ctx),
            ),
          ],
        ),
      );
    },
  );
}
