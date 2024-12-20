class Product {
  final String id;
  final String name;
  int quantity;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, quantity: $quantity, price: $price}';
  }
}
