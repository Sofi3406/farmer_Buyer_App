import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _receiptImage;
  bool _isPlacing = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickReceiptImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (!mounted || image == null) return;
    setState(() {
      _receiptImage = image;
    });
  }

  Future<void> _placeOrder() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    if (_isPlacing) return; // prevent duplicate submissions
    if (_addressController.text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }
    if (_receiptImage == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please upload a receipt before placing the order'),
        ),
      );
      return;
    }
    setState(() => _isPlacing = true);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    try {
      final receiptUpload = await ApiService.uploadImages([
        _receiptImage!.path,
      ]);
      final receiptUrl = (receiptUpload['urls'] as List).isNotEmpty
          ? receiptUpload['urls'][0].toString()
          : null;
      if (receiptUrl == null || receiptUrl.isEmpty) {
        throw Exception('Receipt upload failed');
      }

      final orderData = {
        'items': cartProvider.toOrderItems(),
        'totalAmount': cartProvider.totalAmount,
        'deliveryAddress': _addressController.text,
        'buyerId': authProvider.user!.id,
        'receiptUrl': receiptUrl,
        // farmerId will be inferred from products (backend logic)
      };

      await orderProvider.placeOrder(orderData);
      cartProvider.clearCart();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Order placed successfully')),
      );
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
    final paymentProduct = cartProvider.items.isNotEmpty
        ? cartProvider.items.first.product
        : null;
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
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.items.length,
                itemBuilder: (ctx, i) {
                  final item = cartProvider.items[i];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text(
                      'Qty: ${item.quantity}kg x ETB ${item.product.price}',
                    ),
                    trailing: Text('ETB ${item.totalPrice}'),
                  );
                },
              ),
            ),
            const Divider(),
            Card(
              elevation: 0,
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.35),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bank: CBE',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Account Number: ${paymentProduct?.accountNumber ?? 'Not provided'}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Holder Name: ${paymentProduct?.accountHolderName ?? paymentProduct?.farmerName ?? 'Not provided'}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: ETB ${cartProvider.totalAmount}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _isPlacing ? null : _pickReceiptImage,
              icon: const Icon(Icons.receipt_long),
              label: Text(
                _receiptImage == null ? 'Upload Receipt' : 'Receipt Selected',
              ),
            ),
            if (_receiptImage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_receiptImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_receiptImage!.name)),
                  ],
                ),
              ),
            ],
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
