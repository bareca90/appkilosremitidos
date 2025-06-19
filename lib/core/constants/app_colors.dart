import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed = Color.fromRGBO(214, 0, 28, 1);
  static const Color primaryBlue = Color.fromRGBO(0, 88, 124, 1);
  static const Color lightGray = Color.fromRGBO(248, 248, 248, 1);
  static const Color darkGray = Color.fromRGBO(100, 100, 100, 1);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color.fromARGB(255, 157, 168, 172), white],
  );
}
