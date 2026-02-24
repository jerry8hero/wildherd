import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

// 桌面平台需要初始化 sqflite_common_ffi
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// 用户偏好存储
import 'data/local/user_preferences.dart';

// 定时任务管理
import 'utils/schedule_manager.dart';

// 成就系统
import 'utils/achievement_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化用户偏好存储
  await UserPreferences.init();

  // 初始化 FFI（桌面平台需要）
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // 初始化成就系统
  final achievementManager = AchievementManager();
  await achievementManager.init();

  // 初始化定时任务管理器
  final scheduleManager = ScheduleManager();

  // 注册资讯更新回调
  scheduleManager.registerExhibitionUpdateCallback(() {
    // 这里可以添加实际的更新逻辑
    // 比如刷新展览资讯、重新加载数据等
    debugPrint('定时任务：开始更新资讯...');
  });

  // 启动定时任务
  await scheduleManager.init();

  runApp(
    const ProviderScope(
      child: ReptileCareApp(),
    ),
  );
}
