import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/flight_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cute_card.dart';

class FlightCountdownCard extends StatefulWidget {
  final FlightModel flight;
  final int animationDelay;

  const FlightCountdownCard({
    super.key,
    required this.flight,
    this.animationDelay = 0,
  });

  @override
  State<FlightCountdownCard> createState() => _FlightCountdownCardState();
}

class _FlightCountdownCardState extends State<FlightCountdownCard>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration? _timeRemaining;
  bool _isDismissing = false;
  late AnimationController _dismissController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize dismiss animation controller
    _dismissController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeInOut),
    );

    // Initialize countdown display state.
    final now = DateTime.now();
    final timeUntil = widget.flight.departureTime.difference(now);
    _timeRemaining = timeUntil;

    // Start timer that updates every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dismissController.dispose();
    super.dispose();
  }

  void _updateTimeRemaining() {
    if (_isDismissing) return;

    final now = DateTime.now();
    final timeUntil = widget.flight.departureTime.difference(now);

    if (timeUntil.isNegative || timeUntil.inSeconds <= 0) {
      // Flight time reached - show notification and dismiss
      _onFlightTimeReached();
    } else {
      if (mounted) {
        setState(() {
          _timeRemaining = timeUntil;
        });
      }
    }
  }

  Future<void> _onFlightTimeReached() async {
    if (_isDismissing) return;

    setState(() {
      _isDismissing = true;
    });

    await NotificationService().notifyFlightDepartureNow(
      flightId: widget.flight.id,
      flightNumber: widget.flight.flightNumber,
      route: '${widget.flight.from} → ${widget.flight.to}',
    );

    // Cancel timer
    _timer?.cancel();

    // Start dismiss animation
    await _dismissController.forward();
  }

  bool get _shouldShowCountdown {
    if (_timeRemaining == null) return false;
    return _timeRemaining!.inMinutes <
        300; // Show countdown if < 5 hours (299 minutes or less, i.e., 4:59:59)
  }

  String _formatCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatRegularTime(Duration duration) {
    final hours = duration.inHours;
    if (hours < 24) {
      // Within 24 hours - show hours format
      if (hours == 0) {
        final minutes = duration.inMinutes;
        return '${minutes}m';
      }
      return '${hours}h';
    }
    // More than 24 hours - show days
    final days = duration.inDays;
    return '$days days';
  }

  @override
  Widget build(BuildContext context) {
    // Don't render if animation completed
    if (_dismissController.isCompleted) {
      return const SizedBox.shrink();
    }

    if (_timeRemaining == null) {
      return const SizedBox.shrink();
    }

    final showCountdown = _shouldShowCountdown;
    final isUrgent = _timeRemaining!.inMinutes <
        180; // Red alert if < 3 hours (179 minutes or less, i.e., 2:59:59)
    final isDark = context.isDark;

    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _isDismissing
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CuteCard(
                    gradient: isUrgent
                        ? (isDark
                            ? const LinearGradient(
                                colors: [Color(0xFF5C2D2D), Color(0xFF4A2020)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFFFD5D5), Color(0xFFFFB3B3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ))
                        : (isDark
                            ? AppColors.gradientLavenderDark
                            : const LinearGradient(
                                colors: [Color(0xFFE8D5FF), Color(0xFFCDB4F0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: (isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.white.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  isUrgent ? '🚨' : '✈️',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.flight.from} → ${widget.flight.to}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    widget.flight.flightNumber,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (isDark
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.6)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                showCountdown
                                    ? _formatCountdown(_timeRemaining!)
                                    : _formatRegularTime(_timeRemaining!),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isUrgent
                                      ? (isDark
                                          ? const Color(0xFFFF8A8A)
                                          : const Color(0xFFD32F2F))
                                      : context.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (showCountdown) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 1 -
                                  (_timeRemaining!.inSeconds /
                                      18000), // 18000s = 5 hours
                              backgroundColor: (isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.5)),
                              valueColor: AlwaysStoppedAnimation(
                                isUrgent
                                    ? (isDark
                                        ? const Color(0xFFFF8A8A)
                                        : const Color(0xFFD32F2F))
                                    : context.textSecondary,
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isUrgent
                                ? '🚨 URGENT! Get ready NOW!'
                                : '⏰ Countdown started - prepare soon!',
                            style: TextStyle(
                              fontSize: 10,
                              color: isUrgent
                                  ? (isDark
                                      ? const Color(0xFFFF8A8A)
                                      : const Color(0xFFD32F2F))
                                  : context.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                      .animate(
                          delay: Duration(milliseconds: widget.animationDelay))
                      .fadeIn()
                      .slideX(begin: 0.1, end: 0),
                ),
        ),
      ),
    );
  }
}
