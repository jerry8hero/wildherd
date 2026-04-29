import '../local/database_helper.dart';
import '../models/reptile.dart';

class ReptileRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取所有爬宠
  Future<List<Reptile>> getAllReptiles() async {
    final result = await _dbHelper.query('reptiles', orderBy: 'created_at DESC');
    return result.map((map) => Reptile.fromMap(map)).toList();
  }

  // 获取单个爬宠
  Future<Reptile?> getReptile(String id) async {
    final result = await _dbHelper.queryWhere(
      'reptiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Reptile.fromMap(result.first);
  }

  // 添加爬宠
  Future<void> addReptile(Reptile reptile) async {
    await _dbHelper.insert('reptiles', reptile.toMap());
  }

  // 更新爬宠
  Future<void> updateReptile(Reptile reptile) async {
    await _dbHelper.update(
      'reptiles',
      reptile.toMap(),
      where: 'id = ?',
      whereArgs: [reptile.id],
    );
  }

  // 删除爬宠
  Future<void> deleteReptile(String id) async {
    await _dbHelper.delete('reptiles', where: 'id = ?', whereArgs: [id]);
  }
}
