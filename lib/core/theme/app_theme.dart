import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class ChronicleTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paperBackgroundLight,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.inkPrimaryLight,
        onPrimary: AppColors.paperCardLight,
        secondary: AppColors.vintageGold,
        onSecondary: AppColors.paperCardLight,
        error: AppColors.postalStampRed,
        onError: Colors.white,
        surface: AppColors.paperSurfaceLight,
        onSurface: AppColors.inkPrimaryLight,
        outline: AppColors.paperCardBorderLight,
      ),
      textTheme: AppTypography.textTheme(
        AppColors.inkPrimaryLight,
        AppColors.inkSecondaryLight,
        AppColors.inkMutedLight,
      ),
      cardTheme: CardThemeData(
        color: AppColors.paperCardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.paperCardBorderLight,
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paperBackgroundLight,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.inkPrimaryLight),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.serifFamily,
          color: AppColors.inkPrimaryLight,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.paperSurfaceLight,
        indicatorColor: AppColors.paperCardBorderLight.withAlpha(128),
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: AppTypography.serifFamily,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.bold
                : FontWeight.normal,
            color: states.contains(WidgetState.selected)
                ? AppColors.inkPrimaryLight
                : AppColors.inkSecondaryLight,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.paperBackgroundDark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.inkPrimaryDark,
        onPrimary: AppColors.paperBackgroundDark,
        secondary: AppColors.vintageGold,
        onSecondary: AppColors.paperBackgroundDark,
        error: AppColors.postalStampRed,
        onError: Colors.white,
        surface: AppColors.paperSurfaceDark,
        onSurface: AppColors.inkPrimaryDark,
        outline: AppColors.paperCardBorderDark,
      ),
      textTheme: AppTypography.textTheme(
        AppColors.inkPrimaryDark,
        AppColors.inkSecondaryDark,
        AppColors.inkMutedDark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.paperCardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.paperCardBorderDark,
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paperBackgroundDark,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.inkPrimaryDark),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.serifFamily,
          color: AppColors.inkPrimaryDark,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.paperSurfaceDark,
        indicatorColor: AppColors.paperCardBorderDark,
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: AppTypography.serifFamily,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.bold
                : FontWeight.normal,
            color: states.contains(WidgetState.selected)
                ? AppColors.inkPrimaryDark
                : AppColors.inkSecondaryDark,
          ),
        ),
      ),
    );
  }
}
