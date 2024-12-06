import 'package:flutter/material.dart';
import 'package:inventorypos/provider/inventory_provider.dart';
import 'package:provider/provider.dart';

class POSProvider with ChangeNotifier {
  List<Map<String, dynamic>> displayedProducts = [];
  List<Map<String, dynamic>> selectedProducts = [];
  TextEditingController searchController = TextEditingController();

  void initialize(BuildContext context) async {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    await inventoryProvider.fetchProducts();
    displayedProducts = List.from(inventoryProvider.filteredInventory);
  }

  void filterProducts(BuildContext context, String query) {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    inventoryProvider.searchInventory(query);
    displayedProducts = List.from(inventoryProvider.filteredInventory);
    notifyListeners();
  }

  void addToCart(BuildContext context, Map<String, dynamic> product) {
    final newProduct = Map.of(product);
    newProduct['count'] = 1;

    int index = selectedProducts.indexWhere((p) => p['id'] == product['id']);
    if (index != -1) {
      if (selectedProducts[index]['count'] < product['stock']) {
        selectedProducts[index]['count']++;
      }
    } else {
      selectedProducts.add(newProduct);
    }
    notifyListeners();
  }

  void removeCart(BuildContext context, Map<String, dynamic> product) {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);

    int index =
        selectedProducts.indexWhere((p) => p['name'] == product['name']);
    if (index != -1 && selectedProducts[index]['count'] > 0) {
      if (selectedProducts[index]['count'] < product['stock']) {
        selectedProducts[index]['count']--;
      }
    }

    if (selectedProducts[index]['count'] == 0) {
      selectedProducts.removeAt(index);
    }
    notifyListeners();
  }
}
