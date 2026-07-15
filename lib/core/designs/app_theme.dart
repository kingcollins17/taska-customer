import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1,
        displayMedium: AppTextStyles.heading2,
        displaySmall: AppTextStyles.heading3,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.label,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading3.copyWith(color: AppColors.onPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTextStyles.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentPurple,
        secondary: AppColors.accentOrange,
        surface: AppColors.darkBackground,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onPrimary,
        onSurface: AppColors.onPrimary,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(color: AppColors.onPrimary),
        displayMedium: AppTextStyles.heading2.copyWith(color: AppColors.onPrimary),
        displaySmall: AppTextStyles.heading3.copyWith(color: AppColors.onPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.onPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.onPrimary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.onPrimary),
        labelLarge: AppTextStyles.label.copyWith(color: AppColors.onPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading3.copyWith(color: AppColors.onPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPurple,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTextStyles.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
