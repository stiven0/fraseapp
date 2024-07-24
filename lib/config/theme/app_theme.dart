import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const colorSeed = Color(0xff077187);
const scaffoldBackgroundColor = Color.fromARGB(255, 248, 247, 247);

class AppTheme {

  final bool isDarkMode;

  AppTheme({ this.isDarkMode = true });

  ThemeData getTheme() {
    return ThemeData(

      ///* General
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorSchemeSeed: colorSeed,
      fontFamily: GoogleFonts.montserratAlternates().fontFamily,

      ///* Texts
      textTheme: TextTheme(
        titleLarge: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 40, fontWeight: FontWeight.bold
        ),
        titleMedium: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 30, fontWeight: FontWeight.bold
        ),
        titleSmall: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 20
        ),
      ),

      scaffoldBackgroundColor: scaffoldBackgroundColor,

      ///* AppBar
      appBarTheme: AppBarTheme(
        color: scaffoldBackgroundColor,
        titleTextStyle: GoogleFonts.montserratAlternates().copyWith( 
          fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black 
        )
      ),

    );
  }

  AppTheme copyWith({ bool? isDarkMode }) {
    return AppTheme(
      isDarkMode: isDarkMode ?? this.isDarkMode
    );
  }

}