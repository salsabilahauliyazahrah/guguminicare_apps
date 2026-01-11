import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.orangeMedium,      // #FB9E3A dari palet
      onPrimary: AppColors.white,
      primaryContainer: AppColors.creamLight,
      secondary: AppColors.redVibrant,       // #EA2F14 dari palet
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.black,           // Gray gelap
      background: AppColors.white, // Background cream
      onBackground: AppColors.black,
      error: AppColors.redVibrant,           // Gunakan merah dari palet
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.white, // Background cream
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.titleLarge,
      iconTheme: IconThemeData(color: AppColors.orangeMedium),
      toolbarTextStyle: TextStyle(color: AppColors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orangeMedium, // Orange dari palet
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: AppTextStyles.button,
        shadowColor: AppColors.orangeMedium.withOpacity(0.3),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.orangeMedium,
        side: const BorderSide(color: AppColors.orangeMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.orangeMedium),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.orangeMedium,
        textStyle: AppTextStyles.button.copyWith(color: AppColors.orangeMedium),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey200,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey500),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey400), // Cream
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.orangeMedium, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.redVibrant), // Merah dari palet
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.grey700,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.grey600,
      ),
      floatingLabelStyle: TextStyle(
        color: AppColors.orangeMedium,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.grey300, width: 1),
      ),
      margin: EdgeInsets.zero,
      surfaceTintColor: AppColors.creamLight,
    ),
    dialogTheme: DialogThemeData( 
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      titleTextStyle: AppTextStyles.titleLarge,
      contentTextStyle: AppTextStyles.bodyMedium,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.creamYellow.withOpacity(0.3),
      selectedColor: AppColors.orangeMedium,
      labelStyle: const TextStyle(
        color: AppColors.black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      checkmarkColor: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.creamYellow, // Cream untuk divider
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.orangeMedium,
      foregroundColor: AppColors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.orangeMedium,
      unselectedItemColor: AppColors.grey700,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.creamLight,
      labelTextStyle: MaterialStateProperty.all(
        AppTextStyles.labelMedium,
      ),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: AppColors.white,
      iconColor: AppColors.orangeMedium,
      textColor: AppColors.black,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.orangeMedium,
      linearTrackColor: AppColors.creamYellow,
    ),
  );

  // Dark theme (opsional - disesuaikan)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.creamYellow,        // Cream untuk dark mode
      onPrimary: AppColors.black,
      primaryContainer: Color(0xFF5D4037),
      secondary: AppColors.orangeRed,        // Orange kemerahan
      onSecondary: AppColors.black,
      surface: Color(0xFF1E1E1E),
      onSurface: AppColors.grey400,
      background: Color(0xFF121212),
      onBackground: AppColors.grey400,
      error: Color(0xFFCF6679),
      onError: AppColors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.creamYellow,
      ),
      iconTheme: IconThemeData(color: AppColors.creamYellow),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}