class Participant {
  final String id;
  final String name;

  Participant({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Participant.fromMap(Map<dynamic, dynamic> map) {
    return Participant(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}
