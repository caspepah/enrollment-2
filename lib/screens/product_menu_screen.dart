import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import './checkout_screen.dart';

class ProductMenuScreen extends StatefulWidget {
  @override
  _ProductMenuScreenState createState() => _ProductMenuScreenState();
}

class _ProductMenuScreenState extends State<ProductMenuScreen> {
  final ProductService _productService = ProductService();
  final Map<String, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _initializeProducts();
  }

  Future<void> _initializeProducts() async {
    await _productService.addSampleProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Menu'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _showCart,
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    'Price: \$${product.price.toStringAsFixed(2)}\nAvailable: ${product.quantity}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _updateCart(product, false),
                      ),
                      Text(_cart[product.id]?.toString() ?? '0'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _updateCart(product, true),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateCart(Product product, bool increment) {
    setState(() {
      if (!_cart.containsKey(product.id)) {
        _cart[product.id] = 0;
      }

      if (increment) {
        if (_cart[product.id]! < product.quantity) {
          _cart[product.id] = _cart[product.id]! + 1;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum available quantity reached')),
          );
        }
      } else {
        if (_cart[product.id]! > 0) {
          _cart[product.id] = _cart[product.id]! - 1;
        }
      }
    });
  }

  void _showCart() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cart: _cart),
      ),
    );
  }
}
