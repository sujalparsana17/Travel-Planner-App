import 'package:flutter/foundation.dart';
import '../models/trip.dart';

class TripProvider with ChangeNotifier {
  final List<Trip> _trips = [];
  Trip? _currentTrip;

  List<Trip> get trips => _trips;
  Trip? get currentTrip => _currentTrip;

  void selectTrip(Trip trip) {
    _currentTrip = trip;
    notifyListeners();
  }

  void addTrip(Trip trip) {
    _trips.add(trip);
    notifyListeners();
  }

  void removeTrip(String id) {
    _trips.removeWhere((trip) => trip.id == id);
    notifyListeners();
  }
}
