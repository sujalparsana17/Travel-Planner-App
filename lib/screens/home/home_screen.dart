import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_card.dart';

import '../../providers/expense_provider.dart';
import '../../providers/itinerary_provider.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false).loadTrips();
      Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
      Provider.of<ItineraryProvider>(context, listen: false).loadItineraries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Travel Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.dashboard);
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              }
            },
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          final trips = tripProvider.trips;
          
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_travel, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No trips created yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create one!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              final startDateStr = DateFormat('MMM d, yyyy').format(trip.startDate);
              final endDateStr = DateFormat('MMM d, yyyy').format(trip.endDate);

              return CustomCard(
                onTap: () {
                  tripProvider.selectTrip(trip);
                  Navigator.pushNamed(context, AppRoutes.dashboard);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            trip.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.people, size: 16, color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 4),
                              Text(
                                '${trip.participants.length}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          trip.destination,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '$startDateStr - $endDateStr',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createTrip);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
