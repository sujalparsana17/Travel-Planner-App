import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/participant.dart';
import 'dart:math';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  List<Expense> getExpensesByTrip(String tripId) {
    return _expenses.where((expense) => expense.tripId == tripId).toList();
  }

  double getTotalExpense(String tripId) {
    return getExpensesByTrip(tripId).fold(0.0, (sum, e) => sum + e.amount);
  }

  List<String> calculateBalances(String tripId, List<Participant> participants) {
    final tripExpenses = getExpensesByTrip(tripId);
    if (participants.isEmpty) return [];

    final total = getTotalExpense(tripId);
    final share = total / participants.length;

    final balances = <String, double>{};
    final names = <String, String>{};
    
    for (var p in participants) {
      balances[p.id] = -share;
      names[p.id] = p.name;
    }

    for (var e in tripExpenses) {
      if (balances.containsKey(e.paidBy)) {
        balances[e.paidBy] = balances[e.paidBy]! + e.amount;
      }
    }

    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];

    balances.forEach((id, balance) {
      if (balance < -0.01) debtors.add(MapEntry(id, balance));
      if (balance > 0.01) creditors.add(MapEntry(id, balance));
    });

    debtors.sort((a, b) => a.value.compareTo(b.value)); // Most negative first
    creditors.sort((a, b) => b.value.compareTo(a.value)); // Most positive first

    final settlements = <String>[];

    int i = 0;
    int j = 0;

    while (i < debtors.length && j < creditors.length) {
      final debtorId = debtors[i].key;
      final creditorId = creditors[j].key;
      
      final amountToSettle = min(-debtors[i].value, creditors[j].value);

      if (amountToSettle > 0.01) {
        settlements.add('${names[debtorId]} owes ${names[creditorId]} \$${amountToSettle.toStringAsFixed(2)}');
      }

      debtors[i] = MapEntry(debtorId, debtors[i].value + amountToSettle);
      creditors[j] = MapEntry(creditorId, creditors[j].value - amountToSettle);

      if (debtors[i].value > -0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return settlements;
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }
}
