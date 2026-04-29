import 'package:flutter/material.dart';

/// 颜色工具类
class ColorUtils {
  /// 根据温度返回颜色（用于冬化/环境显示）
  static Color getTemperatureColor(double temp) {
    if (temp < 5) return Colors.blue;
    if (temp < 10) return Colors.lightBlue;
    if (temp < 15) return Colors.teal;
    if (temp < 20) return Colors.green;
    if (temp < 25) return Colors.orange;
    return Colors.red;
  }

  /// 根据湿度返回颜色
  static Color getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.orange; // 干燥
    if (humidity < 70) return Colors.green; // 适宜
    return Colors.blue; // 潮湿
  }

  /// 根据评分返回颜色
  static Color getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  /// 根据优先级返回颜色
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 创建半透明颜色
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
