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
}
