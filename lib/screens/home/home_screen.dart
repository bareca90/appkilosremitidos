import 'package:appkilosremitidos/core/constants/app_colors.dart';
import 'package:appkilosremitidos/core/constants/app_routes.dart';
import 'package:appkilosremitidos/core/constants/app_strings.dart';
import 'package:appkilosremitidos/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/menu_card.dart';
import 'widgets/logout_button.dart';
import 'widgets/user_info_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: CustomScrollView(
        slivers: [
          // AppBar con efecto de curvatura
          SliverAppBar(
            expandedHeight: 80.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                AppStrings.appName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color.fromARGB(255, 250, 249, 249),
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryBlue,
                          // Color.fromARGB(255, 155, 168, 180),
                        ],
                      ),
                    ),
                  ),
                  const _CurvedBackground(),
                ],
              ),
            ),
            actions: const [LogoutButton()],
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Información del usuario
                  const UserInfoHeader(),

                  const SizedBox(height: 30),

                  // Tarjetas de menú
                  MenuCard(
                    title: AppStrings.registerKilos,
                    icon: Icons.scale,
                    color: AppColors.primaryBlue,
                    onTap: () {
                      // Navegar a pantalla de registro de kilos
                      Navigator.pushNamed(context, AppRoutes.materialPescaList);
                    },
                  ),
                  const SizedBox(height: 20),
                  MenuCard(
                    title: AppStrings.registerHours,
                    icon: Icons.access_time_filled,
                    color: AppColors.primaryRed,
                    onTap: () {
                      // Navegar a pantalla de registro de horas
                      Navigator.pushNamed(
                        context,
                        AppRoutes.fishingDataList,
                        arguments: {'option': 'GSG', 'isKilosScreen': false},
                      );
                    },
                  ),

                  // Espacio adicional al final
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Fondo curvo para el AppBar
class _CurvedBackground extends StatelessWidget {
  const _CurvedBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: _BottomWaveClipper(),
        child: Container(height: 30, color: AppColors.lightGray),
      ),
    );
  }
}

// Clipper para la forma de onda
class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 4,
      size.height - 10,
      size.width / 2,
      size.height,
    );
    path.quadraticBezierTo(
      3 / 4 * size.width,
      size.height + 10,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
