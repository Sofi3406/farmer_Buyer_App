import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../widgets/location_picker.dart';
import '../../utils/image_picker_helper.dart';
import '../../widgets/loading_indicator.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descController = TextEditingController();
  String? _location;
  List<String> _imageUrls = [];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await ImagePickerHelper.pickMultipleImages();
    // In a real app, upload each image to server and get URL
    // For now, we simulate upload
    setState(() {
      _imageUrls = images.map((_) => 'https://via.placeholder.com/150').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price per unit (₹)'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid price' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Available Quantity'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid quantity' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            LocationPicker(onLocationSelected: (loc) => _location = loc),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image),
              label: Text(_imageUrls.isEmpty ? 'Pick Images' : '${_imageUrls.length} images selected'),
            ),
            const SizedBox(height: 24),
            productProvider.isLoading
                ? const LoadingIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && _location != null) {
                        final productData = {
                          'name': _nameController.text.trim(),
                          'price': double.parse(_priceController.text),
                          'quantity': int.parse(_quantityController.text),
                          'location': _location,
                          'images': _imageUrls,
                          'description': _descController.text.trim(),
                        };
                        await productProvider.addProduct(productData);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Product added successfully')),
                          );
                          context.go('/farmer-products');
                        }
                      } else if (_location == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a location')),
                        );
                      }
                    },
                    child: const Text('Add Product'),
                  ),
          ],
        ),
      ),
    );
  }
}