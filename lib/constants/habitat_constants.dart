/// 饲养环境常量默认值
class HabitatConstants {
  // 默认环境参数
  static const double defaultTemperature = 25.0;
  static const double defaultHumidity = 50.0;

  // 标准环境参数默认值
  static const double defaultMinTemp = 20.0;
  static const double defaultMaxTemp = 30.0;
  static const double defaultIdealTemp = 25.0;
  static const double defaultMinHumidity = 30.0;
  static const double defaultMaxHumidity = 70.0;

  // 温度范围
  static const double absoluteMinTemp = 0.0;
  static const double absoluteMaxTemp = 50.0;

  // 湿度范围
  static const double absoluteMinHumidity = 0.0;
  static const double absoluteMaxHumidity = 100.0;

  // 评分相关
  static const double idealTempRange = 2.0; // 理想温度范围 ±2°C
  static const double idealHumidityRange = 10.0; // 理想湿度范围 ±10%

  // 最小饲养箱尺寸（升）
  static const double minTankSize = 60.0;
}
