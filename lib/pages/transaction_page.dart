import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventorypos/extension/number_extension.dart';
import 'package:inventorypos/extension/string_extension.dart';
import 'package:inventorypos/provider/transaction_provider.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) {
                    provider.filterTransactions(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Cari',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              // Transactions Table
              Expanded(
                child: provider.paginatedTransactions.isEmpty
                    ? const Center(child: Text('Belum Ada Transaksi'))
                    : SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Kode Transaksi')),
                            DataColumn(label: Text('Tanggal')),
                            DataColumn(label: Text('Total')),
                            DataColumn(label: Text('Aksi')),
                          ],
                          rows:
                              provider.paginatedTransactions.map((transaction) {
                            return DataRow(cells: [
                              DataCell(Text(
                                  transaction['transaction_code'].toString())),
                              DataCell(Text(DateFormat('dd MMM yyyy', 'id')
                                  .format(DateTime.parse(
                                      transaction['date'] as String)))),
                              DataCell(Text((transaction['total'] as double)
                                  .toInt()
                                  .toRupiah())),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.info,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        final res = await provider
                                            .fetchTransactionDetails(
                                                transaction['id']);
                                        if (res == 'success') {
                                          _showTransactionDetailsDialog(
                                              context,
                                              provider.transactionDetails ??
                                                  {});
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                res,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        final res =
                                            await provider.deleteTransaction(
                                                transaction['id']);
                                        if (res == 'success') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Transaksi berhasil dihapus')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
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
                        'Page ${provider.currentPage} of ${provider.totalPages}'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: provider.currentPage < provider.totalPages
                          ? () => provider.nextPage()
                          : null,
                    ),
                  ],
                ),
              ),
              // Add Transaction Button
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: ElevatedButton(
              //     onPressed: () {
              //       _showTransactionForm(context, provider);
              //     },
              //     child: const Text('Add Transaction'),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }

  void _showTransactionDetailsDialog(
      BuildContext context, Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detail Transaksi'),
          content: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kode Transaksi: '),
                      Text(transaction['transaction']['transaction_code']),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tanggal: '),
                      Text(transaction['transaction']['date']
                          .toString()
                          .toFormattedDate()),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Discount: '),
                      Text((transaction['transaction']['discount'] as double)
                          .toInt()
                          .toRupiah()),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: '),
                      Text((transaction['transaction']['total'] as double)
                          .toInt()
                          .toRupiah()),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Produk Terjual',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: 900,
                    child: Table(
                      border: TableBorder.all(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                      columnWidths: {
                        0: FixedColumnWidth(50),
                        1: FixedColumnWidth(150),
                        2: FixedColumnWidth(100),
                        3: FixedColumnWidth(100),
                      },
                      children: [
                        // Table Header Row
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Foto'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Nama'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Harga'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Terjual'),
                            ),
                          ],
                        ),
                        // Table Rows for each product
                        ...(transaction['products']
                                as List<Map<String, dynamic>>)
                            .mapIndexed(
                          (i, e) => TableRow(
                            children: [
                              // Product image (adjust size if needed)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(
                                  File(
                                      transaction['products'][i]['image_path']),
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                              // Product Name
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(transaction['products'][i]['name']),
                              ),
                              // Product Price
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  (transaction['products'][i]['price']
                                          as double)
                                      .toInt()
                                      .toRupiah(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  transaction['products'][i]['quantity']
                                      .toString(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  // const SizedBox(height: 8),
                  // Text(
                  //     'Date: ${DateFormat('dd MMM yyyy', 'id').format(DateTime.parse(transaction['date'] as String))}'),
                  // const SizedBox(height: 8),
                  // Text('Total: ${transaction['total']}'),
                  // const SizedBox(height: 8),
                  // Text('Products:'),
                  // for (var product in transaction['products'])
                  //   Text(
                  //     '  - ${product['product']} (x${product['quantity']})',
                  //   ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
