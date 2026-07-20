import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        elevation: 0,
      ),
    ),

    // InputDecoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
      hintStyle: const TextStyle(color: AppColors.textHint, fontFamily: 'Inter', fontSize: 14),
    ),

    // BottomNavigationBar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      selectedLabelStyle: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontFamily: 'Inter', fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      space: 1,
      thickness: 1,
    ),

    // Text
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineLarge: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineMedium: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      headlineSmall: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
      bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textHint),
      labelLarge: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  static ThemeData get instructorTheme => light.copyWith(
        scaffoldBackgroundColor: AppColors.instructorBackground,
      );

  static ThemeData get learnerTheme => light.copyWith(
        scaffoldBackgroundColor: AppColors.learnerBackground,
      );
}
