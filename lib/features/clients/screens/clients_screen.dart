import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tecnico_app_airq/features/auth/providers/auth_provider.dart';
import 'package:tecnico_app_airq/features/devices/providers/device_provider.dart';
import 'package:tecnico_app_airq/core/theme/app_theme.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<DeviceProvider>(context, listen: false).fetchClients(token);
      }
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<DeviceProvider>(context, listen: false).fetchClients(token, silent: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);

    return deviceProvider.isLoadingClients
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () async {
              final token = Provider.of<AuthProvider>(context, listen: false).token;
              if (token != null) {
                await deviceProvider.fetchClients(token);
              }
            },
            child: deviceProvider.clients.isEmpty
                ? const Center(child: Text('No hay empresas asignadas.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: deviceProvider.clients.length,
                    itemBuilder: (context, index) {
                      final client = deviceProvider.clients[index];
                      final companyName = client['companyName'] ?? 'Sin Empresa';
                      final contactName = client['name'] ?? 'Cliente';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppTheme.primaryBlue,
                            child: Icon(Icons.business, color: Colors.white),
                          ),
                          title: Text(companyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contactName),
                              Text(client['email'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/client-sensors',
                              arguments: {
                                'clientId': client['id'],
                                'clientName': companyName,
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
          );
  }
}
