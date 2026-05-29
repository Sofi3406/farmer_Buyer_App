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
  final String? receiptUrl;

  Order({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    this.receiptUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    buyerId: json['buyerId']?.toString() ?? '',
    farmerId: json['farmerId']?.toString() ?? '',
    items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
    totalAmount: (json['totalAmount'] as num).toDouble(),
    status: OrderStatus.values.firstWhere(
      (e) => e.toString() == 'OrderStatus.${json['status']}',
      orElse: () => OrderStatus.pending,
    ),
    orderDate: DateTime.parse(
      (json['orderDate'] ?? json['createdAt']).toString(),
    ),
    deliveryDate: json['deliveryDate'] != null
        ? DateTime.parse(json['deliveryDate'].toString())
        : null,
    receiptUrl: json['receiptUrl']?.toString(),
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
    productId: json['productId']?.toString() ?? '',
    productName: json['productName']?.toString() ?? '',
    quantity: (json['quantity'] as num).toInt(),
    price: (json['price'] as num).toDouble(),
  );
}
