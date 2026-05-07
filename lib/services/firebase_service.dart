import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';
import '../models/expense.dart';
import '../models/itinerary.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  // Trips
  Future<void> uploadTrip(Trip trip) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('trips')
        .doc(trip.id)
        .set(trip.toMap());
  }

  Future<List<Trip>> fetchTrips() async {
    if (userId == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('trips')
        .get();
    return snapshot.docs.map((doc) => Trip.fromMap(doc.data())).toList();
  }

  // Expenses
  Future<void> uploadExpense(Expense expense) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toMap());
  }

  Future<List<Expense>> fetchExpenses() async {
    if (userId == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();
    return snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
  }

  // Itineraries
  Future<void> uploadItinerary(Itinerary itinerary) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('itineraries')
        .doc(itinerary.id)
        .set(itinerary.toMap());
  }

  Future<List<Itinerary>> fetchItineraries() async {
    if (userId == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('itineraries')
        .get();
    return snapshot.docs.map((doc) => Itinerary.fromMap(doc.data())).toList();
  }
}
