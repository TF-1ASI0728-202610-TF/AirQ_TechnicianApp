import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tecnico_app_airq/features/tasks/models/task_model.dart';
import 'package:tecnico_app_airq/features/tasks/providers/task_provider.dart';
import 'package:tecnico_app_airq/features/auth/providers/auth_provider.dart';
import 'package:tecnico_app_airq/core/theme/app_theme.dart';

class TicketDetailScreen extends StatelessWidget {
  final TechTask ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Ticket'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Empresa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(ticket.clientName, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 12),
                      const Text('Correo Electrónico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(ticket.clientEmail, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                      const SizedBox(height: 12),
                      const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(ticket.category, style: const TextStyle(fontSize: 16, color: AppTheme.primaryBlue)),
                      const SizedBox(height: 12),
                      const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(ticket.issueDescription, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      const Text('Detalles del Dispositivo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(ticket.location, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      const Text('ID de Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(ticket.taskId, style: const TextStyle(fontSize: 16)),
                      const Spacer(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final taskProvider = context.read<TaskProvider>();
                            final authProvider = context.read<AuthProvider>();
                            final token = authProvider.token;
                            
                            if (token != null) {
                              bool success = await taskProvider.resolveTask(ticket.taskId, token);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ticket resuelto exitosamente')),
                                );
                                Navigator.pop(context);
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Error al resolver el ticket')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Marcar como Resuelto'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
