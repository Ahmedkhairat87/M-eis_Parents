import 'package:eism/core/theme/liquid_glass_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppStyle {
  // ... rest of the class
  // Common Colors - Brand Colors
  static const Color primaryBlue = Color(0xFF1565C0); // blue.shade800
  static const Color primaryDarkBlue = Color(0xFF0D47A1); // blue.shade900
  static const Color lightBlueBg = Color(0xFFE3F2FD); // blue.shade50
  
  // Dark Mode Specialized Colors
  static const Color darkPrimaryBlue = Color(0xFF42A5F5); // blue.shade400 - Brighter for dark mode
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceElevated = Color(0xFF2C2C2C);
  
  // Accents
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentTeal = Color(0xFF26A69A);
  static const Color accentOrange = Color(0xFFFFA000);
  static const Color errorRed = Color(0xFFEF5350); // Lighter red for dark mode contrast

  // Gradient Colors
  static List<Color> lightGradient = [
    const Color(0xFFF0F4F8), 
    const Color(0xFFE1E8EE),
    const Color(0xFFD1D9E1),
  ];
  static List<Color> darkGradient = [
    const Color(0xFF1A1F25),
    const Color(0xFF121417),
    const Color(0xFF0D0F11),
  ];

  //==> Light Theme Starts Here <==//
  static ThemeData lightMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      onPrimary: Colors.white,
      secondary: accentTeal,
      surface: Colors.white.withValues(alpha: 0.7),
      error: const Color(0xFFD32F2F),
    ),
    extensions: const [
      LiquidGlassTheme(),
    ],
    scaffoldBackgroundColor: const Color(0xFFF0F4F8),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white.withValues(alpha: 0.3),
      elevation: 0,
      centerTitle: false,
      foregroundColor: primaryDarkBlue,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: primaryDarkBlue,
        fontWeight: FontWeight.bold,
        fontSize: 18.sp,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: primaryDarkBlue),
      titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: primaryDarkBlue),
      bodyLarge: TextStyle(fontSize: 16.sp, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14.sp, color: Colors.black54),
    ),
  );

  //==> Dark Theme Starts Here <==//
  static ThemeData darkMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: darkPrimaryBlue,
      onPrimary: Colors.black,
      secondary: accentTeal,
      surface: Colors.black.withValues(alpha: 0.4),
      onSurface: Colors.white,
      error: errorRed,
    ),
    extensions: const [
      LiquidGlassTheme(),
    ],
    scaffoldBackgroundColor: const Color(0xFF121417),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18.sp,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryBlue,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceElevated,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      hintStyle: TextStyle(color: Colors.white38, fontSize: 13.sp),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.white.withAlpha(30)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.white.withAlpha(30)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: darkPrimaryBlue, width: 2),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16.sp, color: Colors.white.withAlpha(230)),
      bodyMedium: TextStyle(fontSize: 14.sp, color: Colors.white70),
    ),
  );
}
