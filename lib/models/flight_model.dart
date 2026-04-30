class FlightModel {
  final String id;
  String flightNumber;
  String from;
  String to;
  DateTime departureTime;
  String? gate;
  String? seat;
  String? airline;
  bool reminderSet;

  FlightModel({
    required this.id,
    required this.flightNumber,
    required this.from,
    required this.to,
    required this.departureTime,
    this.gate,
    this.seat,
    this.airline,
    this.reminderSet = true,
  });

  Duration get timeUntilFlight => departureTime.difference(DateTime.now());

  bool get isUpcoming => departureTime.isAfter(DateTime.now());

  Map<String, dynamic> toMap() => {
        'id': id,
        'flightNumber': flightNumber,
        'from': from,
        'to': to,
        'departureTime': departureTime.millisecondsSinceEpoch,
        'gate': gate,
        'seat': seat,
        'airline': airline,
        'reminderSet': reminderSet ? 1 : 0,
      };

  factory FlightModel.fromMap(Map<String, dynamic> m) => FlightModel(
        id: m['id'],
        flightNumber: m['flightNumber'],
        from: m['from'],
        to: m['to'],
        departureTime: DateTime.fromMillisecondsSinceEpoch(m['departureTime']),
        gate: m['gate'],
        seat: m['seat'],
        airline: m['airline'],
        reminderSet: m['reminderSet'] == 1,
      );
}
