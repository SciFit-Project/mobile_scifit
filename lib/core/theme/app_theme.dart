import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _primaryDark = Color(0xFFE8FF47);
  static const _backgroundDark = Color(0xFF0A0A0A);
  static const _surfaceDark = Color(0xFF141414);
  static const _surfaceVariantDark = Color(0xFF1E1E1E);
  static const _onSurfaceDark = Color(0xFFEEEEEE);
  static const _mutedDark = Color(0xFF666666);

  static const _primaryLight = Color(0xFF3579E5);
  static const _backgroundLight = Color(0xFFF5F5F5);
  static const _surfaceLight = Color(0xFF141414);
  static const _surfaceVariantLight = Color(0xFF1E1E1E);
  static const _onSurfaceLight = Color(0xFFEEEEEE);
  static const _mutedLight = Color(0xFF666666);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: _primaryDark,
      onPrimary: Color(0xFF0A0A0A),
      background: _backgroundDark,
      surface: _surfaceDark,
      onSurface: _onSurfaceDark,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme().apply(
      bodyColor: _onSurfaceDark,
      displayColor: _onSurfaceDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _surfaceDark,
        foregroundColor: _onSurfaceDark,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _surfaceVariantDark, width: 1),
        ),
        elevation: 0,
      ),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: _primaryLight,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF0A0A0A),
    ),

    textTheme: GoogleFonts.spaceGroteskTextTheme().apply(
      bodyColor: const Color(0xFF0A0A0A),
      displayColor: const Color(0xFF0A0A0A),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    ),
  );

  // Expose colors for use in widgets
  static const primaryDark = _primaryDark;
  static const backgroundDark = _backgroundDark;
  static const surfaceDark = _surfaceDark;
  static const surfaceVariantDark = _surfaceVariantDark;
  static const mutedDark = _mutedDark;

  // Light
  static const primaryLight = _primaryLight;
  static const backgroundLight = _backgroundLight;
  static const surfaceLight = _surfaceLight;
  static const onsurfaceLight = _onSurfaceLight;
  static const surfaceVariantLight = _surfaceVariantLight;
  static const mutedLight = _mutedLight;
}
