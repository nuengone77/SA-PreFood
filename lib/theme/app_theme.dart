import 'package:flutter/material.dart';

abstract final class AppColors {
  static const orange = Color(0xFFF47C48);
  static const orangeDark = Color(0xFFD95C2B);
  static const cream = Color(0xFFFFF8F1);
  static const green = Color(0xFF2F8064);
  static const ink = Color(0xFF27312E);
  static const muted = Color(0xFF75817D);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.light,
      primary: AppColors.orange,
      secondary: AppColors.green,
      surface: const Color(0xFFFFFCF9),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF0E5DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.orange.withValues(alpha: .16),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.orangeDark
                : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
