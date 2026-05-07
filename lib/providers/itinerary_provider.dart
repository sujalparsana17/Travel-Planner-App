import 'package:flutter/foundation.dart';
import '../models/itinerary.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/firebase_service.dart';

class ItineraryProvider with ChangeNotifier {
  List<Itinerary> _itineraries = [];
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> loadItineraries() async {
    final box = Hive.box('itinerariesBox');
    if (box.isNotEmpty) {
      _itineraries = box.values.map((e) => Itinerary.fromMap(e as Map)).toList();
      notifyListeners();
    }

    try {
      final cloudData = await _firebaseService.fetchItineraries();
      if (cloudData.isNotEmpty) {
        _itineraries = cloudData;
        await box.clear();
        for (var item in _itineraries) {
          await box.put(item.id, item.toMap());
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Offline mode active: $e");
    }
  }

  List<Itinerary> get itineraries => _itineraries;

  List<Itinerary> getItinerariesByTrip(String tripId) {
    return _itineraries.where((item) => item.tripId == tripId).toList();
  }

  Future<void> addItinerary(Itinerary itinerary) async {
    _itineraries.add(itinerary);
    _itineraries.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();

    final box = Hive.box('itinerariesBox');
    await box.put(itinerary.id, itinerary.toMap());

    try {
      await _firebaseService.uploadItinerary(itinerary);
    } catch (e) {
      debugPrint("Saved locally, sync failed: $e");
      throw Exception("offline");
    }
  }

  Future<void> removeItinerary(String id) async {
    _itineraries.removeWhere((item) => item.id == id);
    notifyListeners();

    final box = Hive.box('itinerariesBox');
    await box.delete(id);
  }
}
