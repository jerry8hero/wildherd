import 'package:flutter/material.dart';

/// 性别工具类
class GenderUtils {
  static const List<String> options = ['雄性', '雌性', '未知'];

  /// 获取性别显示文本
  static String getText(String? gender) {
    switch (gender) {
      case '雄性':
        return '雄性';
      case '雌性':
        return '雌性';
      default:
        return '未知';
    }
  }

  /// 获取性别图标
  static IconData getIcon(String? gender) {
    switch (gender) {
      case '雄性':
        return Icons.male;
      case '雌性':
        return Icons.female;
      default:
        return Icons.help_outline;
    }
  }

  /// 获取性别图标颜色
  static Color getColor(String? gender) {
    switch (gender) {
      case '雄性':
        return Colors.blue;
      case '雌性':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  /// 获取性别下拉选项列表
  static List<DropdownMenuItem<String>> getDropdownItems() {
    return options.map((gender) {
      return DropdownMenuItem(
        value: gender,
        child: Row(
          children: [
            Icon(getIcon(gender), color: getColor(gender), size: 20),
            const SizedBox(width: 8),
            Text(gender),
          ],
        ),
      );
    }).toList();
  }
}
