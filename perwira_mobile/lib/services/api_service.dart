import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/reward.dart';
import '../models/redemption.dart';
import '../models/invoice.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8001/api';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException err, handler) {
          if (err.response?.statusCode == 401) {
            debugPrint('401 error: ${err.response?.data}');
            _storage.delete(key: 'token');
          }
          return handler.next(err);
        },
      ),
    );
  }

  // Login
  Future<Map<String, dynamic>> login(String credential, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'credential': credential, 'password': password},
      );

      if (response.data['status'] == 'success') {
        await _storage.write(key: 'token', value: response.data['token']);
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (e) {
      // Jika logout gagal, tetap hapus token
      print('Logout error: $e');
    }
    await _storage.delete(key: 'token');
  }

  // Get Profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Update Profile
  // Update Profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? password,
  }) async {
    try {
      Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (address != null) data['address'] = address;
      if (password != null) data['password'] = password;

      final response = await _dio.put('/profile', data: data);

      return response.data;
    } on DioException catch (e) {
      debugPrint('DioError during profile update:');
      debugPrint('Error type: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');

      rethrow;
    } catch (e) {
      debugPrint('Other error during profile update: $e');
      rethrow;
    }
  }

  // Get User
  Future<Map<String, dynamic>> getUser() async {
    try {
      final response = await _dio.get('/user');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Get Rewards
  Future<List<Reward>> getRewards() async {
    try {
      final response = await _dio.get('/rewards');
      return (response.data['data'] as List)
          .map((json) => Reward.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Redeem Reward
  Future<Map<String, dynamic>> redeemReward(int rewardId) async {
    try {
      final response = await _dio.post(
        '/redemptions',
        data: {'reward_id': rewardId},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Get Redemptions
  Future<List<Redemption>> getRedemptions() async {
    try {
      final response = await _dio.get('/redemptions');
      return (response.data['data'] as List)
          .map((json) => Redemption.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Upload Invoice
  Future<Map<String, dynamic>> uploadInvoice({
    required double totalAmount,
    required String salesCode,
    required String imagePath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'total_amount': totalAmount.toString(),
        'sales_code': salesCode,
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: 'invoice.jpg',
        ),
      });

      final response = await _dio.post('/invoices', data: formData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Get Invoices
  Future<List<Invoice>> getInvoices() async {
    try {
      final response = await _dio.get('/invoices');
      return (response.data['data'] as List)
          .map((json) => Invoice.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/dashboard-stats');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
