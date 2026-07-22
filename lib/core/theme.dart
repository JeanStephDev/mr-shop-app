import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette reprise directement du logo MR Shop.
class AppColors {
  static const peach = Color(0xFFF4B183);
  static const peachLight = Color(0xFFFBE3CC);
  static const navy = Color(0xFF0E3A4C);
  static const navySoft = Color(0xFF3D6273);
  static const blue = Color(0xFF2AA9D8);
  static const yellow = Color(0xFFF2B705);
  static const orange = Color(0xFFEF7B2E);
  static const cream = Color(0xFFFBF7F2);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.orange,
        secondary: AppColors.blue,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineSmall: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: AppColors.navy),
        headlineMedium: GoogleFonts.fredoka(fontWeight: FontWeight.w700, color: AppColors.navy),
        titleLarge: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: AppColors.navy),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
