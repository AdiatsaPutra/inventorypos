import 'package:flutter/material.dart';
import 'package:inventorypos/provider/transaction_provider.dart';
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
                    labelText: 'Search by Transaction ID or Product Name',
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
                    ? const Center(child: Text('No transactions available'))
                    : SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Kode Transaksi')),
                            DataColumn(label: Text('Tanggal')),
                            DataColumn(label: Text('Total')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows:
                              provider.paginatedTransactions.map((transaction) {
                            return DataRow(cells: [
                              DataCell(Text(
                                  transaction['transaction_code'].toString())),
                              DataCell(Text(DateFormat('dd MMM yyyy', 'id')
                                  .format(DateTime.parse(
                                      transaction['date'] as String)))),
                              DataCell(Text(transaction['total'].toString())),
                              DataCell(
                                Row(
                                  children: [
                                    // IconButton(
                                    //   icon: const Icon(Icons.edit,
                                    //       color: Colors.blue),
                                    //   onPressed: () {
                                    //     _showTransactionForm(
                                    //         context, provider, transaction);
                                    //   },
                                    // ),
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
                                                    'Transaction deleted successfully')),
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

  void _showTransactionForm(BuildContext context, TransactionProvider provider,
      [Map<String, dynamic>? transaction]) {
    final TextEditingController productController =
        TextEditingController(text: transaction?['product'] ?? '');
    final TextEditingController quantityController =
        TextEditingController(text: transaction?['quantity']?.toString() ?? '');
    final TextEditingController dateController =
        TextEditingController(text: transaction?['date'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              transaction == null ? 'Add Transaction' : 'Edit Transaction'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: productController,
                  decoration: const InputDecoration(labelText: 'Product'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
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
              onPressed: () async {
                if (transaction == null) {
                  await provider.addTransaction(
                    total: 0, // Add logic for total calculation if required
                    products: [
                      {
                        'product': productController.text,
                        'quantity': quantityController.text
                      }
                    ],
                  );
                } else {
                  await provider.updateTransaction(
                    transaction['id'],
                    dateController.text,
                    0, // Add logic for total calculation if required
                  );
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
