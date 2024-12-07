import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:inventorypos/extension/number_extension.dart';
import 'package:inventorypos/extension/string_extension.dart';
import 'package:inventorypos/provider/inventory_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Cari Produk',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: provider.searchInventory,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => exportToPdf(provider),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Ekspor ke PDF'),
            ),
          ),
          // DataTable or Loading Indicator
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.filteredInventory.isEmpty
                  ? const Center(child: Text('Produk tidak tersedia'))
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(label: Text('Nama')),
                              DataColumn(label: Text('Kode')),
                              DataColumn(label: Text('Tipe')),
                              DataColumn(label: Text('Harga')),
                              DataColumn(label: Text('Stok')),
                              DataColumn(label: Text('Aksi')),
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
                Text(
                    'Halaman ${provider.currentPage} dari ${provider.totalPages}'),
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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => _showProductForm(context, provider),
                child: const Text('Tambah Produk'),
              ),
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
    final TextEditingController initialPriceController = TextEditingController(
        text: (product?['initial_price'] as double?)?.toStringAsFixed(0) ?? '');
    provider.image = product?['image_path'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
          content: SingleChildScrollView(
            child: Column(
              children: [
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
                TextField(
                  controller: initialPriceController,
                  decoration: const InputDecoration(labelText: 'Harga Awal'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyTextInputFormatter.currency(
                      decimalDigits: 0,
                      locale: 'id_ID',
                      symbol: 'Rp',
                    )
                  ],
                ),
                const SizedBox(height: 10),
                // Image Picker
                Row(
                  children: [
                    provider.image == null
                        ? ElevatedButton.icon(
                            onPressed: () async {
                              await provider.pickImage();
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Pilih Gambar'),
                          )
                        : SizedBox(),
                    const SizedBox(width: 10),
                    Consumer<InventoryProvider>(
                      builder: (context, provider, _) {
                        if (provider.image != null) {
                          return Image.memory(
                            base64Decode(product!['image_path']),
                            width: 100,
                            height: 100,
                          );
                        }

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
              child: const Text('Batal'),
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
                final double initialPrice = double.tryParse(
                        initialPriceController.text
                            .trim()
                            .replaceAll('Rp', '')
                            .replaceAll('.', '')) ??
                    0;

                if (product == null) {
                  provider.addProduct(name, type, price, stock, initialPrice);
                } else {
                  provider.updateProduct(
                      product['id'], name, type, price, stock, initialPrice);
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
                Text('Kode: ${product['code']}'),
                Text('Tipe: ${product['type']}'),
                Text(
                    'Harga: ${(product['price'] as double).toInt().toRupiah()}'),
                Text('Stok: ${product['stock']}'),
                Text(
                    'Harga Awal: ${(product['initial_price'] as double).toInt().toRupiah()}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void exportToPdf(InventoryProvider provider) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Inventaris ${DateTime.now().toString().toFormattedDate()}',
                style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                // Header row
                pw.TableRow(
                  children: [
                    pw.Text(' Nama Produk',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(' Kode',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(' Tipe',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(' Harga',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(' Stok',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                // Data rows
                ...provider.filteredInventory.map(
                  (product) => pw.TableRow(
                    children: [
                      pw.Text(' ${product['name']}'),
                      pw.Text(' ${product['code']}'),
                      pw.Text(' ${product['type']}'),
                      pw.Text(
                        ' ${(product['price'] as double).toInt().toRupiah()}',
                      ),
                      pw.Text(' ${product['stock']}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Save and display the PDF
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
