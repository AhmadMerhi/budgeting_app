import 'package:flutter/material.dart';
import '../widgets/show_transactions.dart';
import '../widgets/add_transaction_form.dart';
import '../services/transaction_service.dart';

class HomeScreenTransactions extends StatefulWidget {
  const HomeScreenTransactions({super.key});

  @override
  State<HomeScreenTransactions> createState() => _HomeScreenTransactionsState();
}

class _HomeScreenTransactionsState extends State<HomeScreenTransactions> {
  String _message = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _loading = true;
      _message = 'Loading Transactions...';
    });
    TransactionService.updateTransactions((success) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = success ? 'Transactions loaded!' : 'Failed to load transactions';
      });
    });
  }

  void _openAddTransactionForm() {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionForm(),
    ).then((_) => _loadTransactions());
  }

  void _deleteTransaction(BuildContext context, int id) async {
    bool success = await TransactionService.deleteTransactionById(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted transaction ID $id')));
      _loadTransactions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete transaction')));
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
                : ShowTransactions(deleteTransaction: _deleteTransaction),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionForm,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}
