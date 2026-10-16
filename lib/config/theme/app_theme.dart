import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const colorSeed = Color(0xff077187);
const scaffoldBackgroundColor = Color(0xFFF8F7F7);
const scaffoldBackgroundColorDark = Color(0xFF121212);

class AppTheme {

  final bool isDarkMode;

  AppTheme({ this.isDarkMode = true });

  ThemeData getTheme() {
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colorSeed,
      brightness: brightness,
    );
    final scaffoldColor =
        isDarkMode ? scaffoldBackgroundColorDark : scaffoldBackgroundColor;
    final onScaffold = isDarkMode ? Colors.white : Colors.black87;
    final baseText = GoogleFonts.montserratAlternates();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: baseText.fontFamily,
      textTheme: TextTheme(
        titleLarge: baseText.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: onScaffold,
        ),
        titleMedium: baseText.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: onScaffold,
        ),
        titleSmall: baseText.copyWith(
          fontSize: 20,
          color: onScaffold,
        ),
        bodyMedium: baseText.copyWith(
          fontSize: 16,
          color: onScaffold,
        ),
      ),
      scaffoldBackgroundColor: scaffoldColor,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldColor,
        foregroundColor: onScaffold,
        elevation: 0,
        titleTextStyle: baseText.copyWith(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: onScaffold,
        ),
        iconTheme: IconThemeData(color: onScaffold),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: baseText.copyWith(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return baseText.copyWith(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          );
        }),
      ),
    );
  }

  AppTheme copyWith({ bool? isDarkMode }) {
    return AppTheme(
      isDarkMode: isDarkMode ?? this.isDarkMode
    );
  }

}
