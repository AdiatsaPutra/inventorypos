import 'dart:convert'; // For base64 encoding
import 'dart:io'; // For file handling
import 'dart:math';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class InventoryService {
  late Database _database;

  Future<void> initDatabase() async {
    sqfliteFfiInit();
    _database = await databaseFactoryFfi.openDatabase(
      'inventory.db',
      options: OpenDatabaseOptions(
        version: 2, // Increment the version to trigger the migration
        onCreate: (db, version) async {
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
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    return await _database.query('inventory');
  }

  Future<int> addProduct(String name, String type, double price, int stock,
      String? imagePath) async {
    final String code = _generateProductCode(name);
    String? base64Image;

    // Convert image to base64 if a path is provided
    if (imagePath != null) {
      base64Image = await _encodeImageToBase64(imagePath);
    }

    return await _database.insert('inventory', {
      'code': code,
      'name': name,
      'type': type,
      'price': price,
      'stock': stock,
      'image_path': base64Image, // Save the base64 encoded image
    });
  }

  Future<int> updateProduct(int id, String name, String type, double price,
      int stock, String? imagePath) async {
    String? base64Image;

    // Convert image to base64 if a path is provided
    if (imagePath != null) {
      base64Image = await _encodeImageToBase64(imagePath);
    }

    return await _database.update(
      'inventory',
      {
        'name': name,
        'type': type,
        'price': price,
        'stock': stock,
        'image_path': base64Image, // Update the base64 encoded image
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    return await _database
        .delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  /// Generates a product code based on the product name.
  String _generateProductCode(String name) {
    final prefix =
        name.toLowerCase().substring(0, 3); // First 3 letters of the name
    final randomNumber =
        Random().nextInt(900000) + 100000; // Generate a 6-digit number
    return '$prefix-$randomNumber';
  }

  /// Encodes an image at the given path to base64 format.
  Future<String?> _encodeImageToBase64(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes(); // Read the image as bytes
      return base64Encode(bytes); // Convert bytes to base64 string
    } catch (e) {
      print("Error encoding image: $e");
      return null; // Return null if there's an error
    }
  }
}