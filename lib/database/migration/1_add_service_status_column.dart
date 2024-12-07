import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> migration(Database db) async {
  await db.execute('''
    ALTER TABLE transactions ADD COLUMN status INTEGER DEFAULT 0
  ''');
}
