import 'dart:math';
import 'dart:io'; // For file handling
import 'package:inventorypos/constant/string_constant.dart';
import 'package:inventorypos/database/db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class InventoryService {
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('inventory');
  }

  Future<int> addProduct(String name, String type, double price, int stock,
      String? imagePath, double initialPrice) async {
    final db = await DatabaseHelper.instance.database;
    final String code = _generateProductCode(name);

    return await db.insert('inventory', {
      'code': code,
      'name': name,
      'type': type,
      'price': price,
      'stock': stock,
      'image_path': imagePath, // Save the image file path
      'initial_price': initialPrice, // Save the initial price
    });
  }

  Future<int> updateProduct(int id, String name, String type, double price,
      int stock, String? imagePath, double initialPrice) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'inventory',
      {
        'name': name,
        'type': type,
        'price': price,
        'stock': stock,
        'image_path': imagePath, // Update the image file path
        'initial_price': initialPrice, // Update the initial price
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  /// Generates a product code based on the product name.
  String _generateProductCode(String name) {
    final prefix =
        name.toLowerCase().substring(0, 3); // First 3 letters of the name
    final randomNumber =
        Random().nextInt(900000) + 100000; // Generate a 6-digit number
    return '$prefix-$randomNumber';
  }
}
