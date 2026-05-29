import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../config/app_constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    try {
      final response = await ApiService.get('${AppConstants.productsEndpoint}/${widget.productId}');
      setState(() {
        _product = Product.fromJson(response['product']);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_product == null) {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_product!.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // Fallback to buyer dashboard
              final role = Provider.of<AuthProvider>(context, listen: false).user?.role;
              if (role == 'buyer') {
                context.go('/buyer-dashboard');
              } else if (role == 'farmer') {
                context.go('/farmer-dashboard');
              } else {
                context.go('/');
              }
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_product!.images.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: _product!.images.length,
                  itemBuilder: (ctx, i) => Image.network(
                    _product!.images[i],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(_product!.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('ETB ${_product!.price} per kg', style: const TextStyle(fontSize: 20, color: Colors.green)),
            const SizedBox(height: 8),
            Text('Quantity available: ${_product!.quantity}'),
            Text('Location: ${_product!.location}'),
            Text('Seller: ${_product!.farmerName}'),
            const SizedBox(height: 16),
            if (_product!.description != null) Text(_product!.description!),
            const SizedBox(height: 24),
            ElevatedButton.icon(
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
                  final existingIndex = cart.items.indexWhere((it) => it.product.id == _product!.id);
                  final existingQty = existingIndex != -1 ? cart.items[existingIndex].quantity : 0;
                  final available = _product!.quantity - existingQty;
                  if (qty > available) {
                    messenger.showSnackBar(SnackBar(content: Text('Only $available kg available')));
                  } else {
                    cart.addToCart(_product!, quantity: qty);
                    messenger.showSnackBar(const SnackBar(content: Text('Added to cart')));
                  }
                }
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}