import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load product')));
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
      appBar: AppBar(title: Text(_product!.name)),
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
                  itemBuilder: (ctx, i) => Image.network(_product!.images[i], fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 16),
            Text(_product!.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('₹${_product!.price} per unit', style: const TextStyle(fontSize: 20, color: Colors.green)),
            const SizedBox(height: 8),
            Text('Quantity available: ${_product!.quantity}'),
            Text('Location: ${_product!.location}'),
            Text('Seller: ${_product!.farmerName}'),
            const SizedBox(height: 16),
            if (_product!.description != null) Text(_product!.description!),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).addToCart(_product!);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
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