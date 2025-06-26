import 'package:appkilosremitidos/core/providers/connectivity_provider.dart';
import 'package:appkilosremitidos/core/providers/fishing_data_provider.dart';
import 'package:appkilosremitidos/core/services/api_service.dart';
import 'package:appkilosremitidos/core/services/local_db_service.dart';
import 'package:appkilosremitidos/screens/fishing_data/repositories/fishing_data_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/constants/app_routes.dart';
import 'core/services/shared_prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsService.init();
  // Inicializa servicios
  final apiService = ApiService();
  final localDbService = LocalDbService();
  await localDbService.database;
  // Crea el repositorio
  final fishingRepository = FishingDataRepository(
    apiService: apiService,
    localDbService: localDbService,
  );
  // Inicializa providers
  final authProvider = AuthProvider();
  await authProvider.loadToken();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(
          create: (_) => FishingDataProvider(fishingRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Kilos Remitidos App',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
