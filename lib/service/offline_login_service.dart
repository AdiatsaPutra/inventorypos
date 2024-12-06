import 'package:inventorypos/constant/string_constant.dart';
import 'package:inventorypos/database/db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class OfflineLoginService {
  Future<bool> login(String username, String password) async {
    // Get the database instance by awaiting the future
    final db = await DatabaseHelper.instance.database;

    // Now you can use the 'db' instance to call the 'query' method
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
