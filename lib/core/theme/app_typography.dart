import 'package:flutter/material.dart';

class AppTypography {
  static const String serifFamily = 'serif';

  static TextTheme textTheme(
    Color inkPrimary,
    Color inkSecondary,
    Color inkMuted,
  ) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: serifFamily,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: inkPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontFamily: serifFamily,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: inkPrimary,
      ),
      displaySmall: TextStyle(
        fontFamily: serifFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: inkPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: serifFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: inkPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: serifFamily,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: inkPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: serifFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: inkPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: serifFamily,
        fontSize: 16,
        height: 1.6,
        color: inkPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: serifFamily,
        fontSize: 14,
        height: 1.5,
        color: inkSecondary,
      ),
      bodySmall: TextStyle(
        fontFamily: serifFamily,
        fontSize: 12,
        color: inkMuted,
      ),
      labelLarge: TextStyle(
        fontFamily: serifFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: inkPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: serifFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: inkSecondary,
      ),
    );
  }
}
