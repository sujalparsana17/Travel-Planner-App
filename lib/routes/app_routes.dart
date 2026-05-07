import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/trip/create_trip_screen.dart';
import '../screens/itinerary/itinerary_screen.dart';
import '../screens/expense/expense_entry_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/search/search_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String createTrip = '/create-trip';
  static const String itinerary = '/itinerary';
  static const String expenseEntry = '/expense-entry';
  static const String dashboard = '/dashboard';
  static const String search = '/search';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case createTrip:
        return MaterialPageRoute(builder: (_) => const CreateTripScreen());
      case itinerary:
        return MaterialPageRoute(builder: (_) => const ItineraryScreen());
      case expenseEntry:
        return MaterialPageRoute(builder: (_) => const ExpenseEntryScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
