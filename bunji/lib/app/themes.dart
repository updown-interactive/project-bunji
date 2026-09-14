import 'package:flutter/material.dart';

abstract class AppColors {
    // Theme Base & Accents
  static const Color primary = Color(0xFFC53032);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFE63446);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFCC344A);
  static const Color onError = Color(0xFFFFFFFF);

  // Surface & Neutrals
  static const Color lightSurface = Color(0xFFEAECED);
  static const Color lightSurfaceContainer = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF0F0F0F);

  static const Color darkSurface = Color(0xFF0F0F0F);
  static const Color darkSurfaceContainer = Color(0xFF000000);
  static const Color darkOnSurface = Color(0xFFEAECED);

  // Common Constants
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
}



final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightSurface,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    error: AppColors.error,
    onError: AppColors.onError,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    surfaceContainer: AppColors.lightSurfaceContainer,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkSurface,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    error: AppColors.error,
    onError: AppColors.onError,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    surfaceContainer: AppColors.darkSurfaceContainer,
  ),
);
