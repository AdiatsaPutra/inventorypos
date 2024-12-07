import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventorypos/extension/number_extension.dart';
import 'package:inventorypos/provider/dashboard_provider.dart';
import 'package:inventorypos/provider/inventory_provider.dart';
import 'package:inventorypos/provider/pos_provider.dart';
import 'package:inventorypos/provider/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import this for currency formatting

class POSPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<POSProvider>(context);
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    if (posProvider.displayedProducts.isEmpty) {
      posProvider.initialize(context);
    }

    return Scaffold(
      body: Consumer<InventoryProvider>(
        builder: (context, value, child) => Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: posProvider.searchController,
                      onChanged: (query) =>
                          posProvider.filterProducts(context, query),
                      decoration: InputDecoration(
                        hintText: 'Cari',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child:
                          // inventoryProvider.isLoading
                          //     ? Center(child: CircularProgressIndicator())
                          //     :
                          LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = constraints.maxWidth;

                          int crossAxisCount;
                          double cardSize;

                          if (screenWidth > 1600) {
                            crossAxisCount = 6;
                            cardSize = 300;
                          } else if (screenWidth > 1200) {
                            crossAxisCount = 4;
                            cardSize = 300;
                          } else if (screenWidth > 800) {
                            crossAxisCount = 3;
                            cardSize = 300;
                          } else {
                            crossAxisCount = 3;
                            cardSize = 300;
                          }

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                            itemCount: posProvider.displayedProducts.length,
                            itemBuilder: (context, index) {
                              final product =
                                  posProvider.displayedProducts[index];
                              return SizedBox(
                                width: cardSize,
                                height: cardSize,
                                child: ProductCard(
                                  productName: product['name'],
                                  price: product['price'],
                                  imageUrl: product['image_path'],
                                  stock: product['stock'],
                                  onAddToCart: () =>
                                      posProvider.addToCart(context, product),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: CartSummary(),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productName;
  final double price;
  final String imageUrl;
  final int stock;
  final VoidCallback onAddToCart;

  const ProductCard({
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: imageUrl.isNotEmpty
                  ? Image.memory(
                      base64Decode(imageUrl),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 5),
                Text('Harga: ${(price.toInt().toRupiah())}'), // Updated to IDR
                Text(
                  'Stok: $stock',
                  style: TextStyle(
                    color: stock < 2 ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: ElevatedButton(
              onPressed: onAddToCart,
              child: Text('Tambah'),
            ),
          ),
        ],
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final posProvider = Provider.of<POSProvider>(context);

    return Consumer<POSProvider>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Keranjang',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            posProvider.selectedProducts.isEmpty
                ? Expanded(child: Center(child: Text('Belum ada keranjang')))
                : Expanded(
                    child: ListView.builder(
                      itemCount: posProvider.selectedProducts.length,
                      itemBuilder: (context, index) {
                        final product = posProvider.selectedProducts[index];

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          child: ListTile(
                            title: Text(product['name']),
                            subtitle: Text('Jumlah: ${product['count']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    posProvider.removeCart(context, product);
                                  },
                                ),
                                Text(
                                  ((product['price'] * product['count'])
                                          as double)
                                      .toInt()
                                      .toRupiah(),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    posProvider.addToCart(context, product);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Total: ${posProvider.selectedProducts.fold<double>(
                      0,
                      (sum, product) =>
                          sum + (product['price'] * product['count']),
                    ).toInt().toRupiah()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: posProvider.selectedProducts.isEmpty
                    ? null
                    : () async {
                        final transactionProvider =
                            Provider.of<TransactionProvider>(context,
                                listen: false);
                        final inventoryProvider =
                            Provider.of<InventoryProvider>(context,
                                listen: false);
                        final res = await transactionProvider.addTransaction(
                          total: posProvider.selectedProducts.fold<double>(
                            0,
                            (sum, product) =>
                                sum + (product['price'] * product['count']),
                          ),
                          products: posProvider.selectedProducts,
                        );
                        if (res == 'success') {
                          posProvider.clearCart();
                          posProvider.initialize(context);
                          transactionProvider.fetchTransactions();
                          final dashboardProvider =
                              Provider.of<DashboardProvider>(context,
                                  listen: false);
                          dashboardProvider.fetchTotalOfAllTransactions();
                          dashboardProvider.fetchMostSoldProduct();
                          dashboardProvider.fetchTotalProductsSold();
                          dashboardProvider.fetchWeeklyProductsSold();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Berhasil Checkout'),
                                actions: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Oke'),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                child: Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
