import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import '../models/transaction.dart';

class TransactionService {
  static const String _baseURL = 'testingforproject.mooo.com';
  static const String _transactionsAPI = '/transactions.php';
  static List<Transaction> transactions = [];

 static void updateTransactions(Function(bool success) update) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    final url = Uri.http(_baseURL, _transactionsAPI, {'user_id': '$userId'});
    final response = await http.get(url).timeout(const Duration(seconds: 5));

    transactions.clear();

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      debugPrint('Server response: ${response.body}');

      if (jsonResponse['success'] == true) {
        for (var row in jsonResponse['data']) {
          transactions.add(Transaction(
            int.parse(row['id'] ?? '0'),
            int.parse(row['user_id'] ?? '0'),
            row['type'] ?? '',
            row['category'] ?? '',
            double.parse(row['amount'] ?? '0.0'),
            row['date'] ?? '',
            row['description'] ?? '',
          ));
        }
        update(true);
      } else {
        debugPrint('Error in response: ${jsonResponse['error']}');
        update(false);
      }
    } else {
      debugPrint('Failed to fetch transactions. Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      update(false);
    }
  } catch (e) {
    debugPrint('Error fetching transactions: $e');
    update(false);
  }
}


  static Future<bool> addTransaction(Transaction transaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      final url = Uri.http(_baseURL, _transactionsAPI);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode({
          'user_id': userId,
          'type': transaction.type,
          'category': transaction.category,
          'amount': transaction.amount.toString(),
          'date': transaction.date,
          'description': transaction.description,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return true;
        } else {
          debugPrint('Error adding transaction: ${jsonResponse['error']}');
          return false;
        }
      } else {
        debugPrint('Failed to add transaction. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }
static Future<bool> deleteTransactionById(int id) async {
  try {
    final url = Uri.http(_baseURL, _transactionsAPI, {'id': '$id'});
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        return true;
      } else {
        debugPrint('Error deleting transaction: ${jsonResponse['error']}');
        return false;
      }
    } else {
      debugPrint('Failed to delete transaction. Status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    debugPrint('Error deleting transaction: $e');
    return false;
  }
}

}
