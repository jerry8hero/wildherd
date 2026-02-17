import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4CAF50); // 绿色，代表自然
  static const Color secondaryColor = Color(0xFF8BC34A); // 浅绿色
  static const Color accentColor = Color(0xFFFF9800); // 橙色，代表爬行动物
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE53935);

  // 宠物类别颜色
  static const Map<String, Color> categoryColors = {
    'snake': Color(0xFF7E57C2),     // 紫色 - 蛇
    'lizard': Color(0xFF4CAF50),    // 绿色 - 蜥蜴
    'turtle': Color(0xFF03A9F4),    // 蓝色 - 龟
    'gecko': Color(0xFFFF9800),     // 橙色 - 守宫
    'amphibian': Color(0xFF26A69A), // 青色 - 两栖
    'arachnid': Color(0xFFE91E63),  // 粉色 - 蜘蛛
    'insect': Color(0xFF8D6E63),    // 棕色 - 昆虫
    'mammal': Color(0xFFFFB74D),    // 橙色 - 哺乳动物
    'bird': Color(0xFF64B5F6),      // 浅蓝 - 鸟类
    'fish': Color(0xFF4DD0E1),      // 青色 - 鱼类
  };

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? primaryColor;
  }
}
