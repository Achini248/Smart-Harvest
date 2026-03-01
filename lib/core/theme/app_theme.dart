import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF7BA53D);
  static const Color background = Color(0xFFF7F7F7);
  static const Color surface = Colors.white;
  static const Color divider = Color(0xFFEEEEEE);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      
      // Material 3 භාවිතා කිරීම වඩාත් සුදුසුයි අලුත් Apps වලට
      useMaterial3: true, 

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),

      // මෙතන තිබුණු error එක විසඳන්න CardThemeData ලෙස භාවිතා කළා
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        margin: const EdgeInsets.all(0), // Default margin එක අයින් කළා
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),

      // AppBar එකේ පෙනුම නිවැරදි කිරීම
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}