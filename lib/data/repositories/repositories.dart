import '../local/database_helper.dart';
import '../models/reptile.dart';
import '../models/record.dart';
import '../models/community.dart';
import '../models/encyclopedia.dart';
import '../models/exhibition.dart';
import '../models/article.dart';

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

class EncyclopediaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取所有物种
  Future<List<ReptileSpecies>> getAllSpecies() async {
    // 确保百科数据已初始化
    await _dbHelper.initEncyclopediaData();
    final result = await _dbHelper.query('species', orderBy: 'name_chinese ASC');
    return result.map((map) => ReptileSpecies.fromMap(map)).toList();
  }

  // 按类别获取物种
  Future<List<ReptileSpecies>> getSpeciesByCategory(String category) async {
    await _dbHelper.initEncyclopediaData();
    final result = await _dbHelper.queryWhere(
      'species',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name_chinese ASC',
    );
    return result.map((map) => ReptileSpecies.fromMap(map)).toList();
  }

  // 获取单个物种详情
  Future<ReptileSpecies?> getSpeciesDetail(String id) async {
    await _dbHelper.initEncyclopediaData();
    final result = await _dbHelper.queryWhere(
      'species',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return ReptileSpecies.fromMap(result.first);
  }

  // 搜索物种
  Future<List<ReptileSpecies>> searchSpecies(String keyword) async {
    await _dbHelper.initEncyclopediaData();
    final result = await _dbHelper.query(
      'species',
      orderBy: 'name_chinese ASC',
    );
    // 简单的客户端过滤
    final filtered = result.where((map) {
      final chinese = (map['name_chinese'] ?? '').toString().toLowerCase();
      final english = (map['name_english'] ?? '').toString().toLowerCase();
      final scientific = (map['scientific_name'] ?? '').toString().toLowerCase();
      final kw = keyword.toLowerCase();
      return chinese.contains(kw) || english.contains(kw) || scientific.contains(kw);
    }).toList();
    return filtered.map((map) => ReptileSpecies.fromMap(map)).toList();
  }
}

class CommunityRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取动态列表
  Future<List<Post>> getPosts({String? category}) async {
    if (category != null) {
      final result = await _dbHelper.queryWhere(
        'posts',
        where: 'reptile_species = ?',
        whereArgs: [category],
        orderBy: 'created_at DESC',
      );
      return result.map((map) => Post.fromMap(map)).toList();
    }
    final result = await _dbHelper.query('posts', orderBy: 'created_at DESC');
    return result.map((map) => Post.fromMap(map)).toList();
  }

  // 发布动态
  Future<void> addPost(Post post) async {
    await _dbHelper.insert('posts', post.toMap());
  }

  // 删除动态
  Future<void> deletePost(String id) async {
    await _dbHelper.delete('posts', where: 'id = ?', whereArgs: [id]);
  }

  // 点赞 - 简化实现
  Future<void> likePost(String id) async {
    final posts = await _dbHelper.queryWhere('posts', where: 'id = ?', whereArgs: [id]);
    if (posts.isNotEmpty) {
      final post = posts.first;
      final likes = (post['likes'] ?? 0) as int;
      await _dbHelper.update('posts', {'likes': likes + 1}, where: 'id = ?', whereArgs: [id]);
    }
  }

  // 获取评论
  Future<List<Comment>> getComments(String postId) async {
    final result = await _dbHelper.queryWhere(
      'comments',
      where: 'post_id = ?',
      whereArgs: [postId],
      orderBy: 'created_at ASC',
    );
    return result.map((map) => Comment.fromMap(map)).toList();
  }

  // 添加评论
  Future<void> addComment(Comment comment) async {
    await _dbHelper.insert('comments', comment.toMap());
    // 更新帖子评论数
    final posts = await _dbHelper.queryWhere('posts', where: 'id = ?', whereArgs: [comment.postId]);
    if (posts.isNotEmpty) {
      final post = posts.first;
      final comments = (post['comments'] ?? 0) as int;
      await _dbHelper.update('posts', {'comments': comments + 1}, where: 'id = ?', whereArgs: [comment.postId]);
    }
  }
}

export 'exhibition_repository.dart';
export 'price_alert_repository.dart';
