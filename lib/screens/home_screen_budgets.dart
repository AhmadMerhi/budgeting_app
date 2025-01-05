import 'package:flutter/material.dart';
import '../widgets/show_budgets.dart';
import '../widgets/add_budget_form.dart';
import '../services/budget_service.dart';

class HomeScreenBudgets extends StatefulWidget {
  const HomeScreenBudgets({super.key});

  @override
  State<HomeScreenBudgets> createState() => _HomeScreenBudgetsState();
}

class _HomeScreenBudgetsState extends State<HomeScreenBudgets> {
  String _message = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() {
    setState(() {
      _loading = true;
      _message = 'Loading Budgets...';
    });
    BudgetService.updateBudgets((success) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = success ? 'Budgets loaded!' : 'Failed to load budgets';
      });
    });
  }

  void _openAddBudgetForm() {
    showDialog(
      context: context,
      builder: (context) => const AddBudgetForm(),
    ).then((_) => _loadBudgets());
  }

  void _deleteBudget(BuildContext context, int id) async {
    bool success = await BudgetService.deleteBudgetById(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted budget ID $id')));
      _loadBudgets();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete budget')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ShowBudgets(deleteBudget: _deleteBudget),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddBudgetForm,
        child: const Icon(Icons.add),
        tooltip: 'Add Budget',
      ),
    );
  }
}
