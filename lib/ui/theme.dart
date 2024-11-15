import 'package:flutter/material.dart';

class AppColors {
  static const Color blue = Color(0xFF187FFB); // Blue
  static const Color blackBackground = Color(0xFF171717); // Black_Background
  static const Color blackNavigation = Color(0xFF242424); // Black_Navigation
  static const Color blackCasellaN = Color(0xFF1B1B1B); // Black_casellaN
  static const Color grayGriglia = Color(0xFF909090); // Gray_griglia
  static const Color grayGrigliaN = Color(0xFF555555); // Gray_grigliaN
  static const Color white30 = Color.fromARGB(30, 255, 255, 255); // white30
  static const Color grayText = Color(0xFF5D5D5D); // Gray_Text
  static const Color blueAg = Color(0xFF184F8C); // Blue_Ag
  static const Color blackBack = Color(0xFF171717); // Black_Back
  static const Color blackDialog = Color(0xFF292929); // Black_Dialog
  static const Color blackDialog1 = Color(0xFF1D1D1D); // Black_Dialog_1
  static const Color blackWhite = Color.fromARGB(13, 255, 255, 255); // Black_White
  static const Color blackAgenda = Color(0xDFFFFFF); // Black_Agenda
  static const Color green = Color(0xFF196519); // Green
  static const Color red = Color(0xFFFF0000); // Red
}

    final ThemeData darkTheme = ThemeData(

      fontFamily: 'Outfit-Regular',

      brightness: Brightness.dark,
      primaryColor: AppColors.blue, // Colore principale (sfondo bottone)
      scaffoldBackgroundColor: AppColors.blackBackground, // Sfondo dell'app
      colorScheme: ColorScheme.dark(
        primary: AppColors.blue, // Colore principale
        onPrimary: Colors.white, // Testo sopra il colore primario

        secondary: Colors.white, // Colore secondario
        onSecondary: Colors.black, // Testo sopra il secondario

        tertiary: Colors.white, // Colore terziario
        onTertiary: Colors.black, // Testo sopra il terziario

        background: Colors.white, // Colore di sfondo generale
        onBackground: Colors.white, // Testo sopra lo sfondo

        surface: Colors.white, // Colore delle superfici
        onSurface: Colors.black, // Testo sopra le superfici

        surfaceVariant: Colors.white, // Sfondo dei TextField
        onSurfaceVariant: Colors.grey, // Testo delle label dei TextField

        error: AppColors.red, // Colore per gli errori
        onError: Colors.white, // Testo sopra gli errori

        inverseSurface: Colors.grey.shade800, // Superficie inversa
        onInverseSurface: Colors.white, // Testo sopra la superficie inversa
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.blackNavigation, // Sfondo AppBar
        foregroundColor: Colors.white, // Testo su AppBar
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.green, // Colore per il FloatingActionButton
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.blue, // Colore dei bottoni
        textTheme: ButtonTextTheme.primary, // Testo dei bottoni
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blackCasellaN, // Sfondo dei TextField
        labelStyle: TextStyle(color: AppColors.grayGrigliaN), // Colore delle label dei TextField
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Forma degli Input
        ),
      ),

      textTheme: TextTheme(

        bodyLarge: TextStyle(color: AppColors.grayText), // Per testi principali
        bodyMedium: TextStyle(color: AppColors.grayGriglia), // Per testi secondari
      ),

      dialogTheme: DialogTheme(
        backgroundColor: AppColors.blackDialog, // Colore di sfondo del dialog
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit-Regular',
          color: Colors.white, // Colore del titolo
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Outfit-Regular',
          color: AppColors.grayText, // Colore del testo contenuto
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40), // Forma del dialog
        ),
      ),


      cardTheme: CardTheme(
        color: AppColors.blackDialog, // Colore di sfondo delle Card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Forma delle Card
        ),
      ),
    );
