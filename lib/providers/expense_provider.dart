import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/participant.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/firebase_service.dart';
import 'dart:math';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> loadExpenses() async {
    final box = Hive.box('expensesBox');
    if (box.isNotEmpty) {
      _expenses = box.values.map((e) => Expense.fromMap(e as Map)).toList();
      notifyListeners();
    }

    try {
      final cloudData = await _firebaseService.fetchExpenses();
      if (cloudData.isNotEmpty) {
        _expenses = cloudData;
        await box.clear();
        for (var item in _expenses) {
          await box.put(item.id, item.toMap());
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Offline mode active: $e");
    }
  }

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

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    notifyListeners();

    final box = Hive.box('expensesBox');
    await box.put(expense.id, expense.toMap());

    try {
      await _firebaseService.uploadExpense(expense);
    } catch (e) {
      debugPrint("Saved locally, sync failed: $e");
      throw Exception("offline");
    }
  }

  Future<void> removeExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();

    final box = Hive.box('expensesBox');
    await box.delete(id);
  }
}
