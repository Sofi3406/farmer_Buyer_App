import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../providers/cart_provider.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool showFarmer;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.showFarmer = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.images.isNotEmpty
                    ? Image.network(
                        product.images.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.image)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('ETB ${product.price} per kg', style: const TextStyle(color: Colors.green)),
                    Text('Qty: ${product.quantity}kg'),
                    if (showFarmer) Text('Farmer: ${product.farmerName}'),
                    Text('📍 ${product.location}'),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                )
              else
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                  onPressed: () async {
                    final cart = Provider.of<CartProvider>(context, listen: false);
                    final messenger = ScaffoldMessenger.of(context);
                    final qty = await showDialog<int>(
                      context: context,
                      builder: (ctx) {
                        final controller = TextEditingController(text: '1');
                        return AlertDialog(
                          title: const Text('Enter amount (kg)'),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(suffixText: 'kg'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                final v = int.tryParse(controller.text);
                                if (v == null || v <= 0) return;
                                Navigator.of(ctx).pop(v);
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                    if (qty != null) {
                      final existingIndex = cart.items.indexWhere((it) => it.product.id == product.id);
                      final existingQty = existingIndex != -1 ? cart.items[existingIndex].quantity : 0;
                      final available = product.quantity - existingQty;
                      if (qty > available) {
                        messenger.showSnackBar(SnackBar(content: Text('Only $available kg available')));
                      } else {
                        cart.addToCart(product, quantity: qty);
                        messenger.showSnackBar(const SnackBar(content: Text('Added to cart')));
                      }
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}