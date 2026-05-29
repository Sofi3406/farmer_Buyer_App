import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final productsById = {for (final product in productProvider.products) product.id: product};
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
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
                          leading: item.product.images.isNotEmpty
                              ? Image.network(
                                  item.product.images.first,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported, size: 20),
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image),
                                ),
                          title: Text(item.product.name),
                          subtitle: Text('ETB ${item.product.price} x ${item.quantity}kg = ETB ${item.totalPrice}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => cartProvider.updateQuantity(i, item.quantity - 1),
                              ),
                              Text('${item.quantity}kg'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  final latestProduct = productsById[item.product.id];
                                  final available = latestProduct?.quantity ?? item.product.quantity;
                                  if (item.quantity + 1 > available) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('You can\'t order more than available quantity. Only $available kg left.')),
                                    );
                                    return;
                                  }
                                  cartProvider.updateQuantity(i, item.quantity + 1);
                                },
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
                      Text('Total: ETB ${cartProvider.totalAmount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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