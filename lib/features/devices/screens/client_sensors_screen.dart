import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tecnico_app_airq/features/auth/providers/auth_provider.dart';
import 'package:tecnico_app_airq/features/devices/providers/device_provider.dart';
import 'package:tecnico_app_airq/core/theme/app_theme.dart';

class ClientSensorsScreen extends StatefulWidget {
  final int clientId;
  final String clientName;

  const ClientSensorsScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<ClientSensorsScreen> createState() => _ClientSensorsScreenState();
}

class _ClientSensorsScreenState extends State<ClientSensorsScreen> {
  List<Map<String, dynamic>> _sensors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSensors();
  }

  Future<void> _loadSensors() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
      final sensors = await deviceProvider.fetchSensorsByClient(widget.clientId, token);
      if (mounted) {
        setState(() {
          _sensors = sensors;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSensor(int sensorId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Sensor'),
        content: const Text('¿Estás seguro de que deseas eliminar este sensor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
      final success = await deviceProvider.deleteSensor(sensorId, token);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sensor eliminado correctamente')),
          );
          _loadSensors();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar el sensor')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensores - ${widget.clientName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sensors.isEmpty
              ? const Center(child: Text('No hay sensores vinculados a esta empresa.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sensors.length,
                  itemBuilder: (context, index) {
                    final sensor = _sensors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue,
                          child: Icon(Icons.sensors, color: Colors.white),
                        ),
                        title: Text(sensor['serialNumber'] ?? 'Desconocido', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Ubicación: ${sensor['location'] ?? 'No especificada'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.error),
                          onPressed: () => _deleteSensor(sensor['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
