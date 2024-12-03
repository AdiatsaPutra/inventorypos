import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _inventory = [];
  List<Map<String, dynamic>> _filteredInventory = [];
  final NumberFormat currencyFormatter =
      NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
  final NumberFormat numberFormatter =
      NumberFormat.decimalPattern('id'); // For stock formatting

  @override
  void initState() {
    super.initState();
    _filteredInventory = _inventory; // Initialize with full inventory
  }

  void _addProduct(
      String code, String name, String type, double price, int stock) {
    setState(() {
      _inventory.add({
        'code': code,
        'name': name,
        'type': type,
        'price': price,
        'stock': stock,
      });
      _filteredInventory = _inventory;
    });
  }

  void _editProduct(int index, String code, String name, String type,
      double price, int stock) {
    setState(() {
      _inventory[index] = {
        'code': code,
        'name': name,
        'type': type,
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
              product['name'].toLowerCase().contains(query.toLowerCase()) ||
              product['type'].toLowerCase().contains(query.toLowerCase());
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
                labelText: 'Cari berdasarkan Kode, Nama, atau Tipe Produk',
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
                      'Kode: ${product['code']}\nTipe: ${product['type']}\nHarga: ${currencyFormatter.format(product['price'])}\nStok: ${numberFormatter.format(product['stock'])}',
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
              child: const Text('Tambah Produk'),
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
    final TextEditingController typeController =
        TextEditingController(text: product?['type'] ?? '');
    final TextEditingController priceController = TextEditingController(
        text: product != null ? product['price'].toStringAsFixed(0) : '');
    final TextEditingController stockController = TextEditingController(
        text: product != null ? product['stock'].toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Tambah Produk' : 'Edit Produk'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Kode Produk'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Produk'),
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Tipe Produk'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyTextInputFormatter.currency(
                      decimalDigits: 0,
                      locale: 'id_ID',
                      symbol: 'Rp',
                    )
                  ],
                ),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final String code = codeController.text.trim();
                final String name = nameController.text.trim();
                final String type = typeController.text.trim();
                final double price = double.tryParse(priceController.text
                        .trim()
                        .replaceAll('Rp', '')
                        .replaceAll('.', '')) ??
                    0;
                final int stock = int.tryParse(stockController.text
                        .trim()
                        .replaceAll('Rp', '')
                        .replaceAll('.', '')) ??
                    0;

                if (index == null) {
                  _addProduct(code, name, type, price, stock);
                } else {
                  _editProduct(index, code, name, type, price, stock);
                }

                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
