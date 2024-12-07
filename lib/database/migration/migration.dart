import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:inventorypos/database/migration/1_add_service_status_column.dart'
    as m1;

typedef MigrationScript = Future<void> Function(Database db);

class Migration {
  final int version;
  final MigrationScript script;

  Migration({required this.version, required this.script});
}

Future<List<Migration>> loadMigrations() async {
  final migrationDirectory = Directory('lib/database/migration');
  final migrations = <Migration>[];

  if (await migrationDirectory.exists()) {
    final files = migrationDirectory.listSync().whereType<File>();
    for (final file in files) {
      final version =
          int.parse(basenameWithoutExtension(file.path).split('_')[0]);
      final migrationScript = await _loadMigrationScript(file);
      migrations.add(Migration(version: version, script: migrationScript));
    }
  }

  migrations.sort((a, b) => a.version.compareTo(b.version));
  return migrations;
}

Future<MigrationScript> _loadMigrationScript(File file) async {
  // Extract the migration version from the filename
  final fileName = basenameWithoutExtension(file.path);
  final version = int.parse(fileName.split('_')[0]);

  // Map versions to their corresponding migration function
  switch (version) {
    case 1:
      return m1.migration;
    default:
      throw Exception('Migration not found for version $version');
  }
}
