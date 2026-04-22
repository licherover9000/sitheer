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
    backgroundColor: Color.fromARGB(255, 0, 0, 0),
    foregroundColor: Color.fromARGB(255, 93, 0, 255),
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(AppSizes.radiusM),
    ),
    color: AppColors.surface,
  ),
);
