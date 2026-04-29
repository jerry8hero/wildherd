/// 数值格式化工具
class NumUtils {
  /// 格式化为小数（默认1位）
  static String formatDecimal(double value, {int decimals = 1}) {
    return value.toStringAsFixed(decimals);
  }

  /// 格式化为百分比
  static String formatPercent(double value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// 格式化为温度
  static String formatTemperature(double temp, {String unit = '°C'}) {
    return '${temp.toStringAsFixed(1)}$unit';
  }

  /// 格式化为湿度
  static String formatHumidity(double humidity) {
    return '${humidity.toStringAsFixed(0)}%';
  }

  /// 安全转换为 double（失败返回默认值）
  static double? tryParseDouble(String? value, {double? defaultValue}) {
    if (value == null || value.isEmpty) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  /// 限制值在范围内
  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
