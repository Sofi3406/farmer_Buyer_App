import 'package:flutter/foundation.dart';

class AppConstants {
  static const String _overrideBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    if (kIsWeb) return 'http://localhost:3000/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000/api';
      default:
        return 'http://localhost:3000/api';
    }
  }

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String usersEndpoint = '/users';

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}