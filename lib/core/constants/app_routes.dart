import 'package:appkilosremitidos/screens/auth/login_screen.dart';
import 'package:appkilosremitidos/screens/home/home_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';

  static final routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
  };
}
