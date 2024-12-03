import 'package:flutter/material.dart';

class POSPage extends StatefulWidget {
  @override
  _POSPageState createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  List<String> allProducts = List.generate(10, (index) => 'Product $index');
  List<Map<String, dynamic>> displayedProducts = [];
  List<Map<String, dynamic>> selectedProducts =
      []; // List of selected products with count
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedProducts = allProducts.map((product) {
      return {
        'name': product,
        'price': 10.00, // Example price
        'imageUrl':
            'https://static.retailworldvn.com/Products/Images/12217/321641/laptop-lenovo-ideapad-slim-3-14iau7-i3-1215u-8gb-256gb-win11-82rj00cpid-arc-grey-1.jpg'
      };
    }).toList();
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedProducts = allProducts.map((product) {
          return {
            'name': product,
            'price': 10.00,
            'imageUrl':
                'https://static.retailworldvn.com/Products/Images/12217/321641/laptop-lenovo-ideapad-slim-3-14iau7-i3-1215u-8gb-256gb-win11-82rj00cpid-arc-grey-1.jpg'
          };
        }).toList();
      } else {
        displayedProducts = allProducts
            .where((product) =>
                product.toLowerCase().contains(query.toLowerCase()))
            .map((product) {
          return {
            'name': product,
            'price': 10.00,
            'imageUrl':
                'https://static.retailworldvn.com/Products/Images/12217/321641/laptop-lenovo-ideapad-slim-3-14iau7-i3-1215u-8gb-256gb-win11-82rj00cpid-arc-grey-1.jpg'
          };
        }).toList();
      }
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      // Check if the product is already in the cart
      int index =
          selectedProducts.indexWhere((p) => p['name'] == product['name']);
      if (index != -1) {
        // Increment the count if the product is already in the cart
        selectedProducts[index]['count']++;
      } else {
        // Add new product with count 1
        selectedProducts.add({
          'name': product['name'],
          'price': product['price'],
          'count': 1,
        });
      }
    });
  }

  void _incrementCount(int index) {
    setState(() {
      selectedProducts[index]['count']++;
    });
  }

  void _decrementCount(int index) {
    setState(() {
      if (selectedProducts[index]['count'] > 1) {
        // Decrease the count if it's greater than 1
        selectedProducts[index]['count']--;
      } else {
        // Remove the product if the count is 1
        selectedProducts.removeAt(index);
      }
    });
  }

  double _calculateSubtotal() {
    return selectedProducts.fold(
        0, (total, product) => total + (product['price'] * product['count']));
  }

  double _calculateTax() {
    return _calculateSubtotal() * 0.1; // 10% tax
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateTax();
  }

  void _checkout() {
    // Implement checkout logic (e.g., print total, clear cart)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Checkout"),
          content: Text("Total: \$${_calculateTotal().toStringAsFixed(2)}"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedProducts.clear(); // Clear cart after checkout
                });
                Navigator.pop(context);
              },
              child: Text("Confirm"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
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
          // Left Section - Product Cards
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Field
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: searchController,
                      onChanged: _filterProducts,
                      decoration: InputDecoration(
                        hintText: 'Search Products...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                  // Product Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width < 600
                            ? 2
                            : 4, // Adjust based on screen size
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: displayedProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          productName: displayedProducts[index]['name'],
                          price: displayedProducts[index]['price'],
                          imageUrl: displayedProducts[index]['imageUrl'],
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

          // Right Section - Transaction Summary
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Transaction Summary", style: TextStyle(fontSize: 20)),
                  Divider(),
                  // Display selected products with their count in a Card
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
                                "\$${(product['price'] * product['count']).toStringAsFixed(2)}"),
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
                  Text(
                      "Subtotal: \$${_calculateSubtotal().toStringAsFixed(2)}"),
                  Text("Tax: \$${_calculateTax().toStringAsFixed(2)}"),
                  Text("Total: \$${_calculateTotal().toStringAsFixed(2)}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: _checkout,
                    child: Text("Checkout"),
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
  final VoidCallback onAddToCart;

  const ProductCard({
    required this.productName,
    required this.price,
    required this.imageUrl,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 8),
                Text(productName,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("\$${price.toStringAsFixed(2)}"),
                ElevatedButton(
                  onPressed: onAddToCart,
                  child: Text("Add to Cart"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
