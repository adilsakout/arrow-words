import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF2266DD),
        secondary: const Color(0xFF66A6FF),
        surface: const Color(0xFFFDFCF9),
        onSurface: const Color(0xFF141414),
        error: const Color(0xFFD14343),
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      cardColor: Colors.white,
      textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF7CA9FF),
        secondary: const Color(0xFF4DD0E1),
        surface: const Color(0xFF121420),
        onSurface: const Color(0xFFEEF2FF),
        error: const Color(0xFFFF6B6B),
      ),
      scaffoldBackgroundColor: const Color(0xFF0C0F16),
      cardColor: const Color(0xFF1E2230),
      textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
    );
  }

  static ThemeData highContrast() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.black,
        secondary: const Color(0xFFFFB703),
        surface: Colors.white,
        onSurface: Colors.black,
        error: const Color(0xFFB00020),
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      textTheme: base.textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
    );
  }
}
