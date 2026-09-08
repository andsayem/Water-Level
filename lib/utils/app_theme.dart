import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => _base(Brightness.dark);

  static ThemeData get lightTheme => _base(Brightness.light);

  static ThemeData _base(Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
