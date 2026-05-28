enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class Order {
  final String id;
  final String buyerId;
  final String farmerId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? deliveryDate;

  Order({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['_id'],
        buyerId: json['buyerId'],
        farmerId: json['farmerId'],
        items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
        totalAmount: json['totalAmount'].toDouble(),
        status: OrderStatus.values.firstWhere((e) => e.toString() == 'OrderStatus.${json['status']}'),
        orderDate: DateTime.parse(json['orderDate']),
        deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
      );
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'],
        productName: json['productName'],
        quantity: json['quantity'],
        price: json['price'].toDouble(),
      );
}