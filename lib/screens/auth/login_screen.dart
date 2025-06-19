import 'dart:math';

import 'package:appkilosremitidos/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'widgets/login_form.dart';
import 'widgets/logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1, curve: Curves.elasticOut),
      ),
    );

    // Iniciar animación después del primer frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // ignore: unused_local_variable
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Fondo animado
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        // ignore: deprecated_member_use
                        const Color.fromARGB(
                          255,
                          107,
                          110,
                          110,
                        ).withOpacity(_fadeAnimation.value),
                        // ignore: deprecated_member_use
                        const Color.fromARGB(
                          255,
                          141,
                          147,
                          158,
                        ).withOpacity(_fadeAnimation.value * 0.9),
                      ],
                    ),
                  ),
                ),
              ),

              // Contenido principal
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Texto "Bienvenido!" añadido
                        AnimatedOpacity(
                          opacity: _fadeAnimation.value,
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            'Bienvenido!',
                            style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
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
                        ),

                        // Texto "Inicie sesión" añadido
                        AnimatedOpacity(
                          opacity: _fadeAnimation.value,
                          duration: const Duration(milliseconds: 700),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30, top: 8),
                            child: Text(
                              'Inicie sesión',
                              style: textTheme.titleLarge?.copyWith(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const LogoWidget(),
                        const SizedBox(height: 40),
                        LoginForm(authProvider: authProvider),

                        // Copyright añadido en la parte inferior
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: AnimatedOpacity(
                            opacity: _fadeAnimation.value,
                            duration: const Duration(milliseconds: 900),
                            child: Text(
                              '© Promarisco Nueva Pescanova 2025',
                              style: textTheme.bodySmall?.copyWith(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Efecto de partículas (opcional)
              if (_animationController.isCompleted)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.15,
                      child: CustomPaint(painter: _ParticlesPainter()),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Pintor personalizado para partículas de fondo
class _ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(DateTime.now().millisecond);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final radius = rnd.nextDouble() * 2 + 1;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
