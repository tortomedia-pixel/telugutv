import 'package:flutter/material.dart';

class Brand {
  static const purpleDark = Color(0xFF1C0636);
  static const purple = Color(0xFF5B1F8F);
  static const gold = Color(0xFFF2B705);
  static const ink = Color(0xFF1C1C1C);
  static const muted = Color(0xFF6B6B6B);
  static const bg = Color(0xFFF3F3F3);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Brand.purple,
      primary: Brand.purple,
      secondary: Brand.gold,
    ),
    scaffoldBackgroundColor: Brand.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Brand.purpleDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Brand.gold.withOpacity(.35),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
