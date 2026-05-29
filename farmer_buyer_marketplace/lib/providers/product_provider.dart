import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../config/app_constants.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  int _totalCount = 0;

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _totalCount;

  Future<void> fetchProducts({String? search, String? location, String? farmerId}) async {
    _setLoading(true);
    try {
      String endpoint = AppConstants.productsEndpoint;
      final query = <String, String>{};
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (location != null && location.isNotEmpty) query['location'] = location;
      if (farmerId != null && farmerId.isNotEmpty) query['farmerId'] = farmerId;
      if (query.isNotEmpty) {
        endpoint += '?${Uri(queryParameters: query).query}';
      }
      final response = await ApiService.get(endpoint);
      _products = (response['products'] as List).map((p) => Product.fromJson(p)).toList();
      _filteredProducts = _products;
      _totalCount = (response['total'] as int?) ?? _products.length;
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    _setLoading(true);
    try {
      await ApiService.post(AppConstants.productsEndpoint, productData);
      await fetchProducts();
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> deleteProduct(String productId) async {
    await ApiService.delete('${AppConstants.productsEndpoint}/$productId');
    await fetchProducts();
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}