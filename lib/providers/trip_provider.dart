import 'package:flutter/foundation.dart';
import '../models/trip.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/firebase_service.dart';

class TripProvider with ChangeNotifier {
  List<Trip> _trips = [];
  Trip? _currentTrip;
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> loadTrips() async {
    final box = Hive.box('tripsBox');
    if (box.isNotEmpty) {
      _trips = box.values.map((e) => Trip.fromMap(e as Map)).toList();
      notifyListeners();
    }

    try {
      final cloudTrips = await _firebaseService.fetchTrips();
      if (cloudTrips.isNotEmpty) {
        _trips = cloudTrips;
        await box.clear();
        for (var trip in _trips) {
          await box.put(trip.id, trip.toMap());
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Offline mode active: $e");
    }
  }
  List<Trip> get trips => _trips;
  Trip? get currentTrip => _currentTrip;

  void selectTrip(Trip trip) {
    _currentTrip = trip;
    notifyListeners();
  }

  Future<void> addTrip(Trip trip) async {
    _trips.add(trip);
    notifyListeners();

    final box = Hive.box('tripsBox');
    await box.put(trip.id, trip.toMap());

    try {
      await _firebaseService.uploadTrip(trip);
    } catch (e) {
      debugPrint("Saved locally, sync failed: $e");
      throw Exception("offline");
    }
  }

  Future<void> removeTrip(String id) async {
    _trips.removeWhere((trip) => trip.id == id);
    notifyListeners();

    final box = Hive.box('tripsBox');
    await box.delete(id);
    // Note: Cloud deletion would be added to FirebaseService if needed
  }
}
