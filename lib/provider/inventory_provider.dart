import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inventorypos/service/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _service = InventoryService();
  List<Map<String, dynamic>> _inventory = [];
  List<Map<String, dynamic>> _filteredInventory = [];
  bool _isLoading = false;
  String _errorMessage = '';
  File? _selectedImage;

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  List<Map<String, dynamic>> get filteredInventory => _filteredInventory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;
  int get currentPage => _currentPage;

  InventoryProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      _inventory = await _service.getAllProducts();
      _filteredInventory = _inventory;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<File?> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        _selectedImage = File(result.files.single.path!);
        print(_selectedImage);
        notifyListeners();
        return _selectedImage;
      } else {
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error picking image: $e';
      notifyListeners();
      return null;
    }
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<String> addProduct(
      String name, String type, double price, int stock) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.addProduct(
          name, type, price, stock, _selectedImage?.path ?? '');
      await fetchProducts();
      _isLoading = false;
      notifyListeners();

      return 'success';
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      print(_errorMessage);
      notifyListeners();
      return 'Failed to add product: $_errorMessage';
    }
  }

  Future<String> updateProduct(
      int id, String name, String type, double price, int stock) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.updateProduct(
          id, name, type, price, stock, _selectedImage?.path ?? '');
      await fetchProducts();
      _isLoading = false;
      notifyListeners();

      return 'success';
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return 'Failed to update product: $_errorMessage';
    }
  }

  Future<String> deleteProduct(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.deleteProduct(id);
      await fetchProducts();
      _isLoading = false;
      notifyListeners();

      return 'success';
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return 'Failed to delete product: $_errorMessage';
    }
  }

  void searchInventory(String query) {
    if (query.isEmpty) {
      _filteredInventory = _inventory;
    } else {
      _filteredInventory = _inventory.where((product) {
        return product['code'].toLowerCase().contains(query.toLowerCase()) ||
            product['name'].toLowerCase().contains(query.toLowerCase()) ||
            product['type'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // Pagination logic
  int get totalPages {
    return (_filteredInventory.length / _itemsPerPage).ceil();
  }

  List<Map<String, dynamic>> get paginatedInventory {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage) > _filteredInventory.length
        ? _filteredInventory.length
        : (_currentPage * _itemsPerPage);
    return _filteredInventory.sublist(startIndex, endIndex);
  }

  void setCurrentPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }
}
