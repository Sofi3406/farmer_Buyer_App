import 'api_service.dart';
import '../config/app_constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await ApiService.post(AppConstants.loginEndpoint, {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await ApiService.post(AppConstants.registerEndpoint, userData);
  }

  Future<void> forgotPassword(String email) async {
    await ApiService.post(AppConstants.forgotPasswordEndpoint, {'email': email});
  }
}