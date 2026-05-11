import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../local/database_helper.dart';
import '../models/article.dart';
import '../models/knowledge_category.dart';
import '../models/knowledge_tip.dart';
import '../models/knowledge_collection.dart';
import '../models/faq.dart';

class KnowledgeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ===== 分类相关方法 =====

  // 获取所有顶级分类
  List<KnowledgeCategory> getTopCategories() {
    return KnowledgeCategories.getTopCategories();
  }

  // 获取子分类
  List<KnowledgeCategory> getSubCategories(String parentId) {
    return KnowledgeCategories.getSubCategories(parentId);
  }

  // 获取分类详情
  KnowledgeCategory? getCategoryById(String id) {
    return KnowledgeCategories.getCategoryById(id);
  }

  // ===== 文章相关方法 =====

  // 初始化知识库文章数据
  Future<void> initKnowledgeData() async {
    await _initKnowledgeArticles();
    await _initKnowledgeTips();
    await _initFAQs();
  }

  // 初始化示例文章数据
  Future<void> _initKnowledgeArticles() async {
    final existing = await _dbHelper.query('knowledge_articles');
    if (existing.isNotEmpty) return;

    // 添加示例文章
    final sampleArticles = await _getSampleArticles();
    for (var article in sampleArticles) {
      await _dbHelper.insert('knowledge_articles', article.toMap());
    }
  }

  // 初始化示例技巧数据
  Future<void> _initKnowledgeTips() async {
    final existing = await _dbHelper.query('knowledge_tips');
    if (existing.isNotEmpty) return;

    final sampleTips = await _getSampleTips();
    for (var tip in sampleTips) {
      await _dbHelper.insert('knowledge_tips', tip.toMap());
    }
  }

  // 初始化示例FAQ数据
  Future<void> _initFAQs() async {
    final existing = await _dbHelper.query('faqs');
    if (existing.isNotEmpty) return;

    final sampleFAQs = await _getSampleFAQs();
    for (var faq in sampleFAQs) {
      await _dbHelper.insert('faqs', faq.toMap());
    }
  }

  // 获取所有知识库文章
  Future<List<Article>> getAllArticles() async {
    await initKnowledgeData();
    final result = await _dbHelper.query('knowledge_articles', orderBy: 'created_at DESC');
    final articles = result.map((map) => Article.fromMap(map)).toList();

    // 检查收藏状态
    final collections = await getCollections();
    final collectionIds = collections.map((c) => c.itemId).toSet();

    return articles.map((article) {
      return article.copyWith(isCollection: collectionIds.contains(article.id));
    }).toList();
  }

  // 按分类获取文章
  Future<List<Article>> getArticlesByCategory(String categoryId) async {
    await initKnowledgeData();
    final result = await _dbHelper.query('knowledge_articles');
    final filtered = result.where((map) {
      final catId = map['category_id'] ?? '';
      return catId == categoryId || catId.startsWith(categoryId);
    }).toList();
    final articles = filtered.map((map) => Article.fromMap(map)).toList();

    // 检查收藏状态
    final collections = await getCollections();
    final collectionIds = collections.map((c) => c.itemId).toSet();

    return articles.map((article) {
      return article.copyWith(isCollection: collectionIds.contains(article.id));
    }).toList();
  }

  // 获取精选文章
  Future<List<Article>> getFeaturedArticles() async {
    await initKnowledgeData();
    final result = await _dbHelper.query('knowledge_articles');
    final filtered = result.where((map) => map['is_featured'] == 1).toList();
    final articles = filtered.map((map) => Article.fromMap(map)).toList();

    // 检查收藏状态
    final collections = await getCollections();
    final collectionIds = collections.map((c) => c.itemId).toSet();

    return articles.map((article) {
      return article.copyWith(isCollection: collectionIds.contains(article.id));
    }).toList();
  }

  // 按难度获取文章
  Future<List<Article>> getArticlesByDifficulty(int difficulty) async {
    await initKnowledgeData();
    final result = await _dbHelper.query('knowledge_articles');
    final filtered = result.where((map) => map['difficulty'] == difficulty).toList();
    final articles = filtered.map((map) => Article.fromMap(map)).toList();

    // 检查收藏状态
    final collections = await getCollections();
    final collectionIds = collections.map((c) => c.itemId).toSet();

    return articles.map((article) {
      return article.copyWith(isCollection: collectionIds.contains(article.id));
    }).toList();
  }

  // 获取文章详情
  Future<Article?> getArticleDetail(String id) async {
    await initKnowledgeData();
    final result = await _dbHelper.queryWhere(
      'knowledge_articles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;

    final article = Article.fromMap(result.first);
    // 检查收藏状态
    final isCollected = await isItemCollected(id);
    return article.copyWith(isCollection: isCollected);
  }

  // 搜索知识库文章
  Future<List<Article>> searchArticles(String keyword) async {
    await initKnowledgeData();
    final result = await _dbHelper.query('knowledge_articles');
    final kw = keyword.toLowerCase();
    final filtered = result.where((map) {
      final title = (map['title'] ?? '').toString().toLowerCase();
      final content = (map['content'] ?? '').toString().toLowerCase();
      final summary = (map['summary'] ?? '').toString().toLowerCase();
      final tags = (map['tags'] ?? '').toString().toLowerCase();
      return title.contains(kw) || content.contains(kw) || summary.contains(kw) || tags.contains(kw);
    }).toList();
    final articles = filtered.map((map) => Article.fromMap(map)).toList();

    // 检查收藏状态
    final collections = await getCollections();
    final collectionIds = collections.map((c) => c.itemId).toSet();

    return articles.map((article) {
      return article.copyWith(isCollection: collectionIds.contains(article.id));
    }).toList();
  }

  // ===== 技巧相关方法 =====

  // 获取所有技巧
  Future<List<KnowledgeTip>> getAllTips() async {
    await initKnowledgeData();
    final result = await _dbHelper.query('knowledge_tips', orderBy: 'created_at DESC');
    return result.map((map) => KnowledgeTip.fromMap(map)).toList();
  }

  // 按分类获取技巧
  Future<List<KnowledgeTip>> getTipsByCategory(String categoryId) async {
    await initKnowledgeData();
    final result = await _dbHelper.query('knowledge_tips');
    final filtered = result.where((map) => map['category_id'] == categoryId).toList();
    return filtered.map((map) => KnowledgeTip.fromMap(map)).toList();
  }

  // ===== FAQ相关方法 =====

  // 获取所有FAQ
  Future<List<FAQ>> getAllFAQs() async {
    await initKnowledgeData();
    final result = await _dbHelper.query('faqs', orderBy: 'created_at DESC');
    return result.map((map) => FAQ.fromMap(map)).toList();
  }

  // 按分类获取FAQ
  Future<List<FAQ>> getFAQsByCategory(String categoryId) async {
    await initKnowledgeData();
    final result = await _dbHelper.query('faqs');
    final filtered = result.where((map) => map['category_id'] == categoryId).toList();
    return filtered.map((map) => FAQ.fromMap(map)).toList();
  }

  // 搜索FAQ
  Future<List<FAQ>> searchFAQs(String keyword) async {
    await initKnowledgeData();
    final result = await _dbHelper.query('faqs');
    final kw = keyword.toLowerCase();
    final filtered = result.where((map) {
      final question = (map['question'] ?? '').toString().toLowerCase();
      final answer = (map['answer'] ?? '').toString().toLowerCase();
      final keywords = (map['keywords'] ?? '').toString().toLowerCase();
      return question.contains(kw) || answer.contains(kw) || keywords.contains(kw);
    }).toList();
    return filtered.map((map) => FAQ.fromMap(map)).toList();
  }

  // ===== 收藏相关方法 =====

  // 获取用户收藏
  Future<List<KnowledgeCollection>> getCollections() async {
    final result = await _dbHelper.query('knowledge_collections', orderBy: 'collected_at DESC');
    return result.map((map) => KnowledgeCollection.fromMap(map)).toList();
  }

  // 添加收藏
  Future<void> addCollection(KnowledgeCollection collection) async {
    await _dbHelper.insert('knowledge_collections', collection.toMap());
  }

  // 取消收藏
  Future<void> removeCollection(String itemId) async {
    await _dbHelper.delete(
      'knowledge_collections',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
  }

  // 检查是否已收藏
  Future<bool> isItemCollected(String itemId) async {
    final result = await _dbHelper.queryWhere(
      'knowledge_collections',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    return result.isNotEmpty;
  }

  // 切换收藏状态
  Future<bool> toggleCollection({
    required String itemId,
    required String itemType,
    required String title,
    String? summary,
    String? imageUrl,
  }) async {
    final isCollected = await isItemCollected(itemId);
    if (isCollected) {
      await removeCollection(itemId);
      return false;
    } else {
      final collection = KnowledgeCollection(
        id: const Uuid().v7(),
        itemId: itemId,
        itemType: itemType,
        title: title,
        summary: summary,
        imageUrl: imageUrl,
        collectedAt: DateTime.now(),
      );
      await addCollection(collection);
      return true;
    }
  }

  // ===== 阅读历史相关方法 =====

  // 获取阅读历史
  Future<List<ReadHistory>> getReadHistory() async {
    final result = await _dbHelper.query('read_history', orderBy: 'read_at DESC');
    return result.map((map) => ReadHistory.fromMap(map)).toList();
  }

  // 添加阅读历史
  Future<void> addReadHistory(ReadHistory history) async {
    // 先删除同一条目的旧记录
    await _dbHelper.delete(
      'read_history',
      where: 'item_id = ? AND item_type = ?',
      whereArgs: [history.itemId, history.itemType],
    );
    await _dbHelper.insert('read_history', history.toMap());

    // 只保留最近50条记录
    final allHistory = await getReadHistory();
    if (allHistory.length > 50) {
      final toDelete = allHistory.skip(50).map((h) => h.id).toList();
      for (var id in toDelete) {
        await _dbHelper.delete('read_history', where: 'id = ?', whereArgs: [id]);
      }
    }
  }

  // 清空阅读历史
  Future<void> clearReadHistory() async {
    final result = await _dbHelper.query('read_history');
    for (var item in result) {
      await _dbHelper.delete('read_history', where: 'id = ?', whereArgs: [item['id']]);
    }
  }

  // ===== 全局搜索 =====
  // 搜索知识库所有内容
  Future<KnowledgeSearchResult> searchAll(String keyword) async {
    final articles = await searchArticles(keyword);
    final faqs = await searchFAQs(keyword);

    return KnowledgeSearchResult(
      articles: articles,
      faqs: faqs,
      keyword: keyword,
    );
  }

  // ===== 示例数据 =====

  // 从 assets 加载 JSON 数据
  Future<List<Article>> _loadArticlesFromAssets() async {
    final String jsonString = await rootBundle.loadString('assets/data/knowledge_articles.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => Article.fromMap(item)).toList();
  }

  Future<List<KnowledgeTip>> _loadTipsFromAssets() async {
    final String jsonString = await rootBundle.loadString('assets/data/knowledge_tips.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => KnowledgeTip.fromMap(item)).toList();
  }

  Future<List<FAQ>> _loadFAQsFromAssets() async {
    final String jsonString = await rootBundle.loadString('assets/data/knowledge_faqs.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => FAQ.fromMap(item)).toList();
  }

  Future<List<Article>> _getSampleArticles() async {
    return _loadArticlesFromAssets();
  }

  Future<List<KnowledgeTip>> _getSampleTips() async {
    return _loadTipsFromAssets();
  }

  Future<List<FAQ>> _getSampleFAQs() async {
    return _loadFAQsFromAssets();
  }
}

// 知识库搜索结果
class KnowledgeSearchResult {
  final List<Article> articles;
  final List<FAQ> faqs;
  final String keyword;

  KnowledgeSearchResult({
    required this.articles,
    required this.faqs,
    required this.keyword,
  });

  bool get isEmpty => articles.isEmpty && faqs.isEmpty;
  int get totalCount => articles.length + faqs.length;
}
