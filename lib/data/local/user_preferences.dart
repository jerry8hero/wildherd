import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserPreferences {
  static const String _levelKey = 'user_level';
  static const String _hasSelectedLevelKey = 'has_selected_level';

  // 位置设置
  static const String _cityNameKey = 'weather_city_name';
  static const String _latitudeKey = 'weather_latitude';
  static const String _longitudeKey = 'weather_longitude';

  static SharedPreferences? _prefs;
  static bool _isInitialized = false;

  // 常用城市列表
  static const Map<String, List<double>> popularCities = {
    '北京': [39.9, 116.4],
    '上海': [31.2, 121.5],
    '广州': [23.1, 113.3],
    '深圳': [22.5, 114.1],
    '中山': [22.5, 113.4],
    '成都': [30.6, 104.1],
    '杭州': [30.3, 120.2],
    '武汉': [30.6, 114.3],
    '西安': [34.3, 108.9],
    '南京': [32.1, 118.8],
    '重庆': [29.6, 106.5],
    '天津': [39.1, 117.2],
    '苏州': [31.3, 120.6],
    '郑州': [34.7, 113.6],
    '长沙': [28.2, 112.9],
    '青岛': [36.1, 120.4],
  };

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    debugPrint('[UserPreferences] 初始化完成');
    // 测试写入
    await _prefs!.setString('_test_key', 'test_value');
    final test = _prefs!.getString('_test_key');
    debugPrint('[UserPreferences] 测试读写: $test');
  }

  static bool get isInitialized => _isInitialized;

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('UserPreferences 未初始化，请先调用 init()');
    }
    return _prefs!;
  }

  // 获取用户等级
  static UserLevel getUserLevel() {
    final levelString = prefs.getString(_levelKey);
    if (levelString == null) {
      return UserLevel.beginner; // 默认新手
    }
    return UserLevel.values.firstWhere(
      (e) => e.name == levelString,
      orElse: () => UserLevel.beginner,
    );
  }

  // 设置用户等级
  static Future<void> setUserLevel(UserLevel level) async {
    await prefs.setString(_levelKey, level.name);
    await prefs.setBool(_hasSelectedLevelKey, true);
  }

  // 检查用户是否已经选择过等级
  static bool hasSelectedLevel() {
    return prefs.getBool(_hasSelectedLevelKey) ?? false;
  }

  // 获取难度范围
  static List<int> getDifficultyRange() {
    return getUserLevel().difficultyRange;
  }

  // 获取难度范围的最大值（用于筛选）
  static int getMaxDifficulty() {
    return getUserLevel().difficultyRange[1];
  }

  // ===== 位置设置 =====

  // 获取保存的城市名称
  static String getCityName() {
    return prefs.getString(_cityNameKey) ?? '北京';
  }

  // 设置城市
  static Future<void> setCity(String cityName) async {
    await prefs.setString(_cityNameKey, cityName);
    // 如果是预设城市，同时设置经纬度
    if (popularCities.containsKey(cityName)) {
      final coords = popularCities[cityName]!;
      await prefs.setDouble(_latitudeKey, coords[0]);
      await prefs.setDouble(_longitudeKey, coords[1]);
    }
  }

  // 获取纬度
  static double getLatitude() {
    return prefs.getDouble(_latitudeKey) ?? popularCities[getCityName()]?[0] ?? 39.9;
  }

  // 获取经度
  static double getLongitude() {
    return prefs.getDouble(_longitudeKey) ?? popularCities[getCityName()]?[1] ?? 116.4;
  }
}
