import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tecnico_app_airq/features/auth/providers/auth_provider.dart';
import 'package:tecnico_app_airq/features/settings/providers/security_provider.dart';
import 'package:tecnico_app_airq/core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final securityProvider = Provider.of<SecurityProvider>(context, listen: false);

      final success = await securityProvider.changePassword(
        token: authProvider.token!,
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contraseña actualizada correctamente'), backgroundColor: AppTheme.success),
          );
          _oldPasswordController.clear();
          _newPasswordController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: La contraseña actual es incorrecta'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Cambiar Contraseña Temporal',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _oldPasswordController,
                          decoration: const InputDecoration(labelText: 'Contraseña Actual'),
                          obscureText: true,
                          validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
                          obscureText: true,
                          validator: (val) => val!.length < 6 ? 'Mínimo 6 caracteres' : null,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: securityProvider.isLoading ? null : _handleChangePassword,
                          child: securityProvider.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Guardar Cambios'),
                        ),
                        const Spacer(),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout, color: AppTheme.error),
                          label: const Text('Cerrar Sesión', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ],
                    ),
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
