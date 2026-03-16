import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark  => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg      = isDark ? AppColors.backgroundDark  : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark     : AppColors.surface;
    final text1   = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final borderC = isDark ? AppColors.borderDark      : AppColors.border;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary:    AppColors.primary,
        onPrimary:  Colors.white,
        secondary:  AppColors.secondary,
        onSecondary: Colors.white,
        error:      AppColors.error,
        onError:    Colors.white,
        surface:    surface,
        onSurface:  text1,
        background: bg,
        onBackground: text1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text1,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: text1,
          fontFamily: 'Inter',
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textTertiary,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.textTertiary,
            size: 24,
          );
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderC, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderC),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderC),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
        floatingLabelStyle: const TextStyle(color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Inter',
          ),
          elevation: 0,
        ),
      ),
      textTheme: TextTheme(
        displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: text1, fontFamily: 'Inter'),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: text1, fontFamily: 'Inter'),
        titleLarge:    TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: text1, fontFamily: 'Inter'),
        titleMedium:   TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: text1, fontFamily: 'Inter'),
        bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: text1, fontFamily: 'Inter'),
        bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary, fontFamily: 'Inter'),
        labelMedium:   TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: text1, fontFamily: 'Inter'),
        bodySmall:     TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary, fontFamily: 'Inter'),
      ),
      dividerTheme: DividerThemeData(color: borderC, thickness: 0.5, space: 0),
      splashColor: AppColors.primaryLight,
      highlightColor: Colors.transparent,
    );
  }
}
