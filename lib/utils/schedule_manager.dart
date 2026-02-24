import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// 定时任务管理器
/// 用于定时触发资讯更新、提醒等功能
class ScheduleManager {
  static final ScheduleManager _instance = ScheduleManager._internal();
  factory ScheduleManager() => _instance;
  ScheduleManager._internal();

  final Map<String, Timer> _timers = {};
  final Map<String, DateTime?> _lastRunTimes = {};

  // 定时任务键名
  static const String keyLastUpdateExhibition = 'last_update_exhibition';
  static const String keyLastUpdateArticle = 'last_update_article';
  static const String keyLastUpdateQA = 'last_update_qa';
  static const String keyUpdateInterval = 'update_interval_hours';

  // 默认更新间隔（小时）
  static const int defaultUpdateInterval = 6;

  /// 初始化定时任务管理器
  Future<void> init() async {
    // 检查是否需要立即更新（应用长时间未使用）
    await _checkAndUpdateIfNeeded();
    // 启动定时任务
    _startPeriodicTasks();
  }

  /// 启动定时任务
  void _startPeriodicTasks() {
    // 资讯更新任务 - 每6小时检查一次
    _startTask(
      'exhibition_update',
      const Duration(hours: 1),
      _onExhibitionUpdate,
    );

    // 清理过期数据任务 - 每天检查一次
    _startTask(
      'cleanup_task',
      const Duration(hours: 24),
      _onCleanupTask,
    );
  }

  /// 启动单个定时任务
  void _startTask(String key, Duration duration, Function callback) {
    _timers[key]?.cancel();
    _timers[key] = Timer.periodic(duration, (timer) {
      callback();
    });
  }

  /// 停止所有定时任务
  void stopAllTasks() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// 停止单个定时任务
  void stopTask(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// 检查是否需要更新
  Future<bool> shouldUpdate(String lastUpdateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdateStr = prefs.getString(lastUpdateKey);
    if (lastUpdateStr == null) return true;

    final lastUpdate = DateTime.tryParse(lastUpdateStr);
    if (lastUpdate == null) return true;

    final interval = prefs.getInt(keyUpdateInterval) ?? defaultUpdateInterval;
    final now = DateTime.now();
    return now.difference(lastUpdate).inHours >= interval;
  }

  /// 记录更新时间
  Future<void> recordUpdateTime(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, DateTime.now().toIso8601String());
    _lastRunTimes[key] = DateTime.now();
  }

  /// 检查并更新（如果需要）
  Future<void> _checkAndUpdateIfNeeded() async {
    if (await shouldUpdate(keyLastUpdateExhibition)) {
      // 触发资讯更新
      _onExhibitionUpdate();
    }
  }

  /// 资讯更新回调 - 由子类/外部实现具体逻辑
  Function? _onExhibitionUpdateCallback;

  /// 注册资讯更新回调
  void registerExhibitionUpdateCallback(Function callback) {
    _onExhibitionUpdateCallback = callback;
  }

  /// 资讯更新任务
  void _onExhibitionUpdate() async {
    if (_onExhibitionUpdateCallback != null) {
      _onExhibitionUpdateCallback!();
    }
    await recordUpdateTime(keyLastUpdateExhibition);
  }

  /// 清理任务
  Function? _onCleanupTaskCallback;

  /// 注册清理任务回调
  void registerCleanupCallback(Function callback) {
    _onCleanupTaskCallback = callback;
  }

  /// 清理任务
  void _onCleanupTask() async {
    if (_onCleanupTaskCallback != null) {
      _onCleanupTaskCallback!();
    }
  }

  /// 手动触发立即更新
  Future<void> triggerImmediateUpdate() async {
    _onExhibitionUpdate();
  }

  /// 获取最后更新时间
  Future<DateTime?> getLastUpdateTime(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdateStr = prefs.getString(key);
    if (lastUpdateStr == null) return null;
    return DateTime.tryParse(lastUpdateStr);
  }

  /// 设置更新间隔
  Future<void> setUpdateInterval(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyUpdateInterval, hours);
    // 重新启动定时任务以应用新间隔
    _startPeriodicTasks();
  }

  /// 获取更新间隔
  Future<int> getUpdateInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyUpdateInterval) ?? defaultUpdateInterval;
  }

  /// 获取距离下次更新的剩余时间
  Future<Duration> getTimeUntilNextUpdate() async {
    final lastUpdate = await getLastUpdateTime(keyLastUpdateExhibition);
    final interval = await getUpdateInterval();

    if (lastUpdate == null) {
      return Duration.zero;
    }

    final nextUpdate = lastUpdate.add(Duration(hours: interval));
    final now = DateTime.now();

    if (nextUpdate.isBefore(now)) {
      return Duration.zero;
    }

    return nextUpdate.difference(now);
  }
}

/// 资讯更新监听器 mixin
mixin ScheduleUpdateListener {
  void onScheduleUpdate();
}
