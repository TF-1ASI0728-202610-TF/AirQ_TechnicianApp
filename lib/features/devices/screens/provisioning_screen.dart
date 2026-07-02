import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tecnico_app_airq/features/auth/providers/auth_provider.dart';
import 'package:tecnico_app_airq/features/devices/providers/device_provider.dart';
import 'package:tecnico_app_airq/features/tasks/providers/task_provider.dart';
import 'package:tecnico_app_airq/core/theme/app_theme.dart';

class ProvisioningScreen extends StatefulWidget {
  final String macId; // Usaremos esto como serialNumber
  const ProvisioningScreen({super.key, required this.macId});

  @override
  State<ProvisioningScreen> createState() => _ProvisioningScreenState();
}

class _ProvisioningScreenState extends State<ProvisioningScreen> {
  final _campusController = TextEditingController();
  final _locationController = TextEditingController();
  final _macController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCampus;
  int? _selectedClientId;

  @override
  void initState() {
    super.initState();
    _macController.text = widget.macId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<DeviceProvider>(context, listen: false)
            .fetchClients(authProvider.token!);
      }
    });
  }

  void _handleProvisioning() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona un cliente'), backgroundColor: AppTheme.error),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);

      final selectedClient = deviceProvider.clients.firstWhere((c) => c['id'] == _selectedClientId, orElse: () => {});
      final hasCampuses = selectedClient['campuses'] != null && (selectedClient['campuses'] as List).isNotEmpty;
      final campusValue = hasCampuses ? _selectedCampus! : _campusController.text.trim();

      final success = await deviceProvider.provisionDevice(
        token: authProvider.token!,
        serialNumber: _macController.text.trim(),
        campus: campusValue,
        location: _locationController.text.trim(),
        clientId: _selectedClientId!,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sensor vinculado correctamente'), backgroundColor: AppTheme.success),
          );
          Provider.of<TaskProvider>(context, listen: false).fetchPendingTasks(authProvider.token!);
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No se pudo vincular el sensor'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);
    
    // Check campuses for selected client
    final selectedClient = _selectedClientId != null 
        ? deviceProvider.clients.firstWhere((c) => c['id'] == _selectedClientId, orElse: () => {}) 
        : null;
    final List<dynamic> clientCampuses = selectedClient != null && selectedClient['campuses'] != null 
        ? selectedClient['campuses'] as List<dynamic> 
        : [];

    return Scaffold(
      appBar: AppBar(title: const Text('Vincular Sensor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _macController,
                inputFormatters: [MacAddressFormatter()],
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'S/N (MAC) del Sensor',
                  hintText: 'Ej: 00:1B:44:11:3A:B7',
                  prefixIcon: const Icon(Icons.qr_code, color: AppTheme.primaryBlue),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () async {
                      final scannedMac = await Navigator.pushNamed(context, '/scan') as String?;
                      if (scannedMac != null && scannedMac.isNotEmpty) {
                        setState(() {
                          _macController.text = scannedMac;
                        });
                      }
                    },
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'El S/N es obligatorio' : null,
              ),
              const SizedBox(height: 32),
              const Text("Asignar a Empresa", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              deviceProvider.isLoadingClients
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      value: _selectedClientId,
                      decoration: const InputDecoration(
                        labelText: 'Selecciona la empresa cliente',
                        prefixIcon: Icon(Icons.business),
                      ),
                      items: deviceProvider.clients.map((client) {
                        final companyName = client['companyName'] ?? 'Sin Empresa';
                        return DropdownMenuItem<int>(
                          value: client['id'] as int,
                          child: Text(companyName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClientId = value;
                          _selectedCampus = null;
                          _campusController.clear();
                        });
                      },
                      validator: (val) => val == null ? 'Debes seleccionar un cliente' : null,
                    ),
              const SizedBox(height: 32),
              const Text("Detalles de la instalación", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (clientCampuses.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedCampus,
                  decoration: const InputDecoration(
                    labelText: 'Sede (Campus)',
                    prefixIcon: Icon(Icons.domain),
                  ),
                  items: clientCampuses.map((campus) {
                    return DropdownMenuItem<String>(
                      value: campus.toString(),
                      child: Text(campus.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCampus = value;
                    });
                  },
                  validator: (val) => val == null ? 'Selecciona una sede' : null,
                )
              else
                TextFormField(
                  controller: _campusController,
                  decoration: const InputDecoration(
                    labelText: 'Sede (Campus)',
                    hintText: 'Ej: Sede Primaria, Sede Norte...',
                    prefixIcon: Icon(Icons.domain),
                  ),
                  validator: (val) => val!.isEmpty ? 'La sede es obligatoria' : null,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Aula / Ubicación específica',
                  hintText: 'Ej: Aula 302, Pasillo...',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (val) => val!.isEmpty ? 'La ubicación es obligatoria' : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: deviceProvider.isProvisioning ? null : _handleProvisioning,
                child: deviceProvider.isProvisioning
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('REGISTRAR SENSOR'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class MacAddressFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-alphanumeric characters and convert to uppercase
    String text = newValue.text.replaceAll(RegExp(r'[^A-Fa-f0-9]'), '').toUpperCase();
    
    // Limit to 12 hex digits (6 pairs)
    if (text.length > 12) {
      text = text.substring(0, 12);
    }
    
    // Insert colons
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      formatted += text[i];
      if ((i % 2 == 1) && (i != text.length - 1)) {
        formatted += ':';
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
