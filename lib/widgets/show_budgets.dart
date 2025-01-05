import 'package:flutter/material.dart';
import '../services/budget_service.dart';

class ShowBudgets extends StatelessWidget {
  final Function(BuildContext, int) deleteBudget;

  const ShowBudgets({required this.deleteBudget, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: BudgetService.budgets.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
              ),
            ),
            title: Text(
              'Month: ${BudgetService.budgets[index].month}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              'User ID: ${BudgetService.budgets[index].userId}\nBudget Limit: \$${BudgetService.budgets[index].budgetLimit.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteBudget(context, BudgetService.budgets[index].id),
            ),
          ),
        ),
      ),
    );
  }
}
