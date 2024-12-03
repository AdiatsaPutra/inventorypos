import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = _transactions;
  }

  void _addTransaction(String id, String product, int quantity, double price) {
    setState(() {
      _transactions.add({
        'id': id,
        'product': product,
        'quantity': quantity,
        'price': price,
        'total': quantity * price,
      });
      _filteredTransactions = _transactions;
    });
  }

  void _editTransaction(
      int index, String id, String product, int quantity, double price) {
    setState(() {
      _transactions[index] = {
        'id': id,
        'product': product,
        'quantity': quantity,
        'price': price,
        'total': quantity * price,
      };
      _filteredTransactions = _transactions;
    });
  }

  void _deleteTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
      _filteredTransactions = _transactions;
    });
  }

  void _searchTransactions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTransactions = _transactions;
      } else {
        _filteredTransactions = _transactions.where((transaction) {
          return transaction['id']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              transaction['product']
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Pencarian
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Berdasarkan ID Transaksi atau Nama Produk',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _searchTransactions,
            ),
          ),
          // Daftar Transaksi
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _filteredTransactions[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        transaction['id'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(transaction['product']),
                    subtitle: Text(
                      'ID: ${transaction['id']}\nHarga: \$${transaction['price']}\nKuantitas: ${transaction['quantity']}\nTotal: \$${transaction['total']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTransaction(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Tombol Tambah Transaksi
        ],
      ),
    );
  }
}
