import 'package:flutter/material.dart';
import 'package:inventorypos/model/result.dart';
import 'package:inventorypos/service/service_service.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceService _serviceService = ServiceService();

  ServiceProvider() {
    fetchAllServicesFromDB();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _allServices = []; // Full list of services
  List<Map<String, dynamic>> _services = []; // Filtered and paginated list
  List<Map<String, dynamic>> get services => _services;

  // Pagination variables
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  // Search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Controller for search field
  final TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;

  // Fetch all services from the database
  Future<void> fetchAllServicesFromDB() async {
    _setLoading(true);
    try {
      _allServices = List<Map<String, dynamic>>.from(
          await _serviceService.getAllServices());
      _applyFilters();
    } catch (e) {
      _allServices = [];
      _services = [];
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filteredServices =
        List<Map<String, dynamic>>.from(_allServices);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredServices = filteredServices
          .where((service) => service.values.any((value) => value
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase())))
          .toList();
    }

    // Apply pagination
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    _services = List<Map<String, dynamic>>.from(filteredServices.sublist(
      startIndex,
      endIndex > filteredServices.length ? filteredServices.length : endIndex,
    ));
  }

  // Handle search action
  void onSearch(String query) {
    _searchQuery = query.trim();
    _currentPage = 1; // Reset to first page
    _applyFilters();
    notifyListeners();
  }

  // Handle pagination action
  void onPagination(int page) {
    _currentPage = page;
    _applyFilters();
    notifyListeners();
  }

  // Create a service
  Future<Result> createService(Map<String, dynamic> service) async {
    _setLoading(true);
    try {
      await _serviceService.createService(service);
      _allServices.add(service); // Add to local list
      _applyFilters();
      return Result(isSuccess: true, message: 'Service created successfully');
    } catch (e) {
      return Result(isSuccess: false, message: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get service by ID
  Future<Result> getServiceById(int id) async {
    try {
      final service = _allServices.firstWhere((service) => service['id'] == id);
      return Result(isSuccess: true, message: 'Service fetched successfully');
    } catch (e) {
      return Result(isSuccess: false, message: e.toString());
    }
  }

  // Update service
  Future<Result> updateService(int id, Map<String, dynamic> service) async {
    _setLoading(true);
    try {
      await _serviceService.updateService(id, service);
      final index = _allServices.indexWhere((s) => s['id'] == id);
      if (index != -1) {
        _allServices[index] = service; // Update local list
        _applyFilters();
      }
      return Result(isSuccess: true, message: 'Service updated successfully');
    } catch (e) {
      return Result(isSuccess: false, message: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Delete service
  Future<Result> deleteService(int id) async {
    _setLoading(true);
    try {
      await _serviceService.deleteService(id);
      _allServices.removeWhere(
          (service) => service['id'] == id); // Remove from local list
      _applyFilters();
      return Result(isSuccess: true, message: 'Berhasil menghapus service');
    } catch (e) {
      return Result(isSuccess: false, message: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
