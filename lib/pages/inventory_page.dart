import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:inventorypos/extension/number_extension.dart';
import 'package:inventorypos/provider/inventory_provider.dart';
import 'package:provider/provider.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: provider.searchInventory,
            ),
          ),
          // DataTable or Loading Indicator
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.filteredInventory.isEmpty
                  ? const Center(child: Text('No products available'))
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Code')),
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('Price')),
                              DataColumn(label: Text('Stock')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: provider.paginatedInventory.map((product) {
                              return DataRow(cells: [
                                DataCell(Text(product['name'])),
                                DataCell(Text(product['code'])),
                                DataCell(Text(product['type'])),
                                DataCell(Text(
                                  (product['price'] as double)
                                      .toInt()
                                      .toRupiah(),
                                )),
                                DataCell(Text('${product['stock']}')),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.info,
                                            color: Colors.blue),
                                        onPressed: () => _showProductDetails(
                                            context, product),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.orange),
                                        onPressed: () => _showProductForm(
                                            context, provider, product),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => provider
                                            .deleteProduct(product['id']),
                                      ),
                                    ],
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
          // Pagination Controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: provider.currentPage > 1
                      ? () => provider.previousPage()
                      : null,
                ),
                Text('Page ${provider.currentPage} of ${provider.totalPages}'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: provider.currentPage < provider.totalPages
                      ? () => provider.nextPage()
                      : null,
                ),
              ],
            ),
          ),
          // Add Product Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _showProductForm(context, provider),
              child: const Text('Add Product'),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context, InventoryProvider provider,
      [Map<String, dynamic>? product]) {
    final TextEditingController nameController =
        TextEditingController(text: product?['name'] ?? '');
    final TextEditingController typeController =
        TextEditingController(text: product?['type'] ?? '');
    final TextEditingController priceController = TextEditingController(
        text: (product?['price'] as double?)?.toStringAsFixed(0) ?? '');
    final TextEditingController stockController =
        TextEditingController(text: product?['stock']?.toString() ?? '');

    provider.clearSelectedImage();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Product Type'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
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
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                // Image Picker
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await provider.pickImage();
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Select Image'),
                    ),
                    const SizedBox(width: 10),
                    Consumer<InventoryProvider>(
                      builder: (context, provider, _) {
                        if (provider.selectedImage == null) {
                          return const SizedBox();
                        }
                        return Image.file(
                          provider.selectedImage!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ],
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
                final String name = nameController.text.trim();
                final String type = typeController.text.trim();
                final double price = double.tryParse(priceController.text
                        .trim()
                        .replaceAll('Rp', '')
                        .replaceAll('.', '')) ??
                    0;
                final int stock =
                    int.tryParse(stockController.text.trim()) ?? 0;

                if (product == null) {
                  provider.addProduct(name, type, price, stock);
                } else {
                  provider.updateProduct(
                      product['id'], name, type, price, stock);
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

  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product['name']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                if (product['image_path'] != null)
                  Image.memory(
                    base64Decode(product['image_path']),
                    width: 400,
                    height: 400,
                  ),
                const SizedBox(height: 10),
                // Product Details
                Text('Code: ${product['code']}'),
                Text('Type: ${product['type']}'),
                Text(
                    'Price: ${(product['price'] as double).toInt().toRupiah()}'),
                Text('Stock: ${product['stock']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
