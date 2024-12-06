import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:inventorypos/service/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();
  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  Map<String, dynamic>? _transactionDetails;
  bool _isLoading = false;
  String _errorMessage = '';

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  List<Map<String, dynamic>> get transactions => _filteredTransactions;
  Map<String, dynamic>? get transactionDetails => _transactionDetails;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;

  TransactionProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      _isLoading = true;
      notifyListeners();

      _allTransactions = await _service.getAllTransactions();
      _filteredTransactions =
          List.from(_allTransactions); // Initialize with all transactions
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<String> fetchTransactionDetails(int transactionId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _transactionDetails = await _service.getTransactionById(transactionId);
      _isLoading = false;
      notifyListeners();
      return 'success';
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String> addTransaction({
    required double total,
    required List<Map<String, dynamic>> products,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.addTransaction(DateTime.now().toString(), total, products);
      await fetchTransactions(); // Refresh data
      _isLoading = false;
      notifyListeners();

      return 'success';
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return 'Failed to add transaction: $_errorMessage';
    }
  }

  Future<String> updateTransaction(
      int transactionId, String date, double total) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.updateTransaction(transactionId, date, total);
      await fetchTransactions(); // Refresh data
      _isLoading = false;
      notifyListeners();

      return 'success';
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return 'Failed to update transaction: $_errorMessage';
    }
  }

  Future<String> deleteTransaction(int transactionId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.deleteTransaction(transactionId);
      await fetchTransactions(); // Refresh data
      _isLoading = false;
      notifyListeners();

      return 'success';
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return 'Failed to delete transaction: $_errorMessage';
    }
  }

  // Pagination logic
  int get totalPages {
    return (_filteredTransactions.length / _itemsPerPage).ceil();
  }

  List<Map<String, dynamic>> get paginatedTransactions {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex =
        (_currentPage * _itemsPerPage) > _filteredTransactions.length
            ? _filteredTransactions.length
            : (_currentPage * _itemsPerPage);
    return _filteredTransactions.sublist(startIndex, endIndex);
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

  // Search logic
  void filterTransactions(String query) {
    if (query.isEmpty) {
      _filteredTransactions = List.from(_allTransactions);
    } else {
      _filteredTransactions = _allTransactions.where((transaction) {
        final id = transaction['id'].toString();
        final product = transaction['product'].toString().toLowerCase();
        final lowerQuery = query.toLowerCase();

        return id.contains(lowerQuery) || product.contains(lowerQuery);
      }).toList();
    }
    _currentPage = 1; // Reset to the first page after a search
    notifyListeners();
  }
}
