import 'package:inventorypos/constant/string_constant.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  DatabaseHelper._internal();

  static const _databaseVersion = 2;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    final databaseFactory = databaseFactoryFfi;

    return await databaseFactory.openDatabase(
      dbName,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_code TEXT NOT NULL,
        date TEXT NOT NULL,
        total REAL NOT NULL
      )
    ''');

    // Create Transaction-Products Table
    await db.execute('''
      CREATE TABLE transaction_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES inventory (id) ON DELETE CASCADE
      )
    ''');

    // Create Users Table for Offline Login
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Create Inventory Table
    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT,
        name TEXT,
        type TEXT,
        price REAL,
        stock INTEGER,
        image_path TEXT
      )
    ''');

    // Create Service Table
    await db.execute('''
      CREATE TABLE service (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT NOT NULL,
      name TEXT NOT NULL,
      device_type TEXT NOT NULL,
      phone TEXT NOT NULL,
      description TEXT,
      status INTEGER,
      price REAL NOT NULL
    )
  ''');

    // Seed initial users for offline login
    await _seedUsers(db);
  }

  Future<void> _seedUsers(Database db) async {
    await db.insert('users', {
      'username': 'sasa',
      'password': 'sasa123456',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}
}
