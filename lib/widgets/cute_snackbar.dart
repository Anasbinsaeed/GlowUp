import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CuteSnackbar {
  static OverlayEntry? _current;
  static Timer? _timer;
  static final GlobalKey<_CuteSnackbarWidgetState> _key = GlobalKey();

  static void show(
    BuildContext context, {
    required String message,
    String? emoji,
    Duration duration = const Duration(seconds: 3),
    bool isError = false,
  }) {
    // Animate out existing snackbar first, then show new one
    _dismissWithAnimation(() => _showNew(
          context,
          message: message,
          emoji: emoji ?? (isError ? '😬' : '✨'),
          isError: isError,
          duration: duration,
        ));
  }

  static void _showNew(
    BuildContext context, {
    required String message,
    required String emoji,
    required bool isError,
    required Duration duration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _CuteSnackbarWidget(
        key: _key,
        message: message,
        emoji: emoji,
        isError: isError,
        onRemove: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);

    // Auto-dismiss after duration
    _timer?.cancel();
    _timer = Timer(duration, () => _dismissWithAnimation(null));
  }

  static void _dismissWithAnimation(VoidCallback? onComplete) {
    _timer?.cancel();
    _timer = null;

    final state = _key.currentState;
    if (state != null && state.mounted) {
      // Let the widget animate out, then remove
      state._animateOut().then((_) {
        _current?.remove();
        _current = null;
        onComplete?.call();
      });
    } else {
      _current?.remove();
      _current = null;
      onComplete?.call();
    }
  }
}

class _CuteSnackbarWidget extends StatefulWidget {
  final String message;
  final String emoji;
  final bool isError;
  final VoidCallback onRemove;

  const _CuteSnackbarWidget({
    super.key,
    required this.message,
    required this.emoji,
    required this.isError,
    required this.onRemove,
  });

  @override
  State<_CuteSnackbarWidget> createState() => _CuteSnackbarWidgetState();
}

class _CuteSnackbarWidgetState extends State<_CuteSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 280),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateOut() async {
    if (_controller.isAnimating) await _controller.forward();
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomOffset = MediaQuery.of(context).padding.bottom + 68 + 16 + 12;

    return Positioned(
      left: 24,
      right: 24,
      bottom: bottomOffset,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            onTap: () => _animateOut().then((_) => widget.onRemove()),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isError
                      ? (isDark
                          ? const Color(0xFF4A1A1A)
                          : const Color(0xFFFFE8E8))
                      : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isError
                        ? AppColors.errorRed.withValues(alpha: 0.4)
                        : (isDark
                            ? AppColors.darkAccentPink.withValues(alpha: 0.4)
                            : AppColors.babyPink),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark
                              ? AppColors.darkAccentPink
                              : AppColors.softLavender)
                          .withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(widget.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          fontFamily: AppFonts.nclGasdrifo,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: widget.isError
                              ? AppColors.errorRed
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textLight,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
