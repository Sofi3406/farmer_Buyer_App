import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../config/app_constants.dart';

class UserProvider extends ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    _setLoading(true);
    try {
      final response = await ApiService.get(AppConstants.usersEndpoint);
      _users = (response['users'] as List).map((u) => User.fromJson(u)).toList();
      _error = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await ApiService.put('${AppConstants.usersEndpoint}/$userId', data);
    await fetchUsers();
  }

  Future<void> deleteUser(String userId) async {
    await ApiService.delete('${AppConstants.usersEndpoint}/$userId');
    await fetchUsers();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}