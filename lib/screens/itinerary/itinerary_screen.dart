import 'package:flutter/material.dart';
import '../../widgets/custom_card.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/itinerary_provider.dart';
import '../../models/itinerary.dart';
import 'package:intl/intl.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final _activityController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime? _selectedDate;

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Activity'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _activityController,
                      decoration: const InputDecoration(labelText: 'Activity Name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _timeController,
                      decoration: const InputDecoration(labelText: 'Time (e.g. 10:00 AM)'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Text(_selectedDate == null
                          ? 'Select Date'
                          : DateFormat('MMM d, yyyy').format(_selectedDate!)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final activity = _activityController.text.trim();
                    if (activity.isEmpty || _selectedDate == null) {
                      return;
                    }
                    final currentTrip = Provider.of<TripProvider>(context, listen: false).currentTrip;
                    if (currentTrip == null) return;

                    final newItem = Itinerary(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      tripId: currentTrip.id,
                      activity: activity,
                      date: _selectedDate!,
                      time: _timeController.text.trim().isEmpty ? null : _timeController.text.trim(),
                    );
                    Provider.of<ItineraryProvider>(context, listen: false).addItinerary(newItem);
                    _activityController.clear();
                    _timeController.clear();
                    _selectedDate = null;
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary'),
      ),
      body: Consumer2<TripProvider, ItineraryProvider>(
        builder: (context, tripProvider, itineraryProvider, child) {
          final currentTrip = tripProvider.currentTrip;
          if (currentTrip == null) {
            return const Center(child: Text('No trip selected'));
          }

          final items = itineraryProvider.getItinerariesByTrip(currentTrip.id);

          if (items.isEmpty) {
            return const Center(child: Text('No itinerary added yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return CustomCard(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.time != null)
                          Text(
                            item.time!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d').format(item.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.activity,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
