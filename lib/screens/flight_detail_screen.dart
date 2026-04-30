import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/flight_model.dart';
import '../providers/flight_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cute_card.dart';

class FlightDetailScreen extends StatefulWidget {
  final FlightModel flight;

  const FlightDetailScreen({super.key, required this.flight});

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _timeRemaining = widget.flight.departureTime.difference(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isUrgent =>
      _timeRemaining.inMinutes < 180 && !_timeRemaining.isNegative;
  bool get _isCountdown =>
      _timeRemaining.inMinutes < 300 && !_timeRemaining.isNegative;
  bool get _isDeparted => _timeRemaining.isNegative;

  String get _countdownText {
    if (_isDeparted) return 'Departed ✈️';
    final h = _timeRemaining.inHours;
    final m = _timeRemaining.inMinutes.remainder(60);
    final s = _timeRemaining.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final flight = widget.flight;

    final headerGradient = _isDeparted
        ? (isDark
            ? AppColors.gradientLavenderDark
            : const LinearGradient(
                colors: [Color(0xFFE0E0E0), Color(0xFFCCCCCC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ))
        : _isUrgent
            ? (isDark
                ? const LinearGradient(
                    colors: [Color(0xFF5C2D2D), Color(0xFF4A2020)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : const LinearGradient(
                    colors: [Color(0xFFFFD5D5), Color(0xFFFFB3B3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight))
            : (isDark
                ? AppColors.gradientLavenderDark
                : const LinearGradient(
                    colors: [Color(0xFFEDD9FF), Color(0xFFD4B8E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight));

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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? AppColors.darkShadow
                                  : AppColors.shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 16, color: context.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Flight Details ✈️',
                      style: AppTextStyles.heading(
                          fontSize: 22, color: context.textPrimary),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        context.read<FlightProvider>().remove(flight.id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.errorRed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Boarding pass style card
                      CuteCard(
                        gradient: headerGradient,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            // Route
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          flight.from,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            color: _isDeparted
                                                ? context.textTertiary
                                                : context.textPrimary,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        Text(
                                          'From',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: context.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        _isDeparted ? '🛬' : '✈️',
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                      Container(
                                        width: 60,
                                        height: 1,
                                        color: context.textTertiary
                                            .withValues(alpha: 0.3),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          flight.to,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            color: _isDeparted
                                                ? context.textTertiary
                                                : context.textPrimary,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        Text(
                                          'To',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: context.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Countdown / Status
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _isDeparted
                                        ? 'Flight Departed'
                                        : _isCountdown
                                            ? (_isUrgent
                                                ? '🚨 URGENT'
                                                : '⏰ Countdown')
                                            : '🗓️ Scheduled',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _countdownText,
                                    style: TextStyle(
                                      fontSize: _isCountdown ? 32 : 22,
                                      fontWeight: FontWeight.w900,
                                      color: _isUrgent
                                          ? (isDark
                                              ? const Color(0xFFFF8A8A)
                                              : const Color(0xFFD32F2F))
                                          : _isDeparted
                                              ? context.textTertiary
                                              : context.textPrimary,
                                    ),
                                  ),
                                  if (_isCountdown && !_isDeparted) ...[
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: (1 -
                                                  (_timeRemaining.inSeconds /
                                                      18000))
                                              .clamp(0.0, 1.0),
                                          backgroundColor: isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.1)
                                              : Colors.white
                                                  .withValues(alpha: 0.5),
                                          valueColor: AlwaysStoppedAnimation(
                                            _isUrgent
                                                ? (isDark
                                                    ? const Color(0xFFFF8A8A)
                                                    : const Color(0xFFD32F2F))
                                                : context.accentPink,
                                          ),
                                          minHeight: 8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 16),

                      // Flight info grid
                      CuteCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📋 Flight Info',
                              style: AppTextStyles.heading(
                                  fontSize: 16, color: context.textPrimary),
                            ),
                            const SizedBox(height: 16),
                            _infoGrid(context, flight),
                          ],
                        ),
                      )
                          .animate(delay: 100.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 16),

                      // Departure details
                      CuteCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🕐 Departure Details',
                              style: AppTextStyles.heading(
                                  fontSize: 16, color: context.textPrimary),
                            ),
                            const SizedBox(height: 16),
                            _detailRow(
                                context,
                                '📅 Date',
                                DateFormat('EEEE, MMMM d, yyyy')
                                    .format(flight.departureTime)),
                            _detailRow(
                                context,
                                '⏰ Time',
                                DateFormat('h:mm a')
                                    .format(flight.departureTime)),
                            if (flight.gate != null)
                              _detailRow(context, '🚪 Gate', flight.gate!),
                            if (flight.seat != null)
                              _detailRow(context, '💺 Seat', flight.seat!),
                            if (flight.airline != null)
                              _detailRow(
                                  context, '🏢 Airline', flight.airline!),
                          ],
                        ),
                      )
                          .animate(delay: 150.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 16),

                      // Milestone notifications
                      if (!_isDeparted)
                        CuteCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🔔 Notification Milestones',
                                style: AppTextStyles.heading(
                                    fontSize: 16, color: context.textPrimary),
                              ),
                              const SizedBox(height: 16),
                              _milestoneRow(
                                context,
                                '5 hours before',
                                flight.departureTime
                                    .subtract(const Duration(hours: 5)),
                                _timeRemaining.inHours >= 5,
                              ),
                              _milestoneRow(
                                context,
                                '3 hours before',
                                flight.departureTime
                                    .subtract(const Duration(hours: 3)),
                                _timeRemaining.inHours >= 3,
                              ),
                              _milestoneRow(
                                context,
                                '1 hour before',
                                flight.departureTime
                                    .subtract(const Duration(hours: 1)),
                                _timeRemaining.inHours >= 1,
                              ),
                              _milestoneRow(
                                context,
                                'Departure',
                                flight.departureTime,
                                !_isDeparted,
                              ),
                            ],
                          ),
                        )
                            .animate(delay: 200.ms)
                            .fadeIn()
                            .slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoGrid(BuildContext context, FlightModel flight) {
    return Row(
      children: [
        Expanded(
            child: _infoCell(context, '✈️ Flight No.', flight.flightNumber)),
        const SizedBox(width: 12),
        Expanded(child: _infoCell(context, '🛫 From', flight.from)),
        const SizedBox(width: 12),
        Expanded(child: _infoCell(context, '🛬 To', flight.to)),
      ],
    );
  }

  Widget _infoCell(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.darkCardElevated
            : AppColors.newPinkLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: context.textTertiary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: context.textPrimary,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _milestoneRow(
      BuildContext context, String label, DateTime time, bool upcoming) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: upcoming
                  ? context.accentPink.withValues(alpha: 0.15)
                  : AppColors.successGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                upcoming ? '⏳' : '✅',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: upcoming ? context.textPrimary : context.textTertiary,
              ),
            ),
          ),
          Text(
            DateFormat('MMM d, h:mm a').format(time),
            style: TextStyle(
              fontSize: 12,
              color: upcoming ? context.accentPink : context.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
