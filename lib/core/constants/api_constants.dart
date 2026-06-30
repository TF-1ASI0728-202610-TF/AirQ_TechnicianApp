import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Apuntando al backend oficial en producción (Render)
  static String get baseUrl => 'https://airqbackendprueba.onrender.com/api/v1';
  
  static String get login => '$baseUrl/auth/login';
  static String get sensors => '$baseUrl/sensors';
  static String get measurements => '$baseUrl/measurements';
  static String get clients => '$baseUrl/admin/clients';
  static String get techTickets => '$baseUrl/tech/tickets';
  static String get techClients => '$baseUrl/tech/clients';
  static String get techSensorsAssign => '$baseUrl/tech/sensors/assign';
  static String get techSensorsBase => '$baseUrl/tech/sensors';
  
  // Endpoint para cambio de contraseña (ajustar si es diferente en tu backend)
  static String get changePassword => '$baseUrl/auth/password/change';
}
