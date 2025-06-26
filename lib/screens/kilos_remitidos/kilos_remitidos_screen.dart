/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appkilosremitidos/core/constants/app_routes.dart';
import 'package:appkilosremitidos/core/providers/auth_provider.dart';
import 'package:appkilosremitidos/core/providers/kilos_provider.dart';
import 'kilos_list_screen.dart';

class KilosRemitidosScreen extends StatefulWidget {
  const KilosRemitidosScreen({super.key});

  @override
  State<KilosRemitidosScreen> createState() => _KilosRemitidosScreenState();
}

class _KilosRemitidosScreenState extends State<KilosRemitidosScreen> {
  late Future<void> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final kilosProvider = Provider.of<KilosProvider>(context, listen: false);

    if (authProvider.token == null) {
      throw Exception('Token de autenticación no disponible');
    }
    await kilosProvider.fetchKilosRemitidos(authProvider.token!, 'GSG');
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.token == null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Kilos Remitidos'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _handleRefresh,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return Consumer<KilosProvider>(
            builder: (context, kilosProvider, _) {
              if (kilosProvider.errorMessage != null &&
                  kilosProvider.kilosList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(kilosProvider.errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _handleRefresh,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _handleRefresh,
                child: const KilosListScreen(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No se encontró token de autenticación'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              child: const Text('Volver al login'),
            ),
          ],
        ),
      ),
    );
  }
}
 */
