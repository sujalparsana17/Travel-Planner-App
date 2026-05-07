import 'package:flutter/material.dart';

import '../../widgets/custom_card.dart';
import '../../routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/expense_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TripProvider, ExpenseProvider>(
      builder: (context, tripProvider, expenseProvider, child) {
        final currentTrip = tripProvider.currentTrip;
        if (currentTrip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Dashboard')),
            body: const Center(child: Text('No trip selected')),
          );
        }

        final expenses = expenseProvider.getExpensesByTrip(currentTrip.id);
        final totalExpenses = expenseProvider.getTotalExpense(currentTrip.id);
        final participantCount = currentTrip.participants.length;
        
        final settlements = expenseProvider.calculateBalances(currentTrip.id, currentTrip.participants);

        final Map<String, String> participantNames = {};
        for (var p in currentTrip.participants) {
          participantNames[p.id] = p.name;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${currentTrip.name} Dashboard'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        title: 'Total Expenses',
                        value: '\$${totalExpenses.toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        title: 'Participants',
                        value: '$participantCount',
                        icon: Icons.people,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Pending Balances',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                CustomCard(
                  child: settlements.isEmpty
                      ? const Text('All balances are settled up!')
                      : Column(
                          children: settlements.map((text) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.payment, size: 16, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      text,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Expense List',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (expenses.isEmpty)
                  const Center(child: Text('No expenses recorded yet.'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final exp = expenses[index];
                      final payerName = participantNames[exp.paidBy] ?? 'Unknown';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.receipt)),
                          title: Text(exp.description),
                          subtitle: Text('Paid by $payerName on ${DateFormat('MMM d').format(exp.date)}'),
                          trailing: Text(
                            '\$${exp.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.expenseEntry);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
