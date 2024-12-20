class Customer {
  final String id;
  final String email;
  final String name;

  Customer({
    required this.id,
    required this.email,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      email: map['email'],
      name: map['name'],
    );
  }
}
