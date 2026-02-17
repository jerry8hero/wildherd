import 'package:flutter/material.dart';
import 'app/app.dart';

// 桌面平台需要初始化 sqflite_common_ffi
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// 用户偏好存储
import 'data/local/user_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化用户偏好存储
  await UserPreferences.init();

  // 初始化 FFI（桌面平台需要）
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const ReptileCareApp());
}
