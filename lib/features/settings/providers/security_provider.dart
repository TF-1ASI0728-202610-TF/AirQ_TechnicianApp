import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tecnico_app_airq/core/constants/api_constants.dart';

class SecurityProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse(ApiConstants.changePassword),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
