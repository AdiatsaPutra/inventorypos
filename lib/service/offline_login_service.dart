import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class OfflineLoginService {
  OfflineLoginService() {
    // Initialize sqflite_common_ffi
    sqfliteFfiInit();
  }

  Future<Database> getDatabase() async {
    // Use the ffi database factory
    final databaseFactory = databaseFactoryFfi;
    return databaseFactory.openDatabase(
      'inventorypos.db',
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, password TEXT)',
          );
          // Seed the database
          await seedDatabase(db);
        },
      ),
    );
  }

  Future<void> seedDatabase(Database db) async {
    await db.insert('users', {
      'username': 'sasa',
      'password': 'sasa123456',
    });
  }

  Future<bool> login(String username, String password) async {
    final db = await getDatabase();
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  // Future<void> syncWithOnline(OnlineLoginService onlineService) async {
  //   final db = await getDatabase();
  //   final localUsers = await db.query('users');

  //   for (var user in localUsers) {
  //     await onlineService.syncUser(user['username'], user['password']);
  //   }
  // }
}
