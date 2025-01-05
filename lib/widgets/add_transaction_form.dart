import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class AddTransactionForm extends StatefulWidget {
  const AddTransactionForm({super.key});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Expense';
  String _category = '';
  double _amount = 0.0;
  DateTime? _selectedDate;
  String _description = '';

  void _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    _formKey.currentState?.save();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    Transaction newTransaction = Transaction(
      0, 
      userId, 
      _type,
      _category,
      _amount,
      _selectedDate?.toIso8601String() ?? '',
      _description,
    );

    bool success = await TransactionService.addTransaction(newTransaction);
    if (success) {
      if (mounted) {
        TransactionService.updateTransactions((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add transaction')),
        );
      }
    }
  }
}


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transaction'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'Income', child: Text('Income')),
                  DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                ],
                onChanged: (value) => setState(() {
                  _type = value ?? 'Expense';
                }),
                onSaved: (value) => _type = value ?? 'Expense',
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a category' : null,
                onSaved: (value) => _category = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final number = double.tryParse(value ?? '');
                  if (number == null || number <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value ?? '0'),
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      hintText: _selectedDate != null 
                          ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" 
                          : 'Select date',
                    ),
                    validator: (value) => (_selectedDate == null) ? 'Please select a date' : null,
                  ),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
