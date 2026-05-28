class Product {
  final String id;
  final String farmerId;
  final String farmerName;
  final String name;
  final double price;
  final int quantity;
  final String location;
  final List<String> images;
  final String? description;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.name,
    required this.price,
    required this.quantity,
    required this.location,
    required this.images,
    this.description,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['_id'],
        farmerId: json['farmerId'],
        farmerName: json['farmerName'],
        name: json['name'],
        price: json['price'].toDouble(),
        quantity: json['quantity'],
        location: json['location'],
        images: List<String>.from(json['images']),
        description: json['description'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'quantity': quantity,
        'location': location,
        'images': images,
        'description': description,
      };
}