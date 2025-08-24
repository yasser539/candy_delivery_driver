import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class AppTheme {
  static ThemeData lightFor(String language) => ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Rubik',
    primarySwatch: Colors.purple,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: DesignSystem.textPrimary),
      titleTextStyle: TextStyle(
        fontFamily: 'Rubik',
        fontSize: 18,
        fontWeight: language == 'ar' ? FontWeight.w900 : FontWeight.bold,
        color: DesignSystem.textPrimary,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Rubik',
        fontWeight: language == 'ar' ? FontWeight.w900 : null,
        color: DesignSystem.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Rubik',
        fontWeight: language == 'ar' ? FontWeight.w900 : null,
        color: DesignSystem.textPrimary,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Rubik',
        fontWeight: language == 'ar' ? FontWeight.w900 : null,
        color: DesignSystem.textPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Rubik',
        fontWeight: language == 'ar' ? FontWeight.w900 : null,
        color: DesignSystem.textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Rubik',
        fontWeight: language == 'ar' ? FontWeight.w900 : null,
        color: DesignSystem.textPrimary,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Rubik',
        fontWeight: language == 'ar' ? FontWeight.w900 : null,
        color: DesignSystem.textPrimary,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Rubik',
        fontWeight: language == 'ar' ? FontWeight.w900 : null,
        color: DesignSystem.textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Rubik',
        fontWeight: language == 'ar' ? FontWeight.w900 : null,
        color: DesignSystem.textPrimary,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Rubik',
        fontWeight: language == 'ar' ? FontWeight.w900 : null,
        color: DesignSystem.textPrimary,
      ),
    ),
  );

  static ThemeData darkFor(String language) {
    // Use pitch black from DesignSystem for true dark mode
    const background = DesignSystem.darkBackground;
    const surface = DesignSystem.darkSurface;
    const onSurface = DesignSystem.darkTextPrimary;

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Rubik',
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6B46C1),
        secondary: Color(0xFF3B82F6),
        background: background,
        surface: surface,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: 'Rubik',
          fontSize: 18,
          fontWeight: language == 'ar' ? FontWeight.w900 : FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(color: surface, elevation: 0),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: background,
        modalBackgroundColor: surface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: background,
        surfaceTintColor: surface,
        titleTextStyle: TextStyle(
          fontFamily: 'Rubik',
          fontSize: 18,
          fontWeight: language == 'ar' ? FontWeight.w900 : FontWeight.bold,
          color: Colors.white,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Rubik',
          fontWeight: language == 'ar' ? FontWeight.w900 : null,
          color: onSurface,
          fontSize: 14,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontFamily: 'Rubik',
          fontWeight: language == 'ar' ? FontWeight.w700 : null,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Rubik',
          fontWeight: language == 'ar' ? FontWeight.w700 : null,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Rubik',
          fontWeight: language == 'ar' ? FontWeight.w700 : null,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Rubik',
          fontWeight: language == 'ar' ? FontWeight.w900 : null,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Rubik',
          fontWeight: language == 'ar' ? FontWeight.w900 : null,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Rubik',
          fontWeight: language == 'ar' ? FontWeight.w900 : null,
          color: Colors.white,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Rubik',
          fontWeight: language == 'ar' ? FontWeight.w800 : null,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Rubik',
          fontWeight: language == 'ar' ? FontWeight.w800 : null,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Rubik',
          fontWeight: language == 'ar' ? FontWeight.w800 : null,
          color: Colors.white,
        ),
      ),
    );
  }
}
