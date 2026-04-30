import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/flight_model.dart';
import '../database/db_helper.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';

class FlightProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<FlightModel> _flights = [];
  List<FlightModel> get flights => _flights;

  List<FlightModel> get upcoming => _flights.where((f) => f.isUpcoming).toList()
    ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

  List<FlightModel> get past => _flights.where((f) => !f.isUpcoming).toList()
    ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

  Future<void> load() async {
    final rows = await _db.getAll('flights');
    _flights = rows.map(FlightModel.fromMap).toList();

    // Schedule notifications for all upcoming flights
    for (final flight in _flights.where((f) => f.isUpcoming)) {
      await NotificationService().scheduleFlightCountdownNotifications(
        flightId: flight.id,
        flightNumber: flight.flightNumber,
        route: '${flight.from} → ${flight.to}',
        departureTime: flight.departureTime,
      );
    }

    notifyListeners();
  }

  Future<void> add(FlightModel f) async {
    await _db.insert('flights', f.toMap());
    _flights.add(f);

    // Schedule background notifications for this flight
    await NotificationService().scheduleFlightCountdownNotifications(
      flightId: f.id,
      flightNumber: f.flightNumber,
      route: '${f.from} → ${f.to}',
      departureTime: f.departureTime,
    );

    notifyListeners();
    WidgetService.updateFlightWidget(_flights);
  }

  Future<void> remove(String id) async {
    await _db.delete('flights', id);
    _flights.removeWhere((f) => f.id == id);

    // Cancel all scheduled notifications for this flight
    await NotificationService().cancelFlightNotifications(id);

    notifyListeners();
    WidgetService.updateFlightWidget(_flights);
  }

  FlightModel createNew({
    required String flightNumber,
    required String from,
    required String to,
    required DateTime departureTime,
    String? gate,
    String? seat,
    String? airline,
  }) {
    return FlightModel(
      id: const Uuid().v4(),
      flightNumber: flightNumber,
      from: from,
      to: to,
      departureTime: departureTime,
      gate: gate,
      seat: seat,
      airline: airline,
    );
  }

  Future<void> clearAllData() async {
    await _db.clearTable('flights');
    _flights.clear();
    notifyListeners();
  }
}
