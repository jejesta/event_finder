// lib/utils/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A42D6);
  static const Color secondary = Color(0xFFFF6584);
  static const Color accent = Color(0xFF43E97B);
  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF252540);
  static const Color cardBg = Color(0xFF1E1E35);
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF9090B0);
  static const Color textHint = Color(0xFF555577);
  static const Color divider = Color(0xFF2A2A4A);
  static const Color error = Color(0xFFFF4D6D);
  static const Color success = Color(0xFF43E97B);
  static const Color warning = Color(0xFFFFB347);

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'music': Color(0xFFFF6B9D),
    'sports': Color(0xFF43E97B),
    'technology': Color(0xFF6C63FF),
    'food': Color(0xFFFFB347),
    'art': Color(0xFFFF6584),
    'business': Color(0xFF4BC8E8),
    'education': Color(0xFFB388FF),
    'health': Color(0xFF69F0AE),
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? primary;
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        labelStyle: GoogleFonts.nunito(color: textSecondary),
        hintStyle: GoogleFonts.nunito(color: textSecondary),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: Color(0x4D6C63FF),
        labelStyle: GoogleFonts.nunito(color: textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: divider),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: GoogleFonts.nunito(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class AppConstants {
  static const Duration animDuration = Duration(milliseconds: 300);
  static const Duration animDurationLong = Duration(milliseconds: 600);
  static const Curve animCurve = Curves.easeOutCubic;
}
