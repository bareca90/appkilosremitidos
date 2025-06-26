import 'package:appkilosremitidos/screens/auth/login_screen.dart';
import 'package:appkilosremitidos/screens/home/home_screen.dart';
import 'package:appkilosremitidos/screens/fishing_data/fishing_data_list_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String fishingDataList = '/fishing-data-list';

  static final routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case fishingDataList:
        return MaterialPageRoute(
          builder: (_) => FishingDataListScreen(
            option: args?['option'] ?? 'GSK',
            isKilosScreen: args?['isKilosScreen'] ?? true,
          ),
        );
      default:
        return null;
    }
  }
}
