import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tecnico_app_airq/features/auth/models/auth_models.dart';
import 'package:tecnico_app_airq/core/constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? _role;
  bool _isLoading = false;

  String? get token => _token;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> tryAutoLogin() async {
    _token = await _storage.read(key: 'token');
    _role = await _storage.read(key: 'role');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('Login Response Status: ${response.statusCode}');
      debugPrint('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = AuthResponse.fromJson(jsonDecode(response.body));
        
        if (data.role != 'TECHNICIAN') {
          _isLoading = false;
          notifyListeners();
          return false; 
        }

        _token = data.token;
        _role = data.role;

        await _storage.write(key: 'token', value: _token);
        await _storage.write(key: 'role', value: _role);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}
