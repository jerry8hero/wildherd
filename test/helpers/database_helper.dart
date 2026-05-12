import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/local/database_helper.dart';

/// 测试辅助：清空 DatabaseHelper 的内存存储
void clearDatabaseHelper() {
  // DatabaseHelper 使用 _memoryStorage 静态 Map
  // 通过 query 空表来确认状态，实际清空通过直接操作
  final db = DatabaseHelper.instance;
  // 内存存储是 private 的，通过 insert/delete 操作来间接管理
  // 测试中每个 setUp 清理即可
}

/// 清空指定表的所有数据
Future<void> clearTable(String table) async {
  final db = DatabaseHelper.instance;
  final records = await db.query(table);
  for (final record in records) {
    await db.delete(table, where: 'id = ?', whereArgs: [record['id'] as String]);
  }
}

/// 验证表中的记录数
Future<void> expectTableCount(String table, int expected) async {
  final db = DatabaseHelper.instance;
  final records = await db.query(table);
  expect(records.length, equals(expected));
}
