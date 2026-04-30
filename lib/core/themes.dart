import 'package:flutter/material.dart';
import 'constants.dart';

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Color.fromARGB(255, 255, 255, 255),
    foregroundColor: Color.fromARGB(255, 0, 0, 0),
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(AppSizes.radiusM),
    ),
    color: const Color.fromARGB(255, 0, 38, 255),
  ),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: AppColors.bgDark,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.bgDark,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(AppSizes.radiusM),
    ),
    color: const Color(0xFF2C2C3C),
  ),
);
