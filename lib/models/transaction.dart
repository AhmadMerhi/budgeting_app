class Transaction {
  final int id;
  final int userId;
  final String type;
  final String category;
  final double amount;
  final String date;
  final String description;

  Transaction(this.id, this.userId, this.type, this.category, this.amount, this.date, this.description);

  @override
  String toString() {
    return 'ID: $id\nUser ID: $userId\nType: $type\nCategory: $category\nAmount: \$$amount\nDate: $date\nDescription: $description';
  }
}
