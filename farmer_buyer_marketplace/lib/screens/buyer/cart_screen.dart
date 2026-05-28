import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cartProvider.items.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cartProvider.items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Image.network(item.product.images.first, width: 50, height: 50),
                          title: Text(item.product.name),
                          subtitle: Text('₹${item.product.price} x ${item.quantity} = ₹${item.totalPrice}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => cartProvider.updateQuantity(i, item.quantity - 1),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => cartProvider.updateQuantity(i, item.quantity + 1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => cartProvider.removeFromCart(i),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey.shade300)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: ₹${cartProvider.totalAmount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      CustomButton(
                        text: 'Checkout',
                        onPressed: () => context.go('/checkout'),
                        width: 120,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}