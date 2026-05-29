import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

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
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    if (_isPlacing) return; // prevent duplicate submissions
    if (_addressController.text.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Please enter delivery address')));
      return;
    }
    setState(() => _isPlacing = true);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    await productProvider.fetchProducts();
    final latestProductsById = {
      for (final product in productProvider.products) product.id: product,
    };

    for (final item in cartProvider.items) {
      final latestProduct = latestProductsById[item.product.id];
      if (latestProduct == null) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('Product ${item.product.name} is no longer available')),
        );
        return;
      }
      if (item.quantity > latestProduct.quantity) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('You can\'t order more than available quantity for ${item.product.name}. Only ${latestProduct.quantity} kg left.')),
        );
        return;
      }
    }

    final orderData = {
      'items': cartProvider.toOrderItems(),
      'totalAmount': cartProvider.totalAmount,
      'deliveryAddress': _addressController.text,
      'buyerId': authProvider.user!.id,
      // farmerId will be inferred from products (backend logic)
    };
    try {
      await orderProvider.placeOrder(orderData);
      cartProvider.clearCart();
      await productProvider.fetchProducts();
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Order placed successfully')));
      final refreshToken = DateTime.now().millisecondsSinceEpoch.toString();
      router.go('/buyer-dashboard?refresh=$refreshToken');
    } catch (e) {
      // Show API error to buyer (e.g., insufficient stock)
      final msg = e.toString();
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) {
        setState(() => _isPlacing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/buyer-dashboard');
            }
          },
        ),
      ),
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
                    subtitle: Text('Qty: ${item.quantity}kg x ETB ${item.product.price}'),
                    trailing: Text('ETB ${item.totalPrice}'),
                  );
                },
              ),
            ),
            const Divider(),
            Text('Total: ETB ${cartProvider.totalAmount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Delivery Address', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: _isPlacing ? 'Placing...' : 'Place Order',
              onPressed: _isPlacing ? null : _placeOrder,
            ),
          ],
        ),
      ),
    );
  }
}