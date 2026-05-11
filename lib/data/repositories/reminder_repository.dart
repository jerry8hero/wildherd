import '../local/database_helper.dart';
import '../models/feeding_reminder.dart';

class ReminderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取所有喂食提醒
  Future<List<FeedingReminder>> getAllReminders() async {
    final result = await _dbHelper.queryWhere(
      'feeding_reminders',
      orderBy: 'created_at DESC',
    );
    return result.map((map) => FeedingReminder.fromMap(map)).toList();
  }

  // 获取特定爬宠的喂食提醒
  Future<List<FeedingReminder>> getRemindersForReptile(String reptileId) async {
    final result = await _dbHelper.queryWhere(
      'feeding_reminders',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => FeedingReminder.fromMap(map)).toList();
  }

  // 添加喂食提醒
  Future<void> addReminder(FeedingReminder reminder) async {
    await _dbHelper.insert('feeding_reminders', reminder.toMap());
  }

  // 更新喂食提醒
  Future<void> updateReminder(FeedingReminder reminder) async {
    // 先删除旧的记录
    await _dbHelper.delete(
      'feeding_reminders',
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
    // 插入新的记录
    await _dbHelper.insert('feeding_reminders', reminder.toMap());
  }

  // 删除喂食提醒
  Future<void> deleteReminder(String id) async {
    await _dbHelper.delete(
      'feeding_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}