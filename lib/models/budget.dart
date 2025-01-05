class Budget {
  final int id;
  final int userId;
  final String month;
  final double budgetLimit;

  Budget(this.id, this.userId, this.month, this.budgetLimit);

  @override
  String toString() {
    return 'ID: $id\nUser ID: $userId\nMonth: $month\nBudget Limit: \$$budgetLimit';
  }
}
