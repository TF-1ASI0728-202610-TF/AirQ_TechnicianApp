import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tecnico_app_airq/core/constants/api_constants.dart';

class DeviceProvider extends ChangeNotifier {
  bool _isProvisioning = false;
  bool _isLoadingClients = false;
  List<Map<String, dynamic>> _clients = [];

  bool get isProvisioning => _isProvisioning;
  bool get isLoadingClients => _isLoadingClients;
  List<Map<String, dynamic>> get clients => _clients;

  Future<void> fetchClients(String token, {bool silent = false}) async {
    if (!silent) {
      _isLoadingClients = true;
      notifyListeners();
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.techClients),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _clients = data.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('Error fetching clients: $e');
    } finally {
      if (!silent) {
        _isLoadingClients = false;
      }
      notifyListeners();
    }
  }

  Future<bool> provisionDevice({
    required String token,
    required String serialNumber,
    required String campus,
    required String location,
    required int clientId,
  }) async {
    _isProvisioning = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.techSensorsAssign),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'macAddress': serialNumber,
          'campus': campus,
          'location': location,
          'clientId': clientId,
        }),
      );

      debugPrint('Provision Response: ${response.statusCode}');
      _isProvisioning = false;
      notifyListeners();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Provision Error: $e');
      _isProvisioning = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSensorsByClient(int clientId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/tech/sensors/clients/$clientId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('Error fetching sensors for client: $e');
    }
    return [];
  }

  Future<bool> deleteSensor(int sensorId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.techSensorsBase}/$sensorId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting sensor: $e');
      return false;
    }
  }
}
