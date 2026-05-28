import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  bool _isPlacing = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter delivery address')));
      return;
    }
    setState(() => _isPlacing = true);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final orderData = {
      'items': cartProvider.toOrderItems(),
      'totalAmount': cartProvider.totalAmount,
      'deliveryAddress': _addressController.text,
      'buyerId': authProvider.user!.id,
      // farmerId will be inferred from products (backend logic)
    };
    await orderProvider.placeOrder(orderData);
    cartProvider.clearCart();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully')));
      context.go('/buyer-dashboard');
    }
    setState(() => _isPlacing = false);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.items.length,
                itemBuilder: (ctx, i) {
                  final item = cartProvider.items[i];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Qty: ${item.quantity} x ₹${item.product.price}'),
                    trailing: Text('₹${item.totalPrice}'),
                  );
                },
              ),
            ),
            const Divider(),
            Text('Total: ₹${cartProvider.totalAmount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Delivery Address', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _isPlacing
                ? const LoadingIndicator()
                : CustomButton(
                    text: 'Place Order',
                    onPressed: _placeOrder,
                  ),
          ],
        ),
      ),
    );
  }
}