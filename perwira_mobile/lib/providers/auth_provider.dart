import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart' as main;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? get dashboardData => _dashboardData;

  final ApiService _apiService = ApiService();

  Future<bool> login(String credential, String password) async {
    try {
      final response = await _apiService.login(credential, password);
      if (response['status'] == 'success') {
        _isAuthenticated = true;
        _token = response['token'];
        _user = response['user'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _isAuthenticated = false;
    _token = null;
    _user = null;
    notifyListeners();

    // Arahkan ke login page
    if (main.navigatorKey.currentState != null) {
      main.navigatorKey.currentState!.pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  }

  Future<void> loadUser() async {
    try {
      final response = await _apiService.getProfile();
      // ✅ Pastikan struktur response sesuai
      if (response.containsKey('data')) {
        _user = response['data']; // Untuk response yang punya 'data' key
      } else {
        _user = response; // Untuk response langsung user data
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Load user error: $e');
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? password,
  }) async {
    try {
      final response = await _apiService.updateProfile(
        name: name,
        phone: phone,
        email: email,
        address: address,
        password: password,
      );

      if (response['status'] == 'success') {
        _user = response['data']; // Gunakan data dari response
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update profile error: $e');

      // Cek jika error karena unauthorized
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint('Unauthorized during profile update');
      }
      return false;
    }
  }

  Future<void> loadDashboard() async {
    try {
      final response = await _apiService.getDashboardStats();
      _dashboardData = response;
      notifyListeners();
    } catch (e) {
      debugPrint('Load dashboard error: $e');
    }
  }

  Future verifyPhoneOTP(String fullPhone, String otp) async {}

  Future sendPhoneOTP(String fullPhone) async {}
}
