/// 喂食推荐常量
class FeedingConstants {
  // 温度阈值
  static const double tempStopFeeding = 18.0; // 停止喂食温度
  static const double tempCaution = 22.0; // 谨慎喂食温度
  static const double tempNormalLow = 25.0; // 正常喂食下限
  static const double tempOptimalLow = 25.0; // 最佳喂食下限
  static const double tempOptimalHigh = 32.0; // 最佳喂食上限
  static const double tempWarning = 35.0; // 高温警告

  // 建议喂食间隔（天）
  static const int intervalCold = 3; // < 18°C
  static const int intervalCool = 2; // 18-25°C
  static const int intervalNormal = 1; // 25-32°C
  static const int intervalWarm = 1; // 32-35°C

  // 消化最佳温度范围
  static const double digestionOptimalMin = 25.0;
  static const double digestionOptimalMax = 35.0;

  // 默认建议喂食间隔（天）
  static const int suggestedInterval = 3;
}
