class Expense {
  final String id;
  final String tripId;
  final double amount;
  final String description;
  final String paidBy; // Participant ID
  final DateTime date;

  Expense({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.description,
    required this.paidBy,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'amount': amount,
      'description': description,
      'paidBy': paidBy,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<dynamic, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      tripId: map['tripId'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      paidBy: map['paidBy'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
