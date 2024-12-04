import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class OfflineLoginService {
  Future<Database> getDatabase({bool inMemory = false}) async {
    sqfliteFfiInit();
    final databaseFactory = databaseFactoryFfi;

    return databaseFactory.openDatabase(
      inMemory ? inMemoryDatabasePath : 'inventorypos.db',
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) {
          db.execute(
            'CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, password TEXT)',
          );
        },
      ),
    );
  }

  Future<bool> login(String username, String password, {Database? db}) async {
    db ??= await getDatabase();
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }
}

void main() {
  late OfflineLoginService service;

  setUp(() {
    service = OfflineLoginService();
  });

  test('Login with valid credentials should return true', () async {
    final db = await service.getDatabase(inMemory: true);

    // Insert test data
    await db.insert('users', {'username': 'testuser', 'password': 'testpass'});

    // Test login
    final result = await service.login('testuser', 'testpass', db: db);
    expect(result, true);
  });

  test('Login with invalid credentials should return false', () async {
    final db = await service.getDatabase(inMemory: true);

    // Insert test data
    await db.insert('users', {'username': 'testuser', 'password': 'testpass'});

    // Test login
    final result = await service.login('testuser', 'wrongpass', db: db);
    expect(result, false);
  });

  test('Login with non-existent user should return false', () async {
    final db = await service.getDatabase(inMemory: true);

    // Test login
    final result = await service.login('nonexistent', 'testpass', db: db);
    expect(result, false);
  });
}
