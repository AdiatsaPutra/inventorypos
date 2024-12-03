import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _inventory = [];
  List<Map<String, dynamic>> _filteredInventory = [];

  @override
  void initState() {
    super.initState();
    _filteredInventory = _inventory; // Initialize with full inventory
  }

  void _addProduct(String code, String name, double price, int stock) {
    setState(() {
      _inventory.add({
        'code': code,
        'name': name,
        'price': price,
        'stock': stock,
      });
      _filteredInventory = _inventory;
    });
  }

  void _editProduct(
      int index, String code, String name, double price, int stock) {
    setState(() {
      _inventory[index] = {
        'code': code,
        'name': name,
        'price': price,
        'stock': stock,
      };
      _filteredInventory = _inventory;
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _inventory.removeAt(index);
      _filteredInventory = _inventory;
    });
  }

  void _searchInventory(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredInventory = _inventory;
      } else {
        _filteredInventory = _inventory.where((product) {
          return product['code'].toLowerCase().contains(query.toLowerCase()) ||
              product['name'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Product Code or Name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _searchInventory,
            ),
          ),
          // Inventory List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredInventory.length,
              itemBuilder: (context, index) {
                final product = _filteredInventory[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        product['code'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(product['name']),
                    subtitle: Text(
                      'Code: ${product['code']}\nPrice: \$${product['price']}\nStock: ${product['stock']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () =>
                              _showProductForm(context, index, product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Add Product Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _showProductForm(context),
              child: const Text('Add Product'),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context,
      [int? index, Map<String, dynamic>? product]) {
    final TextEditingController codeController =
        TextEditingController(text: product?['code'] ?? '');
    final TextEditingController nameController =
        TextEditingController(text: product?['name'] ?? '');
    final TextEditingController priceController = TextEditingController(
        text: product != null ? product['price'].toString() : '');
    final TextEditingController stockController = TextEditingController(
        text: product != null ? product['stock'].toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Product Code'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String code = codeController.text.trim();
                final String name = nameController.text.trim();
                final double price =
                    double.tryParse(priceController.text.trim()) ?? 0;
                final int stock =
                    int.tryParse(stockController.text.trim()) ?? 0;

                if (index == null) {
                  _addProduct(code, name, price, stock);
                } else {
                  _editProduct(index, code, name, price, stock);
                }

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
