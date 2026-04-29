import 'package:flutter/material.dart';

/// 冬化温度常量
class BrumationConstants {
  // 默认温度
  static const double defaultTemp = 10.0;

  // 温度阈值
  static const double tempFreezing = 5.0; // 结冰危险
  static const double tempVeryCold = 10.0; // 极冷
  static const double tempCold = 15.0; // 冷
  static const double tempCool = 20.0; // 凉爽
  static const double tempNormal = 25.0; // 正常/危险

  // 温度颜色映射
  static Color getTempColor(double temp) {
    if (temp < tempFreezing) return Colors.blue;
    if (temp < tempVeryCold) return Colors.lightBlue;
    if (temp < tempCold) return Colors.teal;
    if (temp < tempCool) return Colors.green;
    if (temp < tempNormal) return Colors.orange;
    return Colors.red;
  }

  // 温度范围描述
  static String getTempRangeLabel(double temp) {
    if (temp < tempFreezing) return '极寒';
    if (temp < tempVeryCold) return '很冷';
    if (temp < tempCold) return '较冷';
    if (temp < tempCool) return '凉爽';
    if (temp < tempNormal) return '适宜';
    return '偏热';
  }
}
