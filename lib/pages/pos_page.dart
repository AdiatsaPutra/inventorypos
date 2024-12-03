import 'package:flutter/material.dart';

class POSPage extends StatefulWidget {
  @override
  _POSPageState createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  List<Map<String, dynamic>> allProducts = List.generate(10, (index) {
    return {
      'name': 'Produk $index',
      'price': 100000.00,
      'stock': 10, // Stok produk
      'imageUrl':
          'https://static.retailworldvn.com/Products/Images/12217/321641/laptop-lenovo-ideapad-slim-3-14iau7-i3-1215u-8gb-256gb-win11-82rj00cpid-arc-grey-1.jpg'
    };
  });
  List<Map<String, dynamic>> displayedProducts = [];
  List<Map<String, dynamic>> selectedProducts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedProducts = List.from(allProducts);
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedProducts = List.from(allProducts);
      } else {
        displayedProducts = allProducts
            .where((product) =>
                product['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      // Check if stock is available
      if (product['stock'] > 0) {
        // Check if product is already in cart
        int index =
            selectedProducts.indexWhere((p) => p['name'] == product['name']);
        if (index != -1) {
          if (selectedProducts[index]['count'] < product['stock']) {
            selectedProducts[index]['count']++;
          } else {
            // Notify user that stock is insufficient
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Stok tidak cukup untuk ${product['name']}'),
            ));
          }
        } else {
          selectedProducts.add({
            'name': product['name'],
            'price': product['price'],
            'count': 1,
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Stok habis untuk ${product['name']}'),
        ));
      }
    });
  }

  void _incrementCount(int index) {
    setState(() {
      var product = selectedProducts[index];
      if (product['count'] <
          allProducts
              .firstWhere((p) => p['name'] == product['name'])['stock']) {
        selectedProducts[index]['count']++;
      }
    });
  }

  void _decrementCount(int index) {
    setState(() {
      if (selectedProducts[index]['count'] > 1) {
        selectedProducts[index]['count']--;
      } else {
        selectedProducts.removeAt(index);
      }
    });
  }

  double _calculateSubtotal() {
    return selectedProducts.fold(
        0, (total, product) => total + (product['price'] * product['count']));
  }

  double _calculateTax() {
    return _calculateSubtotal() * 0.1; // 10% Tax
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateTax();
  }

  void _checkout() {
    // Checkout logic
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Checkout"),
          content: Text("Total: Rp${_calculateTotal().toStringAsFixed(2)}"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedProducts.clear(); // Clear cart after checkout
                });
                Navigator.pop(context);
              },
              child: Text("Konfirmasi"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: searchController,
                      onChanged: _filterProducts,
                      decoration: InputDecoration(
                        hintText: 'Cari Produk...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width < 600 ? 2 : 4,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.67,
                      ),
                      itemCount: displayedProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          productName: displayedProducts[index]['name'],
                          price: displayedProducts[index]['price'],
                          imageUrl: displayedProducts[index]['imageUrl'],
                          stock: displayedProducts[index]['stock'],
                          onAddToCart: () =>
                              _addToCart(displayedProducts[index]),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ringkasan Transaksi", style: TextStyle(fontSize: 20)),
                  Divider(),
                  Expanded(
                    child: ListView(
                      children: selectedProducts.map((product) {
                        int index = selectedProducts.indexOf(product);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(8),
                            title:
                                Text("${product['name']} x${product['count']}"),
                            subtitle: Text(
                                "Rp${(product['price'] * product['count']).toStringAsFixed(2)}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => _incrementCount(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => _decrementCount(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal:"),
                      Text("Rp${_calculateSubtotal().toStringAsFixed(2)}"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Pajak:"),
                      Text("Rp${_calculateTax().toStringAsFixed(2)}"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Rp${_calculateTotal().toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checkout,
                      child: Text("Checkout"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Text(productName,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Rp${price.toStringAsFixed(2)}"),
                  SizedBox(height: 4),
                  Text("Stok: $stock"),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: stock > 0 ? onAddToCart : null,
                child: Text(stock > 0 ? "Tambah" : "Stok Habis"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
