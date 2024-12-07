import 'package:inventorypos/constant/string_constant.dart';
import 'package:inventorypos/database/db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TransactionService {
  final String _transactionsTable = 'transactions';
  final String _transactionProductsTable = 'transaction_products';

  // Generate a unique transaction code
  String _generateTransactionCode(int id) {
    final timestamp = DateTime.now();
    return 'SASA-${id.toString().padLeft(4, '0')}-${timestamp.hour}${timestamp.minute}${timestamp.day}${timestamp.month}${timestamp.year}';
  }

  // Add a new transaction
  Future<String> addTransaction(String date, double total, double discount,
      List<Map<String, dynamic>> products) async {
    try {
      print(products);
      final db = await DatabaseHelper.instance.database;
      return await db.transaction((txn) async {
        // Insert into transactions table
        final transactionId = await txn.insert(_transactionsTable, {
          'transaction_code': 'SASA-',
          'date': date,
          'total': total,
          'discount': discount,
        });

        // Generate and update transaction code
        final transactionCode = _generateTransactionCode(transactionId);
        await txn.update(
          _transactionsTable,
          {'transaction_code': transactionCode},
          where: 'id = ?',
          whereArgs: [transactionId],
        );

        // Insert products into transaction_products table and update inventory stock
        for (var product in products) {
          final productId = product['id'];
          final quantity = product['count'];

          // Insert product into transaction_products table
          await txn.insert(_transactionProductsTable, {
            'transaction_id': transactionId,
            'product_id': productId,
            'quantity': quantity,
          });

          // Update stock in the inventory table
          await txn.rawUpdate(
            'UPDATE inventory SET stock = stock - ? WHERE id = ?',
            [quantity, productId],
          );
        }

        return transactionId.toString();
      });
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  // Get all transactions
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(_transactionsTable);
  }

  // Get transaction details including detailed product information
  Future<Map<String, dynamic>?> getTransactionById(int transactionId) async {
    final db = await DatabaseHelper.instance.database;

    // Fetch transaction details
    final transaction = await db.query(
      _transactionsTable,
      columns: [
        'id',
        'transaction_code',
        'date',
        'total',
        'discount'
      ], // Include specific fields
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    if (transaction.isEmpty) return null;

    // Fetch related products with detailed information
    final products = await db.rawQuery('''
    SELECT tp.*, p.name, p.price, p.image_path
    FROM $_transactionProductsTable tp
    INNER JOIN inventory p ON tp.product_id = p.id
    WHERE tp.transaction_id = ?
  ''', [transactionId]);

    return {
      'transaction': transaction.first,
      'products': products,
    };
  }

  // Update a transaction
  Future<int> updateTransaction(
      int transactionId, String date, double total) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      _transactionsTable,
      {'date': date, 'total': total},
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }

  // Delete a transaction
  Future<int> deleteTransaction(int transactionId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }
}
