import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import '../models/budget.dart';

class BudgetService {
  static const String _baseURL = 'testingforproject.mooo.com';
  static const String _budgetsAPI = '/budgets.php';

  static List<Budget> budgets = [];

  static void updateBudgets(Function(bool success) update) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      final url = Uri.http(_baseURL, _budgetsAPI, {'user_id': '$userId'});
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      budgets.clear();

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);
        debugPrint('Server response: ${response.body}');

        if (jsonResponse['success'] == true) {
          for (var row in jsonResponse['data']) {
            budgets.add(Budget(
              int.parse(row['id'] ?? '0'),
              int.parse(row['user_id'] ?? '0'),
              row['month'] ?? '',
              double.parse(row['budget_limit'] ?? '0.0'),
            ));
          }
          update(true);
        } else {
          debugPrint('Error in response: ${jsonResponse['error']}');
          update(false);
        }
      } else {
        debugPrint('Failed to fetch budgets. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        update(false);
      }
    } catch (e) {
      debugPrint('Error fetching budgets: $e');
      update(false);
    }
  }

  static Future<bool> addBudget(Budget budget) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      final url = Uri.http(_baseURL, _budgetsAPI);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode({
          'user_id': userId,
          'month': budget.month,
          'budget_limit': budget.budgetLimit.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          debugPrint('Budget added successfully');
          return true;
        } else {
          debugPrint('Error adding budget: ${jsonResponse['error']}');
          return false;
        }
      } else {
        debugPrint('Failed to add budget. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding budget: $e');
      return false;
    }
  }

 static Future<bool> deleteBudgetById(int id) async {
  try {
    final url = Uri.http(_baseURL, _budgetsAPI, {'id': '$id'});
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        return true;
      } else {
        debugPrint('Error deleting budget: ${jsonResponse['error']}');
        return false;
      }
    } else {
      debugPrint('Failed to delete budget. Status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    debugPrint('Error deleting budget: $e');
    return false;
  }
}

}
