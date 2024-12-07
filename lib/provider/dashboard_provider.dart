import 'package:flutter/material.dart';
import 'package:inventorypos/model/result.dart';
import 'package:inventorypos/service/dashboard_service.dart';
import 'package:inventorypos/service/transaction_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardProvider = DashboardService();

  DashboardProvider() {
    fetchTotalOfAllTransactions();
    fetchMostSoldProduct();
    fetchTotalProductsSold();
    fetchWeeklyProductsSold();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double? _totalOfAllTransactions;
  double? get totalOfAllTransactions => _totalOfAllTransactions;

  Map<String, dynamic>? _mostSoldProduct;
  Map<String, dynamic>? get mostSoldProduct => _mostSoldProduct;

  int? _totalProductsSold;
  int? get totalProductsSold => _totalProductsSold;

  List<Map<String, dynamic>> _weeklyProdutSold = [
    {
      "start_of_week": "2024-12-04",
      "end_of_week": "2024-12-10",
      "total_transactions": 5,
      "total_amount": 1234.56,
      "products": [
        {
          "transaction_id": 1,
          "date": "2024-12-04",
          "total": 300.50,
          "product_id": 101,
          "product_name": "Product A",
          "total_quantity": 10
        },
        {
          "transaction_id": 2,
          "date": "2024-12-05",
          "total": 934.06,
          "product_id": 102,
          "product_name": "Product B",
          "total_quantity": 5
        }
      ]
    }
  ];
  List<Map<String, dynamic>>? get weeklyProductSold => _weeklyProdutSold;

  Future<Result> fetchTotalOfAllTransactions() async {
    _setLoading(true);
    try {
      _totalOfAllTransactions =
          await _dashboardProvider.getTotalOfThisMonthTransactions();
      _setLoading(false);
      notifyListeners();
      return Result(
          isSuccess: true, message: 'Fetched total transactions successfully.');
    } catch (e) {
      _setLoading(false);
      return Result(
          isSuccess: false, message: 'Failed to fetch total transactions: $e');
    }
  }

  Future<Result> fetchMostSoldProduct() async {
    _setLoading(true);
    try {
      _mostSoldProduct = await _dashboardProvider.getMostSoldProduct();
      _setLoading(false);
      notifyListeners();
      return Result(
          isSuccess: true, message: 'Fetched most sold product successfully.');
    } catch (e) {
      print(e);
      _setLoading(false);
      return Result(
          isSuccess: false, message: 'Failed to fetch most sold product: $e');
    }
  }

  Future<Result> fetchTotalProductsSold() async {
    _setLoading(true);
    try {
      _totalProductsSold = await _dashboardProvider.getTotalProductsSold();
      _setLoading(false);
      notifyListeners();
      return Result(
          isSuccess: true,
          message: 'Fetched total products sold successfully.');
    } catch (e) {
      print(e);
      _setLoading(false);
      return Result(
          isSuccess: false, message: 'Failed to fetch total products sold: $e');
    }
  }

  Future<Result> fetchWeeklyProductsSold() async {
    _setLoading(true);
    try {
      _weeklyProdutSold =
          await _dashboardProvider.getWeeklyTransactionSummary();
      _setLoading(false);
      notifyListeners();
      return Result(
          isSuccess: true,
          message: 'Fetched total products sold successfully.');
    } catch (e) {
      print(e);
      _setLoading(false);
      return Result(
          isSuccess: false, message: 'Failed to fetch total products sold: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
