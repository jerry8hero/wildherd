import '../local/database_helper.dart';
import '../models/exhibition.dart';
import '../models/article.dart';

class ExhibitionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取所有展览活动
  Future<List<Exhibition>> getAllExhibitions() async {
    await _dbHelper.initExhibitionData();
    final result = await _dbHelper.query('exhibitions', orderBy: 'start_time DESC');
    return result.map((map) => Exhibition.fromMap(map)).toList();
  }

  // 获取即将开始的展览
  Future<List<Exhibition>> getUpcomingExhibitions() async {
    await _dbHelper.initExhibitionData();
    final now = DateTime.now().toIso8601String();
    final result = await _dbHelper.queryWhere(
      'exhibitions',
      where: 'start_time > ?',
      whereArgs: [now],
      orderBy: 'start_time ASC',
    );
    return result.map((map) => Exhibition.fromMap(map)).toList();
  }

  // 获取重点推荐的展览
  Future<List<Exhibition>> getFeaturedExhibitions() async {
    await _dbHelper.initExhibitionData();
    final result = await _dbHelper.queryWhere(
      'exhibitions',
      where: 'is_highlight = ?',
      whereArgs: [1],
    );
    return result.map((map) => Exhibition.fromMap(map)).toList();
  }

  // 获取单个展览详情
  Future<Exhibition?> getExhibitionDetail(String id) async {
    await _dbHelper.initExhibitionData();
    final result = await _dbHelper.queryWhere(
      'exhibitions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Exhibition.fromMap(result.first);
  }

  // 获取所有文章
  Future<List<Article>> getAllArticles() async {
    await _dbHelper.initArticleData();
    final result = await _dbHelper.query('articles', orderBy: 'created_at DESC');
    return result.map((map) => Article.fromMap(map)).toList();
  }

  // 按分类获取文章
  Future<List<Article>> getArticlesByCategory(String category) async {
    await _dbHelper.initArticleData();
    final result = await _dbHelper.queryWhere(
      'articles',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Article.fromMap(map)).toList();
  }

  // 获取推荐文章
  Future<List<Article>> getFeaturedArticles() async {
    await _dbHelper.initArticleData();
    final result = await _dbHelper.queryWhere(
      'articles',
      where: 'is_featured = ?',
      whereArgs: [1],
    );
    return result.map((map) => Article.fromMap(map)).toList();
  }

  // 获取文章详情
  Future<Article?> getArticleDetail(String id) async {
    await _dbHelper.initArticleData();
    final result = await _dbHelper.queryWhere(
      'articles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Article.fromMap(result.first);
  }

  // 预留远程 API 接口
  Future<List<Exhibition>> fetchRemoteExhibitions() async {
    // TODO: 实现远程 API 调用
    // final response = await http.get(Uri.parse('${Config.apiBase}/exhibitions'));
    // return parseExhibitions(response.body);
    return [];
  }

  Future<List<Article>> fetchRemoteArticles() async {
    // TODO: 实现远程 API 调用
    return [];
  }
}
