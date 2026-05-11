import '../local/database_helper.dart';
import '../models/shedding_record.dart';

class SheddingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取蜕皮记录
  Future<List<SheddingRecord>> getSheddingRecords(String reptileId) async {
    final result = await _dbHelper.queryWhere(
      'shedding_records',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
      orderBy: 'shed_date DESC',
    );
    return result.map((map) => SheddingRecord.fromMap(map)).toList();
  }

  // 添加蜕皮记录
  Future<void> addSheddingRecord(SheddingRecord record) async {
    await _dbHelper.insert('shedding_records', record.toMap());
  }

  // 删除蜕皮记录
  Future<void> deleteSheddingRecord(String id) async {
    await _dbHelper.delete('shedding_records', where: 'id = ?', whereArgs: [id]);
  }
}