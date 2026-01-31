import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = _buildTheme(Brightness.light);
  static ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseColors = isDark 
        ? const ColorScheme.dark(
            primary: AppColors.primaryPurple,
            secondary: AppColors.primaryBlue,
            surface: AppColors.darkSurface,
            error: AppColors.error,
            background: AppColors.darkBg,
          )
        : const ColorScheme.light(
            primary: AppColors.primaryPurple,
            secondary: AppColors.primaryBlue,
            surface: AppColors.white,
            error: AppColors.error,
            background: AppColors.gray50,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      primaryColor: AppColors.primaryPurple,
      colorScheme: baseColors,

      // TEXT STYLES
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkText : AppColors.gray900,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.gray900,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.gray900,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: isDark ? AppColors.gray300 : AppColors.gray700,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: isDark ? AppColors.gray500 : AppColors.gray500,
        ),
      ),

      // BUTTON THEME
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),

      // INPUT THEME
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
