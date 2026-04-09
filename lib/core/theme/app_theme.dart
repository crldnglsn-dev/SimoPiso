import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final TextTheme base = ThemeData.dark(useMaterial3: true).textTheme;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.emerald,
      secondary: AppColors.amber,
      surface: AppColors.surface,
      error: AppColors.red,
    ),
    textTheme: base.copyWith(
      displaySmall: GoogleFonts.syne(
        textStyle: base.displaySmall,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.syne(
        textStyle: base.headlineMedium,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.syne(
        textStyle: base.headlineSmall,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.syne(
        textStyle: base.titleLarge,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.dmSans(
        textStyle: base.titleMedium,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.dmSans(
        textStyle: base.bodyLarge,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.dmSans(
        textStyle: base.bodyMedium,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.dmSans(
        textStyle: base.labelLarge,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.syne(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.emerald),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.emerald,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceAlt,
      selectedColor: AppColors.emerald.withValues(alpha: 0.2),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      labelStyle: GoogleFonts.dmSans(color: AppColors.textPrimary),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.emerald,
      foregroundColor: AppColors.background,
    ),
  );
}
