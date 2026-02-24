import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/achievement.dart';

/// 成就管理器
/// 处理成就的解锁、进度更新和存储
class AchievementManager {
  static final AchievementManager _instance = AchievementManager._internal();
  factory AchievementManager() => _instance;
  AchievementManager._internal();

  static const String _keyAchievements = 'achievements_data';
  static const String _keyTotalPoints = 'total_points';
  static const String _keyLastLoginDate = 'last_login_date';
  static const String _keyConsecutiveDays = 'consecutive_days';

  final List<Achievement> _achievements = [];
  int _totalPoints = 0;
  bool _isInitialized = false;

  // 成就解锁回调
  final List<Function(Achievement)> _unlockCallbacks = [];

  /// 初始化成就系统
  Future<void> init() async {
    if (_isInitialized) return;

    await _loadData();
    await _checkLoginStreak();
    _isInitialized = true;
  }

  /// 加载成就数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载积分
    _totalPoints = prefs.getInt(_keyTotalPoints) ?? 0;

    // 加载成就进度
    final achievementsJson = prefs.getString(_keyAchievements);
    if (achievementsJson != null) {
      final Map<String, dynamic> savedData = jsonDecode(achievementsJson);

      // 初始化所有成就
      final definitions = AchievementDefinitions.getAll();
      for (var def in definitions) {
        final saved = savedData[def.id];
        if (saved != null) {
          _achievements.add(def.copyWith(
            currentValue: saved['current_value'] ?? 0,
            isUnlocked: saved['is_unlocked'] ?? false,
            unlockedAt: saved['unlocked_at'] != null
                ? DateTime.tryParse(saved['unlocked_at'])
                : null,
          ));
        } else {
          _achievements.add(def);
        }
      }
    } else {
      _achievements.addAll(AchievementDefinitions.getAll());
    }
  }

  /// 保存成就数据
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // 保存积分
    await prefs.setInt(_keyTotalPoints, _totalPoints);

    // 保存成就进度
    final Map<String, dynamic> achievementsData = {};
    for (var a in _achievements) {
      achievementsData[a.id] = a.toMap();
    }
    await prefs.setString(_keyAchievements, jsonEncode(achievementsData));
  }

  /// 检查登录连续天数
  Future<void> _checkLoginStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginStr = prefs.getString(_keyLastLoginDate);
    final lastLogin = lastLoginStr != null ? DateTime.tryParse(lastLoginStr) : null;
    final now = DateTime.now();

    int consecutiveDays = prefs.getInt(_keyConsecutiveDays) ?? 0;

    if (lastLogin == null) {
      // 首次登录
      consecutiveDays = 1;
    } else {
      final diff = now.difference(lastLogin).inDays;
      if (diff == 1) {
        // 连续登录
        consecutiveDays++;
      } else if (diff > 1) {
        // 中断了
        consecutiveDays = 1;
      }
      // diff == 0 表示今天已经登录过，不处理
    }

    await prefs.setInt(_keyConsecutiveDays, consecutiveDays);
    await prefs.setString(_keyLastLoginDate, now.toIso8601String());

    // 更新登录相关成就进度
    await updateProgress('first_login', 1);
    await updateProgress('login_3_days', consecutiveDays);
    await updateProgress('login_7_days', consecutiveDays);
    await updateProgress('login_30_days', consecutiveDays);
  }

  /// 更新成就进度
  Future<void> updateProgress(String achievementId, int value) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    final achievement = _achievements[index];
    if (achievement.isUnlocked) return;

    final newValue = achievement.currentValue + value;
    final isUnlocked = newValue >= achievement.targetValue;

    _achievements[index] = achievement.copyWith(
      currentValue: newValue >= achievement.targetValue ? achievement.targetValue : newValue,
      isUnlocked: isUnlocked,
      unlockedAt: isUnlocked ? DateTime.now() : null,
    );

    // 如果解锁了，发放奖励
    if (isUnlocked && achievement.reward != null) {
      await _grantReward(achievement);
      // 通知解锁
      for (var callback in _unlockCallbacks) {
        callback(_achievements[index]);
      }
    }

    await _saveData();
  }

  /// 设置进度（覆盖）
  Future<void> setProgress(String achievementId, int value) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    final achievement = _achievements[index];
    if (achievement.isUnlocked) return;

    final isUnlocked = value >= achievement.targetValue;

    _achievements[index] = achievement.copyWith(
      currentValue: value >= achievement.targetValue ? achievement.targetValue : value,
      isUnlocked: isUnlocked,
      unlockedAt: isUnlocked ? DateTime.now() : null,
    );

    if (isUnlocked && achievement.reward != null) {
      await _grantReward(achievement);
      for (var callback in _unlockCallbacks) {
        callback(_achievements[index]);
      }
    }

    await _saveData();
  }

  /// 发放奖励
  Future<void> _grantReward(Achievement achievement) async {
    if (achievement.reward == null) return;

    switch (achievement.reward!.type) {
      case 'points':
        final points = int.tryParse(achievement.reward!.value) ?? 0;
        _totalPoints += points;
        break;
      case 'badge':
        // 徽章逻辑，后续可以扩展
        break;
    }
  }

  /// 添加成就解锁回调
  void addUnlockCallback(Function(Achievement) callback) {
    _unlockCallbacks.add(callback);
  }

  /// 移除成就解锁回调
  void removeUnlockCallback(Function(Achievement) callback) {
    _unlockCallbacks.remove(callback);
  }

  /// 获取所有成就
  List<Achievement> getAllAchievements() {
    return List.unmodifiable(_achievements);
  }

  /// 获取已解锁的成就
  List<Achievement> getUnlockedAchievements() {
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  /// 获取未解锁的成就
  List<Achievement> getLockedAchievements() {
    return _achievements.where((a) => !a.isUnlocked).toList();
  }

  /// 获取成就
  Achievement? getAchievement(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取总积分
  int getTotalPoints() => _totalPoints;

  /// 获取连续登录天数
  Future<int> getConsecutiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyConsecutiveDays) ?? 0;
  }

  /// 获取解锁数量
  int getUnlockedCount() {
    return _achievements.where((a) => a.isUnlocked).length;
  }

  /// 获取成就总数
  int getTotalCount() => _achievements.length;

  /// 获取进度
  double getProgress() {
    if (_achievements.isEmpty) return 0.0;
    return getUnlockedCount() / getTotalCount();
  }

  /// 按类型获取成就
  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievements.where((a) => a.type == type).toList();
  }

  // ===== 快捷方法 =====

  /// 爬宠相关成就更新
  Future<void> onReptileAdded(int count) async {
    await setProgress('first_reptile', count);
    await setProgress('reptile_5', count);
    await setProgress('reptile_10', count);
  }

  /// 社区发帖成就更新
  Future<void> onPostCreated(int count) async {
    await setProgress('first_post', count);
    await setProgress('post_10', count);
  }

  /// 获得点赞成就更新
  Future<void> onLiked(int totalLikes) async {
    await setProgress('like_100', totalLikes);
  }

  /// 浏览物种成就更新
  Future<void> onSpeciesViewed(int count) async {
    await setProgress('first_species', count);
    await setProgress('species_50', count);
    await setProgress('species_100', count);
  }

  /// 阅读文章成就更新
  Future<void> onArticleRead(int count) async {
    await setProgress('first_article', count);
    await setProgress('article_10', count);
    await setProgress('article_50', count);
  }

  /// 提问成就更新
  Future<void> onQuestionAsked(int count) async {
    await setProgress('first_question', count);
  }

  /// 回答成就更新
  Future<void> onAnswerPosted(int count) async {
    await setProgress('first_answer', count);
    await setProgress('answer_10', count);
  }

  /// 采纳成就更新
  Future<void> onAnswerAccepted(int count) async {
    await setProgress('accepted_5', count);
  }

  /// 创建环境成就更新
  Future<void> onHabitatCreated(int count) async {
    await setProgress('first_habitat', count);
  }

  /// 更新积分
  Future<void> addPoints(int points) async {
    _totalPoints += points;
    await setProgress('points_500', _totalPoints);
    await setProgress('points_1000', _totalPoints);
    await _saveData();
  }

  /// 重置成就（用于测试）
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAchievements);
    await prefs.remove(_keyTotalPoints);
    await prefs.remove(_keyConsecutiveDays);
    await prefs.remove(_keyLastLoginDate);
    _achievements.clear();
    _achievements.addAll(AchievementDefinitions.getAll());
    _totalPoints = 0;
  }
}
