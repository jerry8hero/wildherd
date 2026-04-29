import '../local/database_helper.dart';
import '../models/record.dart';

class RecordRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取喂食记录
  Future<List<FeedingRecord>> getFeedingRecords(String reptileId) async {
    final result = await _dbHelper.queryWhere(
      'feeding_records',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
      orderBy: 'feeding_time DESC',
    );
    return result.map((map) => FeedingRecord.fromMap(map)).toList();
  }

  // 添加喂食记录
  Future<void> addFeedingRecord(FeedingRecord record) async {
    await _dbHelper.insert('feeding_records', record.toMap());
  }

  // 删除喂食记录
  Future<void> deleteFeedingRecord(String id) async {
    await _dbHelper.delete('feeding_records', where: 'id = ?', whereArgs: [id]);
  }

  // 获取健康记录
  Future<List<HealthRecord>> getHealthRecords(String reptileId) async {
    final result = await _dbHelper.queryWhere(
      'health_records',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
      orderBy: 'record_date DESC',
    );
    return result.map((map) => HealthRecord.fromMap(map)).toList();
  }

  // 添加健康记录
  Future<void> addHealthRecord(HealthRecord record) async {
    await _dbHelper.insert('health_records', record.toMap());
  }

  // 删除健康记录
  Future<void> deleteHealthRecord(String id) async {
    await _dbHelper.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }

  // 获取成长相册
  Future<List<GrowthPhoto>> getGrowthPhotos(String reptileId) async {
    final result = await _dbHelper.queryWhere(
      'growth_photos',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
      orderBy: 'photo_date DESC',
    );
    return result.map((map) => GrowthPhoto.fromMap(map)).toList();
  }

  // 添加成长照片
  Future<void> addGrowthPhoto(GrowthPhoto photo) async {
    await _dbHelper.insert('growth_photos', photo.toMap());
  }

  // 删除成长照片
  Future<void> deleteGrowthPhoto(String id) async {
    await _dbHelper.delete('growth_photos', where: 'id = ?', whereArgs: [id]);
  }
}
