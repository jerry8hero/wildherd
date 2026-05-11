import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'data/local/user_preferences.dart';

void main() async {
  debugPrint('[main] 开始初始化...');
  WidgetsFlutterBinding.ensureInitialized();

  await UserPreferences.init();
  debugPrint('[main] UserPreferences 初始化完成');

  await NotificationService.instance.init();
  debugPrint('[main] NotificationService 初始化完成');

  runApp(
    const ProviderScope(
      child: ReptileCareApp(),
    ),
  );
}
