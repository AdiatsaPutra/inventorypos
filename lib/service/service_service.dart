import 'package:inventorypos/database/db.dart';

class ServiceService {
  // Create a service
  Future<int> createService(Map<String, dynamic> service) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.insert('service', service);
    } catch (e) {
      return 0;
    }
  }

  // Fetch all services without pagination and search
  Future<List<Map<String, dynamic>>> getAllServices() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Fetch all services
      final result = await db.query('service');

      return result;
    } catch (e) {
      return [];
    }
  }

  // Read a single service by ID
  Future<Map<String, dynamic>?> getServiceById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'service',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Update a service
  Future<int> updateService(int id, Map<String, dynamic> service) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'service',
      service,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a service
  Future<int> deleteService(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'service',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
