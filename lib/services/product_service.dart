import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products
  Stream<List<Product>> getProducts() {
    print('Fetching products from Firestore...');
    return _firestore.collection('products').snapshots().map((snapshot) {
      print('Received ${snapshot.docs.length} products');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        print('Product data: $data');
        return Product.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }

  // Add sample products if none exist
  Future<void> addSampleProducts() async {
    print('Checking for existing products...');
    final products = await _firestore.collection('products').get();

    if (products.docs.isEmpty) {
      print('No products found. Adding sample products...');
      final sampleProducts = [
        {
          'name': 'Apple',
          'quantity': 50,
          'price': 1.99,
        },
        {
          'name': 'Banana',
          'quantity': 40,
          'price': 0.99,
        },
        {
          'name': 'Orange',
          'quantity': 30,
          'price': 1.49,
        },
        {
          'name': 'Mango',
          'quantity': 25,
          'price': 2.99,
        },
        {
          'name': 'Grapes',
          'quantity': 35,
          'price': 3.99,
        },
        {
          'name': 'Pineapple',
          'quantity': 20,
          'price': 4.49,
        },
        {
          'name': 'Strawberry',
          'quantity': 15,
          'price': 5.99,
        },
        {
          'name': 'Blueberry',
          'quantity': 10,
          'price': 6.49,
        },
        {
          'name': 'Watermelon',
          'quantity': 8,
          'price': 7.99,
        },
        {
          'name': 'Peach',
          'quantity': 18,
          'price': 3.49,
        }
      ];

      try {
        for (final product in sampleProducts) {
          await _firestore.collection('products').add(product);
          print('Added product: ${product['name']}');
        }
        print('Successfully added all sample products');
      } catch (e) {
        print('Error adding sample products: $e');
      }
    } else {
      print('Found ${products.docs.length} existing products');
    }
  }

  // Update product quantity
  Future<void> updateProductQuantity(String productId, int newQuantity) async {
    print('Updating quantity of product $productId to $newQuantity...');
    try {
      await _firestore.collection('products').doc(productId).update({
        'quantity': newQuantity,
      });
      print('Quantity updated successfully');
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  // Add new product
  Future<void> addProduct(Product product) async {
    print('Adding new product: ${product.name}...');
    try {
      await _firestore.collection('products').add({
        'name': product.name,
        'quantity': product.quantity,
        'price': product.price,
      });
      print('Product added successfully');
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  // Check if quantity is available
  Future<bool> isQuantityAvailable(
      String productId, int requestedQuantity) async {
    print('Checking quantity of product $productId...');
    final doc = await _firestore.collection('products').doc(productId).get();
    if (!doc.exists) {
      print('Product not found');
      return false;
    }

    final product = Product.fromMap({...doc.data()!, 'id': doc.id});
    print('Available quantity: ${product.quantity}');
    return product.quantity >= requestedQuantity;
  }
}
