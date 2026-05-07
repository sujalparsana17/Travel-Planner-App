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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'activity': activity,
      'date': date.toIso8601String(),
      'time': time,
    };
  }

  factory Itinerary.fromMap(Map<dynamic, dynamic> map) {
    return Itinerary(
      id: map['id'] as String,
      tripId: map['tripId'] as String,
      activity: map['activity'] as String,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String?,
    );
  }
}
