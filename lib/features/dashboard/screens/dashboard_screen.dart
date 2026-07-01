import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tecnico_app_airq/features/auth/providers/auth_provider.dart';
import 'package:tecnico_app_airq/features/tasks/providers/task_provider.dart';
import 'package:tecnico_app_airq/core/theme/app_theme.dart';
import 'package:tecnico_app_airq/features/clients/screens/clients_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class TechDashboardScreen extends StatefulWidget {
  const TechDashboardScreen({super.key});

  @override
  State<TechDashboardScreen> createState() => _TechDashboardScreenState();
}

class _TechDashboardScreenState extends State<TechDashboardScreen> {
  int _currentIndex = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _requestPermissionsEarly();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<TaskProvider>(context, listen: false).fetchPendingTasks(token);
      }
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        // Silent refresh
        Provider.of<TaskProvider>(context, listen: false).fetchPendingTasks(token, silent: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestPermissionsEarly() async {
    await Permission.camera.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Mis Instalaciones' : 'Empresas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildTicketsTab() : const ClientsScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/provisioning', arguments: ''),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar sensor', style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Empresas',
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsTab() {
    final taskProvider = Provider.of<TaskProvider>(context);

    return taskProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () async {
              final token = Provider.of<AuthProvider>(context, listen: false).token;
              if (token != null) {
                await taskProvider.fetchPendingTasks(token);
              }
            },
            child: taskProvider.tasks.isEmpty
                ? const Center(child: Text('No hay tareas pendientes'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppTheme.primaryBlue,
                            child: Icon(Icons.location_on, color: Colors.white),
                          ),
                          title: Text(task.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.category, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w500)),
                              Text(task.location, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/ticket-detail',
                              arguments: task,
                            );
                          },
                        ),
                      );
                    },
                  ),
          );
  }
}
