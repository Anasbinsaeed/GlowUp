import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/flight_provider.dart';
import '../models/flight_model.dart';
import '../widgets/cute_card.dart';
import '../widgets/bounce_button.dart';
import '../widgets/section_header.dart';
import '../widgets/cute_date_time_picker.dart';
import 'flight_detail_screen.dart';

class FlightScreen extends StatelessWidget {
  const FlightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.gradientBackground),
        child: SafeArea(
          child: Column(
            children: [
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
                              color: context.isDark
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
                    Expanded(
                      child: SectionHeader(
                        title: 'Flights',
                        emoji: '✈️',
                        actionLabel: 'Add',
                        onAction: () => _showAddSheet(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<FlightProvider>(
                  builder: (_, prov, __) {
                    if (prov.flights.isEmpty) return _emptyState(context);
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      children: [
                        if (prov.upcoming.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              '✈️ Upcoming Flights',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: context.textSecondary),
                            ),
                          ),
                          ...prov.upcoming.asMap().entries.map((e) =>
                              _BoardingPassCard(flight: e.value, index: e.key)),
                        ],
                        if (prov.past.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 12),
                            child: Text(
                              '🕐 Past Flights',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: context.textSecondary),
                            ),
                          ),
                          ...prov.past.take(3).toList().asMap().entries.map(
                              (e) => _BoardingPassCard(
                                  flight: e.value, index: e.key, isPast: true)),
                        ],
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
          const Text('✈️', style: TextStyle(fontSize: 64))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1500.ms,
              ),
          const SizedBox(height: 16),
          Text(
            'No flights yet bestie ✈️\nWhere are we going?!',
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
      builder: (_) => const _AddFlightSheet(),
    );
  }
}

class _BoardingPassCard extends StatelessWidget {
  final FlightModel flight;
  final int index;
  final bool isPast;

