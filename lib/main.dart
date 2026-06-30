import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tecnico_app_airq/features/auth/providers/auth_provider.dart';
import 'package:tecnico_app_airq/features/tasks/providers/task_provider.dart';
import 'package:tecnico_app_airq/features/devices/providers/device_provider.dart';
import 'package:tecnico_app_airq/features/settings/providers/security_provider.dart';
import 'package:tecnico_app_airq/features/auth/screens/login_screen.dart';
import 'package:tecnico_app_airq/features/dashboard/screens/dashboard_screen.dart';
import 'package:tecnico_app_airq/features/devices/screens/qr_scanner_screen.dart';
import 'package:tecnico_app_airq/features/devices/screens/provisioning_screen.dart';
import 'package:tecnico_app_airq/features/settings/screens/settings_screen.dart';
import 'package:tecnico_app_airq/features/tasks/screens/ticket_detail_screen.dart';
import 'package:tecnico_app_airq/features/devices/screens/client_sensors_screen.dart';
import 'package:tecnico_app_airq/features/tasks/models/task_model.dart';
import 'package:tecnico_app_airq/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: const OxairaApp(),
    ),
  );
}

class OxairaApp extends StatelessWidget {
  const OxairaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp(
          title: 'Oxaira Tech',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: auth.isAuthenticated ? const TechDashboardScreen() : const LoginScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/login') {
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            }
            if (settings.name == '/dashboard') {
              return MaterialPageRoute(builder: (_) => const TechDashboardScreen());
            }
            if (settings.name == '/scan') {
              return MaterialPageRoute(builder: (_) => const QRScannerScreen());
            }
            if (settings.name == '/provisioning') {
              final macId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => ProvisioningScreen(macId: macId),
              );
            }
            if (settings.name == '/ticket-detail') {
              final ticket = settings.arguments as TechTask;
              return MaterialPageRoute(
                builder: (_) => TicketDetailScreen(ticket: ticket),
              );
            }
            if (settings.name == '/client-sensors') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => ClientSensorsScreen(
                  clientId: args['clientId'] as int,
                  clientName: args['clientName'] as String,
                ),
              );
            }
            if (settings.name == '/settings') {
              return MaterialPageRoute(builder: (_) => const SettingsScreen());
            }
            return null;
          },
        );
      },
    );
  }
}
