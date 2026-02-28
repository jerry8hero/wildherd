import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserPreferences {
  static const String _levelKey = 'user_level';
  static const String _hasSelectedLevelKey = 'has_selected_level';

  static SharedPreferences? _prefs;
  static bool _isInitialized = false;

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
}
