import '../local/database_helper.dart';
import '../models/reptile.dart';
import '../models/record.dart';
import '../models/community.dart';
import '../models/encyclopedia.dart';

class ReptileRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取所有爬宠
  Future<List<Reptile>> getAllReptiles() async {
    final db = await _dbHelper.database;
    final result = await db.query('reptiles', orderBy: 'created_at DESC');
    return result.map((map) => Reptile.fromMap(map)).toList();
  }

  // 获取单个爬宠
  Future<Reptile?> getReptile(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'reptiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Reptile.fromMap(result.first);
  }

  // 添加爬宠
  Future<void> addReptile(Reptile reptile) async {
    final db = await _dbHelper.database;
    await db.insert('reptiles', reptile.toMap());
  }

  // 更新爬宠
  Future<void> updateReptile(Reptile reptile) async {
    final db = await _dbHelper.database;
    await db.update(
      'reptiles',
      reptile.toMap(),
      where: 'id = ?',
      whereArgs: [reptile.id],
    );
  }

  // 删除爬宠
  Future<void> deleteReptile(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'reptiles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class RecordRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取喂食记录
  Future<List<FeedingRecord>> getFeedingRecords(String reptileId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'feeding_records',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
      orderBy: 'feeding_time DESC',
    );
    return result.map((map) => FeedingRecord.fromMap(map)).toList();
  }

  // 添加喂食记录
  Future<void> addFeedingRecord(FeedingRecord record) async {
    final db = await _dbHelper.database;
    await db.insert('feeding_records', record.toMap());
  }

  // 删除喂食记录
  Future<void> deleteFeedingRecord(String id) async {
    final db = await _dbHelper.database;
    await db.delete('feeding_records', where: 'id = ?', whereArgs: [id]);
  }

  // 获取健康记录
  Future<List<HealthRecord>> getHealthRecords(String reptileId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'health_records',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
      orderBy: 'record_date DESC',
    );
    return result.map((map) => HealthRecord.fromMap(map)).toList();
  }

  // 添加健康记录
  Future<void> addHealthRecord(HealthRecord record) async {
    final db = await _dbHelper.database;
    await db.insert('health_records', record.toMap());
  }

  // 删除健康记录
  Future<void> deleteHealthRecord(String id) async {
    final db = await _dbHelper.database;
    await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }

  // 获取成长相册
  Future<List<GrowthPhoto>> getGrowthPhotos(String reptileId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'growth_photos',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
      orderBy: 'photo_date DESC',
    );
    return result.map((map) => GrowthPhoto.fromMap(map)).toList();
  }

  // 添加成长照片
  Future<void> addGrowthPhoto(GrowthPhoto photo) async {
    final db = await _dbHelper.database;
    await db.insert('growth_photos', photo.toMap());
  }

  // 删除成长照片
  Future<void> deleteGrowthPhoto(String id) async {
    final db = await _dbHelper.database;
    await db.delete('growth_photos', where: 'id = ?', whereArgs: [id]);
  }
}

class EncyclopediaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取所有物种
  Future<List<ReptileSpecies>> getAllSpecies() async {
    final db = await _dbHelper.database;
    final result = await db.query('species', orderBy: 'name_chinese ASC');
    return result.map((map) => ReptileSpecies.fromMap(map)).toList();
  }

  // 按类别获取物种
  Future<List<ReptileSpecies>> getSpeciesByCategory(String category) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'species',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name_chinese ASC',
    );
    return result.map((map) => ReptileSpecies.fromMap(map)).toList();
  }

  // 获取单个物种详情
  Future<ReptileSpecies?> getSpeciesDetail(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'species',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return ReptileSpecies.fromMap(result.first);
  }

  // 搜索物种
  Future<List<ReptileSpecies>> searchSpecies(String keyword) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'species',
      where: 'name_chinese LIKE ? OR name_english LIKE ? OR scientific_name LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'name_chinese ASC',
    );
    return result.map((map) => ReptileSpecies.fromMap(map)).toList();
  }
}

class CommunityRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取动态列表
  Future<List<Post>> getPosts({String? category}) async {
    final db = await _dbHelper.database;
    final result = category != null
        ? await db.query(
            'posts',
            where: 'reptile_species = ?',
            whereArgs: [category],
            orderBy: 'created_at DESC',
          )
        : await db.query('posts', orderBy: 'created_at DESC');
    return result.map((map) => Post.fromMap(map)).toList();
  }

  // 发布动态
  Future<void> addPost(Post post) async {
    final db = await _dbHelper.database;
    await db.insert('posts', post.toMap());
  }

  // 删除动态
  Future<void> deletePost(String id) async {
    final db = await _dbHelper.database;
    await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }

  // 点赞
  Future<void> likePost(String id) async {
    final db = await _dbHelper.database;
    await db.rawUpdate('UPDATE posts SET likes = likes + 1 WHERE id = ?', [id]);
  }

  // 获取评论
  Future<List<Comment>> getComments(String postId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'comments',
      where: 'post_id = ?',
      whereArgs: [postId],
      orderBy: 'created_at ASC',
    );
    return result.map((map) => Comment.fromMap(map)).toList();
  }

  // 添加评论
  Future<void> addComment(Comment comment) async {
    final db = await _dbHelper.database;
    await db.insert('comments', comment.toMap());
    await db.rawUpdate(
        'UPDATE posts SET comments = comments + 1 WHERE id = ?', [comment.postId]);
  }
}
