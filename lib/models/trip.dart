import 'participant.dart';

class Trip {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<Participant> participants;

  Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.participants,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participants': participants.map((x) => x.toMap()).toList(),
    };
  }

  factory Trip.fromMap(Map<dynamic, dynamic> map) {
    return Trip(
      id: map['id'] as String,
      name: map['name'] as String,
      destination: map['destination'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      participants: List<Participant>.from(
        (map['participants'] as List).map<Participant>(
          (x) => Participant.fromMap(x as Map<dynamic, dynamic>),
        ),
      ),
    );
  }
}
