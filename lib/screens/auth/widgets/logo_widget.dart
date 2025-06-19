import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.white, Color(0xFFE0E0E0)],
        ),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const RadialGradient(
            center: Alignment.center,
            colors: [AppColors.primaryBlue, Color(0xFF003350)],
            radius: 0.75,
          ).createShader(bounds),
          child: const Text(
            'P',
            style: TextStyle(
              fontSize: 70,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Este color será reemplazado por el shader
            ),
          ),
        ),
      ),
    );
  }
}
