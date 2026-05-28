import 'dart:convert';
import 'dart:async';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import 'storage_service.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timed out. Make sure the backend server is running and the API URL is correct.');
    } on SocketException {
      throw Exception('Cannot reach the backend server. Check the API URL and network connection.');
    }
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timed out. Make sure the backend server is running and the API URL is correct.');
    } on SocketException {
      throw Exception('Cannot reach the backend server. Check the API URL and network connection.');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timed out. Make sure the backend server is running and the API URL is correct.');
    } on SocketException {
      throw Exception('Cannot reach the backend server. Check the API URL and network connection.');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timed out. Make sure the backend server is running and the API URL is correct.');
    } on SocketException {
      throw Exception('Cannot reach the backend server. Check the API URL and network connection.');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'API Error: ${response.statusCode}');
    }
  }
}