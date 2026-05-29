import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../widgets/location_picker.dart';
import '../../utils/image_picker_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
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
  bool _isUploading = false;
  List<XFile> _selectedImages = [];
  List<double> _uploadProgress = [];

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
    if (images.isEmpty) return;
    try {
      setState(() {
        _isUploading = true;
        _selectedImages = images;
        _uploadProgress = List<double>.filled(images.length, 0);
      });
      // Convert XFile list to paths
      final paths = images.map((x) => x.path).toList();
      final resp = await ApiService.uploadImages(paths, onProgress: (index, sent, total) {
        if (mounted) {
          setState(() {
            _uploadProgress[index] = total > 0 ? sent / total : 0;
          });
        }
      });
      // Expecting { urls: [...] } from backend
        final List<String> urls = (resp is Map && resp['urls'] is List)
          ? List<String>.from(resp['urls'] as List)
          : <String>[];
      setState(() {
        _imageUrls = urls;
        // clear selected images after successful upload
        _selectedImages = [];
        _uploadProgress = [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
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
              decoration: const InputDecoration(labelText: 'Price per kg (ETB)'),
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
              onPressed: _isUploading ? null : _pickImages,
              icon: const Icon(Icons.image),
              label: Text(_isUploading
                  ? 'Uploading...'
                  : (_imageUrls.isEmpty ? 'Pick Images' : '${_imageUrls.length} images selected')),
            ),
            const SizedBox(height: 12),
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    return Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                          child: Image.file(File(_selectedImages[i].path), fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 80,
                          child: LinearProgressIndicator(
                            value: _uploadProgress.length > i ? _uploadProgress[i] : 0,
                          ),
                        ),
                      ],
                    );
                  },
                ),
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