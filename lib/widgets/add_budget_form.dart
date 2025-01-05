import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';

class AddBudgetForm extends StatefulWidget {
  const AddBudgetForm({super.key});

  @override
  State<AddBudgetForm> createState() => _AddBudgetFormState();
}

class _AddBudgetFormState extends State<AddBudgetForm> {
  final _formKey = GlobalKey<FormState>();
  String _month = '';
  double _budgetLimit = 0.0;

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      Budget newBudget = Budget(
        0,
        userId,
        _month,
        _budgetLimit,
      );

      bool success = await BudgetService.addBudget(newBudget);
      if (success) {
        if (mounted) {
          BudgetService.updateBudgets((_) {
            if (mounted) {
              setState(() {});
            }
          });

          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add budget')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Budget'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Month'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a month' : null,
                onSaved: (value) => _month = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Budget Limit'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final number = double.tryParse(value ?? '');
                  if (number == null || number <= 0) {
                    return 'Please enter a valid budget limit';
                  }
                  return null;
                },
                onSaved: (value) => _budgetLimit = double.parse(value ?? '0'),
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
