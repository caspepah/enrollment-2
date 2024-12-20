import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class CheckoutScreen extends StatelessWidget {
  final Map<String, int> cart;
  final ProductService _productService = ProductService();

  CheckoutScreen({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;
          final cartProducts = products.where((p) => cart.containsKey(p.id)).toList();
          
          // Calculate total here
          double total = cartProducts.fold(0.0, (sum, product) {
            final quantity = cart[product.id]!;
            return sum + (product.price * quantity);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProducts.length,
                  itemBuilder: (context, index) {
                    final product = cartProducts[index];
                    final quantity = cart[product.id]!;
                    final subtotal = product.price * quantity;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: $quantity'),
                            Text('Price per item: \$${product.price.toStringAsFixed(2)}'),
                            Text(
                              'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showTransactionSummary(context, cartProducts, total),
                      child: Text(
                        'Confirm Purchase',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTransactionSummary(BuildContext context, List<Product> cartProducts, double total) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Transaction Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items Purchased:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                ...cartProducts.map((product) {
                  final quantity = cart[product.id]!;
                  final subtotal = product.price * quantity;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Quantity: $quantity x \$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                        Divider(),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
                Text(
                  'Total Amount: \$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _handleCheckout(context, cartProducts);
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCheckout(BuildContext context, List<Product> cartProducts) async {
    try {
      // Verify quantities and update stock
      for (final product in cartProducts) {
        final quantity = cart[product.id]!;
        final isAvailable = await _productService.isQuantityAvailable(
          product.id,
          quantity,
        );

        if (!isAvailable) {
          throw 'Some products are no longer available in the requested quantity';
        }

        await _productService.updateProductQuantity(
          product.id,
          product.quantity - quantity,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase successful!')),
      );
      
      // Navigate back to product menu
      Navigator.of(context).popUntil((route) => route.isFirst);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
