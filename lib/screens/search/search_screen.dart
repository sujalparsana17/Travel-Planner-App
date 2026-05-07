import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_card.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/expense_provider.dart';
import 'package:intl/intl.dart';
import '../../routes/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _tripSearchController = TextEditingController();
  final _expenseSearchController = TextEditingController();
  
  String? _selectedParticipant;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tripSearchController.addListener(() => setState(() {}));
    _expenseSearchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tripSearchController.dispose();
    _expenseSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Trips'),
              Tab(text: 'Expenses'),
            ],
          ),
        ),
        body: Consumer2<TripProvider, ExpenseProvider>(
          builder: (context, tripProvider, expenseProvider, child) {
            // Trips Filtering
            final tripQuery = _tripSearchController.text.toLowerCase();
            final filteredTrips = tripProvider.trips.where((trip) {
              return trip.name.toLowerCase().contains(tripQuery) ||
                     trip.destination.toLowerCase().contains(tripQuery);
            }).toList();

            // Expenses Filtering (Using current trip participants for dropdown)
            final currentTrip = tripProvider.currentTrip;
            final allExpenses = currentTrip != null 
                ? expenseProvider.getExpensesByTrip(currentTrip.id) 
                : expenseProvider.expenses;
                
            final expenseQuery = _expenseSearchController.text.toLowerCase();
            final filteredExpenses = allExpenses.where((exp) {
              final matchesDesc = exp.description.toLowerCase().contains(expenseQuery);
              final matchesPart = _selectedParticipant == null || _selectedParticipant == 'All' || exp.paidBy == _selectedParticipant;
              final matchesDate = _selectedDate == null || 
                  (exp.date.year == _selectedDate!.year && 
                   exp.date.month == _selectedDate!.month && 
                   exp.date.day == _selectedDate!.day);
              return matchesDesc && matchesPart && matchesDate;
            }).toList();

            final Map<String, String> participantNames = {};
            if (currentTrip != null) {
              for (var p in currentTrip.participants) {
                participantNames[p.id] = p.name;
              }
            }

            return TabBarView(
              children: [
                // Trips Tab
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomTextField(
                        controller: _tripSearchController,
                        label: 'Search Trips',
                        hint: 'Search by name or destination...',
                        prefixIcon: Icons.search,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = filteredTrips[index];
                          return CustomCard(
                            onTap: () {
                              tripProvider.selectTrip(trip);
                              Navigator.pushNamed(context, AppRoutes.dashboard);
                            },
                            child: ListTile(
                              title: Text(trip.name),
                              subtitle: Text(trip.destination),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Expenses Tab
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _expenseSearchController,
                            label: 'Search Expenses',
                            hint: 'Search by description...',
                            prefixIcon: Icons.search,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Participant',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  value: _selectedParticipant,
                                  items: [
                                    const DropdownMenuItem(value: 'All', child: Text('All')),
                                    if (currentTrip != null)
                                      ...currentTrip.participants.map((p) => 
                                        DropdownMenuItem(value: p.id, child: Text(p.name))
                                      )
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedParticipant = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _selectedDate = picked;
                                      });
                                    } else {
                                      setState(() {
                                        _selectedDate = null; // Clear date filter if cancelled
                                      });
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Date',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_selectedDate == null ? 'Any Date' : DateFormat('MMM d').format(_selectedDate!)),
                                        const Icon(Icons.calendar_today, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final exp = filteredExpenses[index];
                          final payerName = participantNames[exp.paidBy] ?? 'Unknown';
                          return CustomCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary),
                              ),
                              title: Text(exp.description),
                              subtitle: Text('Paid by $payerName \n${DateFormat('MMM d, yyyy').format(exp.date)}'),
                              trailing: Text(
                                '\$${exp.amount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
