import 'dart:convert';
import 'package:flutter/services.dart';
import '../local/database_helper.dart';
import '../models/reptile.dart';
import '../models/record.dart';
import '../models/encyclopedia.dart';
import '../models/article.dart';
import '../models/qa.dart';
import '../models/medical.dart';
import '../models/knowledge_category.dart';
import '../models/knowledge_tip.dart';
import '../models/knowledge_collection.dart';
import '../models/faq.dart';
import 'breeding_repository.dart';

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

class QARepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 初始化问答数据
  Future<void> initData() async {
    await _dbHelper.initQAData();
  }

  // 获取所有问题
  Future<List<Question>> getAllQuestions({String? sortBy}) async {
    await _dbHelper.initQAData();
    String orderBy = 'created_at DESC';
    if (sortBy == 'hot') {
      orderBy = 'view_count DESC';
    } else if (sortBy == 'unanswered') {
      orderBy = 'answer_count ASC';
    }
    final result = await _dbHelper.query('questions', orderBy: orderBy);
    return result.map((map) => Question.fromMap(map)).toList();
  }

  // 按标签获取问题
  Future<List<Question>> getQuestionsByTag(String tag) async {
    await _dbHelper.initQAData();
    final result = await _dbHelper.query('questions', orderBy: 'created_at DESC');
    final filtered = result.where((map) {
      final tags = (map['tags'] ?? '').toString();
      return tags.contains(tag);
    }).toList();
    return filtered.map((map) => Question.fromMap(map)).toList();
  }

  // 按物种获取问题
  Future<List<Question>> getQuestionsBySpecies(String speciesId) async {
    await _dbHelper.initQAData();
    final result = await _dbHelper.queryWhere(
      'questions',
      where: 'species_id = ?',
      whereArgs: [speciesId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Question.fromMap(map)).toList();
  }

  // 获取问题详情
  Future<Question?> getQuestionDetail(String id) async {
    await _dbHelper.initQAData();
    final result = await _dbHelper.queryWhere(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Question.fromMap(result.first);
  }

  // 获取问题的回答
  Future<List<Answer>> getAnswers(String questionId) async {
    await _dbHelper.initQAData();
    final result = await _dbHelper.queryWhere(
      'answers',
      where: 'question_id = ?',
      whereArgs: [questionId],
      orderBy: 'is_accepted DESC, likes DESC',
    );
    return result.map((map) => Answer.fromMap(map)).toList();
  }

  // 搜索问题
  Future<List<Question>> searchQuestions(String keyword) async {
    await _dbHelper.initQAData();
    final result = await _dbHelper.query('questions', orderBy: 'created_at DESC');
    final kw = keyword.toLowerCase();
    final filtered = result.where((map) {
      final title = (map['title'] ?? '').toString().toLowerCase();
      final content = (map['content'] ?? '').toString().toLowerCase();
      return title.contains(kw) || content.contains(kw);
    }).toList();
    return filtered.map((map) => Question.fromMap(map)).toList();
  }

  // 发布问题
  Future<void> addQuestion(Question question) async {
    await _dbHelper.insert('questions', question.toMap());
  }

  // 添加回答
  Future<void> addAnswer(Answer answer) async {
    await _dbHelper.insert('answers', answer.toMap());
    // 更新问题回答数
    final questions = await _dbHelper.queryWhere(
      'questions',
      where: 'id = ?',
      whereArgs: [answer.questionId],
    );
    if (questions.isNotEmpty) {
      final question = questions.first;
      final answers = (question['answer_count'] ?? 0) as int;
      await _dbHelper.update(
        'questions',
        {'answer_count': answers + 1},
        where: 'id = ?',
        whereArgs: [answer.questionId],
      );
    }
  }

  // 采纳回答
  Future<void> acceptAnswer(String questionId, String answerId) async {
    await _dbHelper.update(
      'questions',
      {'is_resolved': 1, 'accepted_answer_id': answerId},
      where: 'id = ?',
      whereArgs: [questionId],
    );
    await _dbHelper.update(
      'answers',
      {'is_accepted': 1},
      where: 'id = ?',
      whereArgs: [answerId],
    );
  }

  // 点赞回答
  Future<void> likeAnswer(String answerId) async {
    final answers = await _dbHelper.queryWhere(
      'answers',
      where: 'id = ?',
      whereArgs: [answerId],
    );
    if (answers.isNotEmpty) {
      final answer = answers.first;
      final likes = (answer['likes'] ?? 0) as int;
      await _dbHelper.update(
        'answers',
        {'likes': likes + 1},
        where: 'id = ?',
        whereArgs: [answerId],
      );
    }
  }

  // 获取标签
  Future<List<QATag>> getTags() async {
    await _dbHelper.initQAData();
    final result = await _dbHelper.query('qa_tags');
    return result.map((map) => QATag.fromMap(map)).toList();
  }

  // 增加浏览数
  Future<void> viewQuestion(String id) async {
    final questions = await _dbHelper.queryWhere(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (questions.isNotEmpty) {
      final question = questions.first;
      final views = (question['view_count'] ?? 0) as int;
      await _dbHelper.update(
        'questions',
        {'view_count': views + 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}

class MedicalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 初始化医疗数据
  Future<void> initData() async {
    await _dbHelper.initMedicalData();
  }

  // 获取所有疾病
  Future<List<Disease>> getAllDiseases() async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.query('diseases', orderBy: 'name_zh ASC');
    return result.map((map) => Disease.fromMap(map)).toList();
  }

  // 按物种分类获取疾病
  Future<List<Disease>> getDiseasesBySpecies(String speciesCategory) async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.query('diseases');
    final filtered = result.where((map) {
      final category = (map['species_category'] ?? '').toString();
      return category == speciesCategory || speciesCategory == 'all';
    }).toList();
    return filtered.map((map) => Disease.fromMap(map)).toList();
  }

  // 按类别获取疾病
  Future<List<Disease>> getDiseasesByCategory(String category) async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.queryWhere(
      'diseases',
      where: 'category = ?',
      whereArgs: [category],
    );
    return result.map((map) => Disease.fromMap(map)).toList();
  }

  // 获取疾病详情
  Future<Disease?> getDiseaseDetail(String id) async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.queryWhere(
      'diseases',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Disease.fromMap(result.first);
  }

  // 搜索疾病
  Future<List<Disease>> searchDiseases(String keyword) async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.query('diseases');
    final kw = keyword.toLowerCase();
    final filtered = result.where((map) {
      final name = (map['name_zh'] ?? '').toString().toLowerCase();
      final nameEn = (map['name'] ?? '').toString().toLowerCase();
      final description = (map['description'] ?? '').toString().toLowerCase();
      return name.contains(kw) || nameEn.contains(kw) || description.contains(kw);
    }).toList();
    return filtered.map((map) => Disease.fromMap(map)).toList();
  }

  // 获取所有症状
  Future<List<Symptom>> getAllSymptoms() async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.query('symptoms', orderBy: 'name_zh ASC');
    return result.map((map) => Symptom.fromMap(map)).toList();
  }

  // 按症状查找可能疾病
  Future<List<Disease>> findDiseasesBySymptoms(List<String> symptomIds) async {
    await _dbHelper.initMedicalData();
    final allDiseases = await getAllDiseases();
    final matchedDiseases = <Disease>[];

    for (var disease in allDiseases) {
      final diseaseSymptomIds = disease.symptoms
          .map((s) => s.toLowerCase())
          .toList();

      int matchCount = 0;
      for (var symptomId in symptomIds) {
        if (diseaseSymptomIds.any((ds) => ds.contains(symptomId.toLowerCase()))) {
          matchCount++;
        }
      }
      if (matchCount > 0) {
        matchedDiseases.add(disease);
      }
    }

    return matchedDiseases;
  }

  // 获取紧急情况指南
  Future<List<EmergencyGuide>> getEmergencyGuides() async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.query('emergency_guides', orderBy: 'priority ASC');
    return result.map((map) => EmergencyGuide.fromMap(map)).toList();
  }
}

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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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
