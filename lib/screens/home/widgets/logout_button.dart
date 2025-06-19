import 'package:appkilosremitidos/core/constants/app_strings.dart';
import 'package:appkilosremitidos/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: AppStrings.logout,
      onPressed: () async {
        final shouldLogout = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro que deseas cerrar tu sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (shouldLogout == true) {
          final authProvider = Provider.of<AuthProvider>(
            // ignore: use_build_context_synchronously
            context,
            listen: false,
          );
          await authProvider.logout();
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
    );
  }
}
