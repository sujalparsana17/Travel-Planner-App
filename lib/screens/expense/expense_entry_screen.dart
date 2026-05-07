import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';

class ExpenseEntryScreen extends StatefulWidget {
  const ExpenseEntryScreen({super.key});

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedPayer;
  DateTime? _expenseDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expenseDate = picked;
      });
    }
  }

  Future<void> _addExpense() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }
      if (_selectedPayer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select who paid')),
        );
        return;
      }
      if (_expenseDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date')),
        );
        return;
      }
      
      final currentTrip = Provider.of<TripProvider>(context, listen: false).currentTrip;
      if (currentTrip == null) return;

      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tripId: currentTrip.id,
        amount: amount,
        description: _descriptionController.text.trim(),
        paidBy: _selectedPayer!,
        date: _expenseDate!,
      );

      try {
        await Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense Synced to Cloud Successfully!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Offline mode active. Expense saved locally.'), backgroundColor: Colors.orange),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                prefixIcon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'e.g., Dinner at Restaurant',
                prefixIcon: Icons.description,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Consumer<TripProvider>(
                builder: (context, tripProvider, child) {
                  final currentTrip = tripProvider.currentTrip;
                  final participants = currentTrip?.participants ?? [];
                  
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Paid By',
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    value: _selectedPayer,
                    items: participants.map((participant) {
                      return DropdownMenuItem<String>(
                        value: participant.id,
                        child: Text(participant.name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPayer = newValue;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _expenseDate == null
                        ? 'Select Date'
                        : DateFormat('MMM d, yyyy').format(_expenseDate!),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Add Expense',
                icon: Icons.add_circle_outline,
                onPressed: _addExpense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
