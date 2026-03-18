import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7BA53D);
  static const Color background = Color(0xFFF7F7F7);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      
      // මෙන්න මෙතනයි වැරැද්ද තිබුණේ. CardThemeData ලෙස තිබිය යුතුයි.
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}