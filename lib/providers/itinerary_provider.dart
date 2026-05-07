import 'package:flutter/foundation.dart';
import '../models/itinerary.dart';

class ItineraryProvider with ChangeNotifier {
  final List<Itinerary> _itineraries = [];

  List<Itinerary> get itineraries => _itineraries;

  List<Itinerary> getItinerariesByTrip(String tripId) {
    return _itineraries.where((item) => item.tripId == tripId).toList();
  }

  void addItinerary(Itinerary itinerary) {
    _itineraries.add(itinerary);
    // Sort by date/time
    _itineraries.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  void removeItinerary(String id) {
    _itineraries.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
