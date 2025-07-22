import 'package:appkilosremitidos/models/material_pesca.dart';
import 'package:appkilosremitidos/screens/auth/login_screen.dart';
import 'package:appkilosremitidos/screens/home/home_screen.dart';
import 'package:appkilosremitidos/screens/fishing_data/fishing_data_list_screen.dart';
import 'package:appkilosremitidos/screens/material_pesca/material_pesca_form_screen.dart';
import 'package:appkilosremitidos/screens/material_pesca/material_pesca_list_screen.dart';
/* import 'package:appkilosremitidos/screens/material_pesca/material_pesca_detail_screen.dart'; */
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String fishingDataList = '/fishing-data-list';
  static const String materialPescaList = '/material-pesca-list';
  static const String materialPescaForm = '/material-pesca-form';
  static const String materialPescaDetail = '/material-pesca-detail';

  static final routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    materialPescaList: (context) => const MaterialPescaListScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case fishingDataList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => FishingDataListScreen(
            option: args?['option'] ?? 'GSK',
            isKilosScreen: args?['isKilosScreen'] ?? true,
          ),
        );
      case materialPescaForm:
        final data = settings.arguments as MaterialPesca;
        return MaterialPageRoute(
          builder: (_) => MaterialPescaFormScreen(data: data),
        );
      /* case materialPescaDetail:
        return MaterialPageRoute(
          builder: (_) => const MaterialPescaDetailScreen(material: null,),
        ); */
      default:
        return null;
    }
  }
}
