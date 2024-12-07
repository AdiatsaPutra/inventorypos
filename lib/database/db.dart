import 'package:inventorypos/constant/string_constant.dart';
import 'package:inventorypos/database/migration/migration.dart';
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
          onConfigure: _onConfigure),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Transactions Table
    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transaction_code TEXT,
      date TEXT,
      total REAL,
      discount REAL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''');

    // Create Transaction-Products Table
    await db.execute('''
    CREATE TABLE transaction_products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transaction_id INTEGER,
      product_id INTEGER,
      quantity INTEGER,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES inventory (id) ON DELETE CASCADE
    )
  ''');

    // Create Users Table for Offline Login
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY,
      username TEXT,
      password TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''');

    // Create Inventory Table
    await db.execute('''
    CREATE TABLE inventory (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT,
      name TEXT,
      type TEXT,
      initial_price REAL,
      price REAL,
      stock INTEGER,
      image_path TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''');

    // Create Service Table
    await db.execute('''
    CREATE TABLE service (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT,
      name TEXT,
      device_type TEXT,
      phone TEXT,
      description TEXT,
      status INTEGER,
      price REAL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final migrations = await loadMigrations();
    for (final migration in migrations) {
      if (migration.version > oldVersion && migration.version <= newVersion) {
        await migration.script(db);
      }
    }
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
}
