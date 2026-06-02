import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroTheme {
  // Brand Colors
  static const Color primary = Color(0xFFFFB77D);
  static const Color onPrimary = Color(0xFF4D2600);
  static const Color primaryContainer = Color(0xFFFF8C00);
  
  static const Color surface = Color(0xFF131313);
  static const Color onSurface = Color(0xFFE5E2E1);
  
  static const Color industrialSilver = Color(0xFFC0C0C0);
  static const Color retroOrange = Color(0xFFFF8C00);

  // Redundant but keeping consistency with my previous plan
  static const Color kPrimary = Color(0xFFFFB77D);
  static const Color kOnPrimary = Color(0xFF4D2600);
  static const Color kSurface = Color(0xFF131313);
  static const Color kSurfaceContainerLow = Color(0xFF1C1B1B);
  static const Color kSurfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color kIndustrialSilver = Color(0xFFC0C0C0);
  static const Color kRetroOrange = Color(0xFFFF8C00);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: kPrimary,
        onPrimary: kOnPrimary,
        surface: kSurface,
        onSurface: kIndustrialSilver,
        surfaceContainerLow: kSurfaceContainerLow,
        surfaceContainerLowest: kSurfaceContainerLowest,
        primaryContainer: kRetroOrange,
      ),
      scaffoldBackgroundColor: kSurface,
      fontFamily: 'Inter', // Define a fonte local como padrão
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: kPrimary,
          letterSpacing: 1.2,
        ),
        labelSmall: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: kIndustrialSilver.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
