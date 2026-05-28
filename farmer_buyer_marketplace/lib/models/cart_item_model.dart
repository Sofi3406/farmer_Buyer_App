import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'quantity': quantity,
        'price': product.price,
      };
}