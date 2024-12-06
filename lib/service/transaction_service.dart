import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TransactionService {
  final String _transactionsTable = 'transactions';
  final String _transactionProductsTable = 'transaction_products';

  Database? _database;

  // Initialize database
  Future<Database> initDb() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;

    _database ??= await databaseFactory.openDatabase('inventory_app.db',
        options: OpenDatabaseOptions(
          version: 2, // Updated version
          onCreate: (db, version) async {
            // Create Transactions Table
            await db.execute('''
              CREATE TABLE $_transactionsTable (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                transaction_code TEXT NOT NULL,
                date TEXT NOT NULL,
                total REAL NOT NULL
              )
            ''');

            // Create Transaction-Products Relationship Table
            await db.execute('''
              CREATE TABLE $_transactionProductsTable (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                transaction_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                quantity INTEGER NOT NULL,
                FOREIGN KEY (transaction_id) REFERENCES $_transactionsTable (id) ON DELETE CASCADE,
                FOREIGN KEY (product_id) REFERENCES inventory (id) ON DELETE CASCADE
              )
            ''');
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2) {
              // Add transaction_code column
              await db.execute('''
                ALTER TABLE $_transactionsTable ADD COLUMN transaction_code TEXT
              ''');

              // Populate transaction_code for existing rows
              final transactions = await db.query(_transactionsTable);
              for (var transaction in transactions) {
                final id = transaction['id'];
                final code = _generateTransactionCode(id as int);
                await db.update(
                  _transactionsTable,
                  {'transaction_code': code},
                  where: 'id = ?',
                  whereArgs: [id],
                );
              }
            }
          },
        ));

    return _database!;
  }

  // Generate a unique transaction code
  String _generateTransactionCode(int id) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TXN-${id.toString().padLeft(4, '0')}-$timestamp';
  }

  // Add a new transaction
  Future<int> addTransaction(
      String date, double total, List<Map<String, dynamic>> products) async {
    try {
      final db = await initDb();
      return await db.transaction((txn) async {
        // Insert into transactions table
        final transactionId = await txn
            .insert(_transactionsTable, {'date': date, 'total': total});

        // Generate and update transaction code
        final transactionCode = _generateTransactionCode(transactionId);
        await txn.update(
          _transactionsTable,
          {'transaction_code': transactionCode},
          where: 'id = ?',
          whereArgs: [transactionId],
        );

        // Insert products into transaction_products table
        for (var product in products) {
          await txn.insert(_transactionProductsTable, {
            'transaction_id': transactionId,
            'product_id': product['id'],
            'quantity': product['count'],
          });
        }

        return transactionId;
      });
    } catch (e) {
      print(e);
      return 0;
    }
  }

  // Get all transactions
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await initDb();
    return await db.query(_transactionsTable);
  }

  // Get transaction details including products
  Future<Map<String, dynamic>?> getTransactionById(int transactionId) async {
    final db = await initDb();

    // Fetch transaction
    final transaction = await db.query(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    if (transaction.isEmpty) return null;

    // Fetch related products
    final products = await db.query(
      _transactionProductsTable,
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );

    return {
      'transaction': transaction.first,
      'products': products,
    };
  }

  // Update a transaction
  Future<int> updateTransaction(
      int transactionId, String date, double total) async {
    final db = await initDb();
    return await db.update(
      _transactionsTable,
      {'date': date, 'total': total},
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }

  // Delete a transaction
  Future<int> deleteTransaction(int transactionId) async {
    final db = await initDb();
    return await db.delete(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }
}
