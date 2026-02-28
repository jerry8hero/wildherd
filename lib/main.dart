import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

// 用户偏好存储
import 'data/local/user_preferences.dart';

void main() async {
  debugPrint('[main] 开始初始化...');
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化用户偏好存储
  await UserPreferences.init();
  debugPrint('[main] UserPreferences 初始化完成');

  runApp(
    const ProviderScope(
      child: ReptileCareApp(),
    ),
  );
}
