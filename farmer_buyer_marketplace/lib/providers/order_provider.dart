import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';
import '../config/app_constants.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _setLoading(true);
    try {
      final response = await ApiService.get(AppConstants.ordersEndpoint);
      _orders = (response['orders'] as List).map((o) => Order.fromJson(o)).toList();
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    _setLoading(true);
    try {
      await ApiService.post(AppConstants.ordersEndpoint, orderData);
      await fetchOrders();
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await ApiService.put('${AppConstants.ordersEndpoint}/$orderId/status', {'status': status});
    await fetchOrders();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}