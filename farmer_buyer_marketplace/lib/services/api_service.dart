import 'dart:convert';
import 'dart:async';
import 'dart:io' show SocketException, Platform;
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
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

  static Future<dynamic> uploadImages(
    List<String> imagePaths, {
    void Function(int index, int sent, int total)? onProgress,
  }) async {
    try {
      final token = await StorageService.getToken();
      final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl, connectTimeout: const Duration(seconds: 15)));
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final List<String> uploadedUrls = [];

      for (var i = 0; i < imagePaths.length; i++) {
        final path = imagePaths[i];
        final fileName = path.split(Platform.pathSeparator).last;
        final formData = FormData.fromMap({
          'images': MultipartFile.fromFileSync(path, filename: fileName),
        });

        final response = await dio.post('/upload', data: formData, onSendProgress: (sent, total) {
          if (onProgress != null) onProgress(i, sent, total);
        });

        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          final data = response.data;
          if (data is Map && data['urls'] is List && data['urls'].isNotEmpty) {
            uploadedUrls.add(data['urls'][0]);
          }
        } else {
          throw Exception('Upload failed for file: $fileName');
        }
      }

      return {'urls': uploadedUrls};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timed out. Make sure the backend server is running and the API URL is correct.');
      }
      throw Exception('Upload failed: ${e.message}');
    } on SocketException {
      throw Exception('Cannot reach the backend server. Check the API URL and network connection.');
    } catch (e) {
      throw Exception('Upload failed: $e');
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