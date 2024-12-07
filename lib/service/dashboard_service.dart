import 'package:inventorypos/constant/string_constant.dart';
import 'package:inventorypos/database/db.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DashboardService {
  final String _transactionsTable = 'transactions';
  final String _transactionProductsTable = 'transaction_products';

  Future<double> getTotalOfThisMonthTransactions() async {
    final db = await DatabaseHelper.instance.database;
    print('THIS');

    // Get the first and last days of the current month
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final lastDayOfMonth =
        DateTime(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String();

    // Query to calculate the total sum for the current month
    final result = await db.rawQuery(
      '''
    SELECT SUM(total) as total_sum 
    FROM $_transactionsTable 
    WHERE created_at BETWEEN ? AND ?
    ''',
      [firstDayOfMonth, lastDayOfMonth],
    );

    // Extract the total sum from the result
    if (result.isNotEmpty && result.first['total_sum'] != null) {
      return result.first['total_sum'] as double;
    }

    // Return 0 if no transactions or if the result is null
    return 0.0;
  }

  Future<Map<String, dynamic>?> getMostSoldProduct() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Query to get the most sold product
      final result = await db.rawQuery('''
    SELECT p.id, p.name, p.price, p.image_path, SUM(tp.quantity) as total_sold
    FROM $_transactionProductsTable tp
    INNER JOIN inventory p ON tp.product_id = p.id
    GROUP BY p.id, p.name, p.price, p.image_path
    ORDER BY total_sold DESC
    LIMIT 1
  ''');
      print(result);

      // Return the most sold product or null if no data
      if (result.isNotEmpty) {
        return result.first;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<int> getTotalProductsSold() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Query to calculate the total sum of quantities for non-deleted products
      final result = await db.rawQuery('''
    SELECT SUM(tp.quantity) as total_products_sold
    FROM $_transactionProductsTable tp
    INNER JOIN inventory p ON tp.product_id = p.id
  ''');

      // Extract the total sum from the result
      if (result.isNotEmpty && result.first['total_products_sold'] != null) {
        return result.first['total_products_sold'] as int;
      }

      // Return 0 if no products sold
      return 0;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyTransactionSummary() async {
    final db = await DatabaseHelper.instance.database;

    // Get the current date
    final now = DateTime.now();

    // Calculate the start of the week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekFormatted =
        DateFormat('yyyy-MM-dd').format(startOfWeek); // Format date to string.
    final startOfWeekData = DateFormat('dd MMMM yyyy', 'id')
        .format(startOfWeek); // Format date to string.

    // Calculate the end of the week (Sunday)
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    final endOfWeekFormatted =
        DateFormat('yyyy-MM-dd').format(endOfWeek); // Format date to string.
    final endOfWeekData = DateFormat('dd MMMM yyyy', 'id')
        .format(endOfWeek); // Format date to string.

    // Query to get transactions within the week range
    final transactions = await db.rawQuery('''
      SELECT 
        t.id AS transaction_id,
        t.date,
        t.total,
        tp.product_id,
        p.name AS product_name,
        SUM(tp.quantity) AS total_quantity
      FROM $_transactionsTable t
      INNER JOIN $_transactionProductsTable tp ON t.id = tp.transaction_id
      INNER JOIN inventory p ON tp.product_id = p.id
      WHERE t.date BETWEEN ? AND ?
      GROUP BY tp.product_id
      ORDER BY t.date ASC
    ''', [startOfWeekFormatted, endOfWeekFormatted]);

    // Calculate weekly totals
    final totalWeeklyTransactions = await db.rawQuery('''
      SELECT 
        COUNT(id) AS total_transactions, 
        SUM(total) AS total_amount 
      FROM $_transactionsTable
      WHERE date BETWEEN ? AND ?
    ''', [startOfWeekFormatted, endOfWeekFormatted]);

    // Combine data into a summary list
    return [
      {
        'start_of_week': startOfWeekData,
        'end_of_week': endOfWeekData,
        'total_transactions':
            totalWeeklyTransactions.first['total_transactions'] ?? 0,
        'total_amount': totalWeeklyTransactions.first['total_amount'] ?? 0.0,
        'products': transactions
      }
    ];
  }
}