  const _BoardingPassCard({
    required this.flight,
    required this.index,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    final diff = flight.timeUntilFlight;
    final daysLeft = diff.inDays;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FlightDetailScreen(flight: flight),
          ),
        ),
        child: CuteCard(
          gradient: isPast
              ? null
              : (context.isDark
                  ? AppColors.gradientLavenderDark
                  : const LinearGradient(
                      colors: [Color(0xFFEDD9FF), Color(0xFFD4B8E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )),
          color: isPast
              ? (context.isDark ? AppColors.darkCard : AppColors.cream)
              : null,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.from,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: isPast
                                ? context.textTertiary
                                : context.textPrimary,
                          ),
                        ),
                        Text(
                          'From',
                          style: TextStyle(
                              fontSize: 11,
                              color: isPast
                                  ? context.textTertiary
                                  : context.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Text('✈️', style: TextStyle(fontSize: 24)),
                      Container(
                        width: 80,
                        height: 1,
                        color: context.textTertiary.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          flight.to,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: isPast
                                ? context.textTertiary
                                : context.textPrimary,
                          ),
                        ),
                        Text(
                          'To',
                          style: TextStyle(
                              fontSize: 11,
                              color: isPast
                                  ? context.textTertiary
                                  : context.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: context.textTertiary.withValues(alpha: 0.2),
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                      label: 'Flight',
                      value: flight.flightNumber,
                      isPast: isPast),
                  const SizedBox(width: 8),
                  _InfoChip(
                      label: 'Date',
                      value: DateFormat('MMM d').format(flight.departureTime),
                      isPast: isPast),
                  const SizedBox(width: 8),
                  _InfoChip(
                      label: 'Time',
                      value: DateFormat('h:mm a').format(flight.departureTime),
                      isPast: isPast),
                  const Spacer(),
                  if (!isPast)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: daysLeft == 0
                            ? AppColors.errorRed.withValues(alpha: 0.2)
                            : (context.isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        daysLeft == 0
                            ? 'TODAY 😱'
                            : daysLeft == 1
                                ? 'Tomorrow!'
                                : '$daysLeft days',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: daysLeft == 0
                              ? AppColors.errorRed
                              : context.textPrimary,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        context.read<FlightProvider>().remove(flight.id),
                    child: Icon(Icons.delete_outline,
                        size: 18, color: context.textTertiary),
                  ),
                ],
              ),
              if (flight.seat != null || flight.gate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (flight.gate != null)
                      _InfoChip(
                          label: 'Gate', value: flight.gate!, isPast: isPast),
                    if (flight.gate != null) const SizedBox(width: 8),
                    if (flight.seat != null)
                      _InfoChip(
                          label: 'Seat', value: flight.seat!, isPast: isPast),
                  ],
                ),
              ],
            ],
          ),
        ).animate(delay: Duration(milliseconds: 80 * index)).fadeIn().slideY(
              begin: 0.1,
              end: 0,
            ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isPast;

  const _InfoChip(
      {required this.label, required this.value, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPast
            ? context.textTertiary.withValues(alpha: 0.1)
            : (context.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 9, color: context.textTertiary),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: isPast ? context.textTertiary : context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFlightSheet extends StatefulWidget {
  const _AddFlightSheet();

  @override
  State<_AddFlightSheet> createState() => _AddFlightSheetState();
}

class _AddFlightSheetState extends State<_AddFlightSheet> {
  final _flightNumCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _gateCtrl = TextEditingController();
  final _seatCtrl = TextEditingController();
  final _airlineCtrl = TextEditingController();
  DateTime _departureTime = DateTime.now().add(const Duration(days: 7));
  bool _fromError = false;
  bool _toError = false;
  bool _flightNumberError = false;

  @override
  void dispose() {
    _flightNumCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _gateCtrl.dispose();
    _seatCtrl.dispose();
    _airlineCtrl.dispose();
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
              'Add Flight ✈️',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fromCtrl,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_fromError) setState(() => _fromError = false);
                    },
                    decoration: InputDecoration(
                      hintText:
                          _fromError ? 'From is required ⚠️' : 'From 🛫 *',
                      hintStyle: _fromError
                          ? const TextStyle(color: AppColors.errorRed)
                          : null,
                      enabledBorder: _fromError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.errorRed, width: 1.5))
                          : null,
                      focusedBorder: _fromError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.errorRed, width: 2))
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('→',
                      style: TextStyle(
                          fontSize: 20, color: context.textSecondary)),
                ),
                Expanded(
                  child: TextField(
                    controller: _toCtrl,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_toError) setState(() => _toError = false);
                    },
                    decoration: InputDecoration(
                      hintText: _toError ? 'To is required ⚠️' : 'To 🛬 *',
                      hintStyle: _toError
                          ? const TextStyle(color: AppColors.errorRed)
                          : null,
                      enabledBorder: _toError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.errorRed, width: 1.5))
                          : null,
                      focusedBorder: _toError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.errorRed, width: 2))
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _flightNumCtrl,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_flightNumberError) {
                  setState(() => _flightNumberError = false);
                }
              },
              decoration: InputDecoration(
                hintText: _flightNumberError
                    ? 'Flight number is required ⚠️'
                    : 'Flight number (e.g. EK123) *',
                hintStyle: _flightNumberError
                    ? const TextStyle(color: AppColors.errorRed)
                    : null,
                enabledBorder: _flightNumberError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.errorRed, width: 1.5))
                    : null,
                focusedBorder: _flightNumberError
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.errorRed, width: 2))
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _airlineCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Airline (optional)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _gateCtrl,
                    textInputAction: TextInputAction.next,
                    decoration:
                        const InputDecoration(hintText: 'Gate (optional)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _seatCtrl,
                    textInputAction: TextInputAction.done,
                    decoration:
                        const InputDecoration(hintText: 'Seat (optional)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final dateTime = await CuteDateTimePicker.showDateTimePicker(
                  context: context,
                  initialDateTime: _departureTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (dateTime != null && mounted) {
                  setState(() {
                    _departureTime = dateTime;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? AppColors.darkCard
                      : AppColors.newPinkLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(_departureTime),
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: context.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CuteButton(
                label: 'Save Flight',
                emoji: '✈️',
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
    bool hasError = false;
    if (_fromCtrl.text.trim().isEmpty) {
      _fromError = true;
      hasError = true;
    }
    if (_toCtrl.text.trim().isEmpty) {
      _toError = true;
      hasError = true;
    }
    if (_flightNumCtrl.text.trim().isEmpty) {
      _flightNumberError = true;
      hasError = true;
    }
    if (hasError) {
      setState(() {});
      return;
    }

    final flight = context.read<FlightProvider>().createNew(
          flightNumber: _flightNumCtrl.text.trim().toUpperCase(),
          from: _fromCtrl.text.trim().toUpperCase(),
          to: _toCtrl.text.trim().toUpperCase(),
          departureTime: _departureTime,
          gate: _gateCtrl.text.trim().isEmpty ? null : _gateCtrl.text.trim(),
          seat: _seatCtrl.text.trim().isEmpty ? null : _seatCtrl.text.trim(),
          airline: _airlineCtrl.text.trim().isEmpty
              ? null
              : _airlineCtrl.text.trim(),
        );
    context.read<FlightProvider>().add(flight);
    Navigator.pop(context);
  }
}
