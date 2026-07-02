import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tecnico_app_airq/features/tasks/models/task_model.dart';
import 'package:tecnico_app_airq/core/constants/api_constants.dart';

class TaskProvider extends ChangeNotifier {
  List<TechTask> _tasks = [];
  bool _isLoading = false;

  List<TechTask> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchPendingTasks(String token, {bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.techTickets), // End-point real de tickets del técnico
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _tasks = data.map((item) => TechTask.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<bool> resolveTask(String ticketId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.techTickets}/$ticketId/resolve'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _tasks.removeWhere((t) => t.taskId == ticketId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error resolving task: $e');
    }
    return false;
  }
}

