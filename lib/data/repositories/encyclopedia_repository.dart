import '../local/database_helper.dart';
import '../models/encyclopedia.dart';
import '../models/article.dart';

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

  // ===== 文章相关方法 =====
  // 初始化文章数据
  Future<void> initArticleData() async {
    await _dbHelper.initArticleData();
  }

  // 获取所有文章
  Future<List<Article>> getAllArticles() async {
    await _dbHelper.initArticleData();
    final result = await _dbHelper.query('articles', orderBy: 'created_at DESC');
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

  // 搜索文章
  Future<List<Article>> searchArticles(String keyword) async {
    await _dbHelper.initArticleData();
    final result = await _dbHelper.query('articles');
    final kw = keyword.toLowerCase();
    final filtered = result.where((map) {
      final title = (map['title'] ?? '').toString().toLowerCase();
      final content = (map['content'] ?? '').toString().toLowerCase();
      final summary = (map['summary'] ?? '').toString().toLowerCase();
      return title.contains(kw) || content.contains(kw) || summary.contains(kw);
    }).toList();
    return filtered.map((map) => Article.fromMap(map)).toList();
  }
}
