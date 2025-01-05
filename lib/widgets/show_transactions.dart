import 'package:flutter/material.dart';
import '../services/transaction_service.dart';

class ShowTransactions extends StatelessWidget {
  final Function(BuildContext, int) deleteTransaction;

  const ShowTransactions({required this.deleteTransaction, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: TransactionService.transactions.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: TransactionService.transactions[index].type == 'Income' ? Colors.greenAccent : Colors.redAccent,
              child: Icon(
                TransactionService.transactions[index].type == 'Income' ? Icons.arrow_downward : Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
            title: Text(
              TransactionService.transactions[index].category,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${TransactionService.transactions[index].description}\n${TransactionService.transactions[index].date}',
              style: const TextStyle(fontSize: 14),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${TransactionService.transactions[index].amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TransactionService.transactions[index].type == 'Income' ? Colors.green : Colors.red,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteTransaction(context, TransactionService.transactions[index].id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
