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
    // 蛇类
    'corn_snake': Color(0xFFFF7043),
    'ball_python': Color(0xFF5C6BC0),
    'black_kingsnake': Color(0xFF424242),
    'milk_snake': Color(0xFFEF5350),
    'hognose_snake': Color(0xFF8D6E63),
    // 守宫
    'leopard_gecko': Color(0xFFFFB300),
    'crested_gecko': Color(0xFFFF8A65),
    // 蜥蜴
    'bearded_dragon': Color(0xFF8BC34A),
    'green_iguana': Color(0xFF66BB6A),
    'blue_tongue_skink': Color(0xFF78909C),
    'veiled_chameleon': Color(0xFF26A69A),
    // 龟类
    'chinese_turtle': Color(0xFF29B6F6),
    'red_eared_slider': Color(0xFF26C6DA),
    'yellow_marginated_box_turtle': Color(0xFFFFCA28),
    'keeled_box_turtle': Color(0xFF8D6E63),
    'radiated_tortoise': Color(0xFF9CCC65),
    'hermanns_tortoise': Color(0xFFFFEE58),
    // 两栖
    'pacman_frog': Color(0xFF66BB6A),
    'axolotl': Color(0xFFEC407A),
    // 蜘蛛
    'chilean_rose_tarantula': Color(0xFFEF5350),
    'mexican_red_knee': Color(0xFFFF7043),
    'brazilian_white_knee': Color(0xFFEEEEEE),
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
      cardTheme: CardThemeData(
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
