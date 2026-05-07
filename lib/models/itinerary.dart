class Itinerary {
  final String id;
  final String tripId;
  final String activity;
  final DateTime date;
  final String? time;

  Itinerary({
    required this.id,
    required this.tripId,
    required this.activity,
    required this.date,
    this.time,
  });
}
