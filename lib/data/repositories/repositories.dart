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
    final sampleArticles = _getSampleArticles();
    for (var article in sampleArticles) {
      await _dbHelper.insert('knowledge_articles', article.toMap());
    }
  }

  // 初始化示例技巧数据
  Future<void> _initKnowledgeTips() async {
    final existing = await _dbHelper.query('knowledge_tips');
    if (existing.isNotEmpty) return;

    final sampleTips = _getSampleTips();
    for (var tip in sampleTips) {
      await _dbHelper.insert('knowledge_tips', tip.toMap());
    }
  }

  // 初始化示例FAQ数据
  Future<void> _initFAQs() async {
    final existing = await _dbHelper.query('faqs');
    if (existing.isNotEmpty) return;

    final sampleFAQs = _getSampleFAQs();
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

  List<Article> _getSampleArticles() {
    return [
      Article(
        id: 'kb001',
        title: '爬宠新手入门指南',
        summary: '如果你想养一只爬宠作为宠物，这篇指南将帮助你了解基本知识和准备工作。',
        content: '''
# 爬宠新手入门指南

## 什么是爬宠？

爬宠是指爬行动物作为宠物饲养，包括蛇、蜥蜴、龟、守宫等。它们具有独特的外观和行为习性，受到越来越多宠物爱好者的喜爱。

## 养爬宠的优势

1. **安静卫生**：爬宠不像猫狗那样会叫喊，适合居住在公寓中。
2. **占用空间小**：相对于猫狗，爬宠需要的饲养空间较小。
3. **饲养成本适中**：每天喂食一次即可，食物成本不高。
4. **寿命长**：很多爬宠可以活10-30年甚至更长。

## 新手推荐物种

### 1. 豹纹守宫
- **难度**：入门级
- **价格**：100-300元
- **特点**：体型小、性格温顺、色彩丰富
- **饲养要点**：需要加热垫、饲养箱、钙粉

### 2. 玉米蛇
- **难度**：入门级
- **价格**：150-500元
- **特点**：性格温顺、花色多样、无毒
- **饲养要点**：需要适当的饲养箱、加温设备

### 3. 巴西龟
- **难度**：入门级
- **价格**：20-100元
- **特点**：适应性强、互动性好
- **饲养要点**：需要水族箱、晒台、UVB灯

## 必备设备

1. **饲养箱**：根据物种选择合适的尺寸
2. **加热设备**：加热垫、陶瓷加热器等
3. **温湿度计**：监控环境参数
4. **垫材**：根据物种选择合适的垫材
5. **食具和水盆**：合适的尺寸和款式

## 注意事项

- 购买正规渠道的宠物
- 了解当地法规（某些物种可能受保护）
- 做好长期饲养的准备
- 了解如何处理宠物生病的情况
''',
        category: 'beginner',
        categoryId: 'beginner_guide',
        difficulty: 1,
        readTimeMinutes: 10,
        author: 'WildHerd',
        tags: ['新手', '入门', '指南'],
        isFeatured: true,
        createdAt: DateTime.now(),
      ),
      Article(
        id: 'kb002',
        title: '爬宠饲养箱布置完全指南',
        summary: '学习如何为你的爬宠打造一个舒适健康的饲养环境。',
        content: '''
# 爬宠饲养箱布置完全指南

## 饲养箱的重要性

一个合适的饲养箱是爬宠健康成长的基础。它需要提供：
- 安全的居住空间
- 适宜的温度和湿度
- 足够的活动空间
- 必要的晒点和躲避处

## 饲养箱的选择

### 玻璃饲养箱
- **优点**：美观、易于观察、保温性好
- **缺点**：较重、易碎、价格较高
- **适用**：守宫、蜥蜴、部分蛇类

### 塑料饲养箱
- **优点**：轻便、便宜、不易碎
- **缺点**：不耐高温、容易刮花
- **适用**：小型守宫、幼体

### 木质饲养箱
- **优点**：保温性好、可自行制作
- **缺点**：容易受潮、不易清洁
- **适用**：陆龟、变色龙

## 必备设备

### 1. 加热设备
- **加热垫**：放置在饲养箱底部或侧面
- **陶瓷加热器**：加热均匀，寿命长
- **加热灯**：同时提供热源和光照

### 2. 温控设备
- **温控器**：精确控制温度
- **温度计**：监测饲养箱温度

### 3. 湿度控制
- **加湿设备**：雾化器、加湿垫
- **湿度计**：监测湿度水平

### 4. 照明设备
- **UVB灯**：促进钙质吸收
- **晒灯**：提供热点
- **LED灯**：提供日常照明

## 垫材选择

| 物种 | 推荐垫材 |
|------|----------|
| 守宫 | 报纸、厨房纸、爬虫砂 |
| 蛇类 | 报纸、树皮、白杨木屑 |
| 陆龟 | 椰土、混合垫材 |
| 水龟 | 水族专用垫材 |

## 环境布置要点

1. **晒点**：提供热点，温度比周围高5-10度
2. **躲避**：至少提供两个躲避处（热区和冷区）
3. **水盆**：足够大让宠物可以浸泡
4. **装饰**：仿真植物、树枝、岩石（确保安全）
''',
        category: 'care',
        categoryId: 'care_housing',
        difficulty: 2,
        readTimeMinutes: 8,
        author: 'WildHerd',
        tags: ['饲养箱', '环境', '布置'],
        isFeatured: true,
        createdAt: DateTime.now(),
      ),
      Article(
        id: 'kb003',
        title: '爬宠常见疾病与预防',
        summary: '了解爬宠最常见的健康问题以及如何预防。',
        content: '''
# 爬宠常见疾病与预防

## 呼吸道感染

### 症状
- 张嘴呼吸
- 呼吸有杂音
- 鼻腔有分泌物
- 食欲下降

### 原因
- 温度过低
- 湿度不适
- 通风不良

### 预防
- 保持适宜温度（根据物种调整）
- 维持适当湿度
- 保证饲养箱通风

## 寄生虫感染

### 症状
- 体重下降
- 食欲正常但消瘦
- 粪便中有虫体
- 频繁挠痒

### 原因
- 食物携带寄生虫
- 环境不洁
- 新宠未隔离

### 预防
- 购买正规来源的宠物
- 定期驱虫
- 保持环境清洁

## 代谢性骨病（缺钙）

### 症状
- 骨骼软化
- 四肢无力
- 爬行困难
- 壳软（龟类）

### 原因
- 缺乏UVB照射
- 钙摄入不足
- 维生素D缺乏

### 预防
- 提供充足的UVB照射
- 定期补充钙粉和维生素
- 合理饮食

## 皮肤问题

### 常见类型
1. **真菌感染**：白色斑点、皮肤脱落
2. **细菌感染**：红肿、化脓
3. **螨虫**：黑色小点、频繁挠痒

### 预防
- 保持环境干燥清洁
- 定期检查宠物皮肤
- 新宠隔离观察

## 总结

预防爬宠疾病的关键在于：
1. 提供适宜的生活环境
2. 合理均衡的饮食
3. 保持清洁卫生
4. 定期观察宠物状态
5. 发现异常及时就医
''',
        category: 'health',
        categoryId: 'health_disease',
        difficulty: 3,
        readTimeMinutes: 7,
        author: 'WildHerd',
        tags: ['疾病', '健康', '预防'],
        isFeatured: true,
        createdAt: DateTime.now(),
      ),
      // 繁殖技术文章
      Article(
        id: 'kb004',
        title: '爬宠繁殖入门指南',
        summary: '了解爬宠繁殖的基本知识和准备工作。',
        content: '''
# 爬宠繁殖入门指南

## 繁殖前的准备

### 1. 确定繁殖目标
在开始繁殖之前，需要明确：
- 你为什么要繁殖？
- 你有足够的空间饲养幼体吗？
- 你能找到幼体的买家或领养人吗？

### 2. 评估宠物健康状况
确保繁殖的个体：
- 年龄适合繁殖（已成熟）
- 身体健康，无疾病
- 体型正常，体重合适

### 3. 学习相关知识
- 了解目标物种的繁殖季节
- 掌握繁殖环境要求
- 熟悉孵化技术

## 繁殖环境设置

### 温度控制
大多数爬宠繁殖需要：
- **温差**：提供冷区和热区
- **适宜温度**：根据物种调整（通常25-32°C）
- **夜间降温**：模拟自然昼夜温差

### 湿度管理
- 孵化期间湿度要求较高
- 根据物种调整（通常60-80%）
- 定期检查湿度计

### 繁殖箱布置
- 提供产卵介质（如椰土、蛭石）
- 设置躲避处
- 保证空间充足

## 孵化技术

### 孵化介质
推荐使用：
- **蛭石**：保湿性好，常用
- **椰土**：天然材料
- **珍珠岩**：透气性好

### 孵化温度与时间
| 物种 | 孵化温度 | 孵化时间 |
|------|----------|----------|
| 豹纹守宫 | 26-28°C | 45-60天 |
| 玉米蛇 | 26-30°C | 55-65天 |
| 豹龟 | 28-30°C | 90-120天 |

### 孵化期管理
1. 定期检查蛋的状态
2. 保持温度稳定
3. 适时喷水保湿
4. 标记蛋的方向（不要翻动）

## 幼体护理

### 出生后的处理
- 让幼体自然出壳
- 提供适当的湿度
- 准备好食物

### 喂食要点
- 幼体需要更频繁喂食
- 食物大小要适合
- 确保饮水充足

### 注意事项
- 单独饲养避免互残
- 保持环境清洁
- 观察健康状况
''',
        category: 'breeding',
        categoryId: 'breeding_conditions',
        difficulty: 4,
        readTimeMinutes: 12,
        author: 'WildHerd',
        tags: ['繁殖', '孵化', '入门'],
        isFeatured: false,
        createdAt: DateTime.now(),
      ),
      // 器材设备文章
      Article(
        id: 'kb005',
        title: '爬宠灯具设备选购指南',
        summary: '全面介绍爬宠饲养所需的各类灯具设备。',
        content: '''
# 爬宠灯具设备选购指南

## 为什么需要灯具？

爬宠大多是变温动物，需要从环境获取热量：
- **UVB灯**：促进维生素D3合成，帮助钙质吸收
- **UVA灯**：提供热量，增加食欲
- **陶瓷加热器**：持续供热，不发光
- **LED灯**：日常照明，节能

## 常见灯具类型

### 1. UVB灯
**作用**：
- 模拟自然紫外线
- 预防代谢性骨病
- 促进健康成长

**类型**：
- **紧凑型荧光灯**：适合小型饲养箱
- **管灯**：覆盖范围广
- **汞灯**：同时提供UVA/UVB/热量

**选择建议**：
- 守宫、蛇类：5-6% UVB
- 蜥蜴、龟类：8-10% UVB
- 每天照射8-12小时

### 2. 加热灯
**类型**：
- **白炽灯**：同时照明+加热
- **红色夜灯**：夜间保温，不打扰休息
- **陶瓷加热器**：仅供热，不发光

**功率选择**：
根据饲养箱大小选择：
- 30cm以下：25-50W
- 30-60cm：50-75W
- 60cm以上：75-100W+

### 3. LED灯
**作用**：
- 提供日常照明
- 模拟自然光照周期
- 节能省电

**选择建议**：
- 选择全光谱LED
- 色温4000-6500K
- 可设置定时开关

## 灯具安装建议

### 1. 位置设置
- 晒点上方15-30cm
- 避免直接接触
- 预留活动空间

### 2. 安全注意
- 使用灯罩防止烫伤
- 固定牢靠防止掉落
- 接线要规范

### 3. 使用周期
- UVB灯：6-12个月更换
- 加热灯：按需更换
- 定期检查功能

## 推荐配置方案

### 守宫（豹纹守宫）
- 陶瓷加热器：24小时供热
- LED灯：日常照明
- 不需要UVB（可通过补钙替代）

### 蜥蜴（鬃狮蜥）
- 汞灯：UVA+UVB+加热
- LED灯：补充照明
- 陶瓷加热器：夜间保温

### 龟类
- UVA+UVB灯：每天8-12小时
- 加热灯：维持水温
- LED灯：整体照明
''',
        category: 'equipment',
        categoryId: 'equipment_lighting',
        difficulty: 2,
        readTimeMinutes: 10,
        author: 'WildHerd',
        tags: ['灯具', 'UVB', '设备'],
        isFeatured: true,
        createdAt: DateTime.now(),
      ),
      // 新手入门文章
      Article(
        id: 'kb006',
        title: '爬宠购买渠道与挑选技巧',
        summary: '如何选择健康的爬宠以及购买渠道推荐。',
        content: '''
# 爬宠购买渠道与挑选技巧

## 购买渠道

### 1. 实体店
**优点**：
- 可以现场挑选
- 直观了解宠物状态
- 有问题可即时售后

**缺点**：
- 品种有限
- 价格相对较高
- 需要亲自前往

**推荐场所**：
- 正规宠物店
- 爬宠专卖店
- 异宠医院（部分有销售）

### 2. 网络平台
**优点**：
- 品种丰富
- 价格相对便宜
- 送货上门

**缺点**：
- 无法现场挑选
- 运输风险
- 售后可能不便

**注意事项**：
- 选择信誉好的卖家
- 查看买家评价
- 了解售后政策

### 3. 爬宠展会
**优点**：
- 品种齐全
- 可以和卖家直接交流
- 价格相对优惠

**缺点**：
- 时间地点受限
- 人较多需要排队

## 挑选技巧

### 健康检查要点

#### 整体状态
- 精神活跃，无嗜睡
- 身体圆润，无明显消瘦
- 爬行正常，无异常姿态

#### 外观检查
- 眼睛明亮，无分泌物
- 嘴巴闭合正常，无流涎
- 皮肤完整，无溃烂
- 排泄正常，无异常

#### 行为观察
- 对外界刺激有反应
- 食欲良好（如果当场喂食）
- 无异常攻击行为

### 避免购买
- 野外捕获的个体
- 状态不佳的个体
- 畸形或残疾个体
- 来路不明的个体

## 价格参考

| 物种 | 价格区间 | 备注 |
|------|----------|------|
| 豹纹守宫 | 100-500元 | 变异基因价格高 |
| 玉米蛇 | 150-800元 | 变异基因价格高 |
| 巴西龟 | 20-100元 | 苗子较便宜 |
| 鬃狮蜥 | 200-600元 | 苗子较便宜 |
| 睫角守宫 | 150-400元 | 热门物种 |

## 注意事项

### 1. 合法合规
- 了解当地法规
- 确认物种不属于保护动物
- 购买有合法来源的个体

### 2. 做好准备
- 先准备好饲养设备
- 了解饲养知识
- 确保有足够时间和精力

### 3. 索取凭证
- 购买发票或收据
- 物种信息卡
- 疫苗或驱虫记录（如有）
''',
        category: 'beginner',
        categoryId: 'beginner_guide',
        difficulty: 1,
        readTimeMinutes: 8,
        author: 'WildHerd',
        tags: ['购买', '渠道', '挑选'],
        isFeatured: false,
        createdAt: DateTime.now(),
      ),
      // 饲养指南文章
      Article(
        id: 'kb007',
        title: '爬宠喂食营养全面指南',
        summary: '了解不同爬宠的食性特点和科学的喂食方法。',
        content: '''
# 爬宠喂食营养全面指南

## 爬宠食性分类

### 1. 肉食性（Carnivore）
**代表物种**：蛇类、巨蜥、部分守宫

**食物类型**：
-  rodents（鼠类）
-  birds（鸟类）
-  eggs（蛋类）
-  insects（昆虫，部分）

**喂食频率**：
- 幼体：每周2-3次
- 成体：每周1-2次

### 2. 草食性（Herbivore）
**代表物种**：陆龟、部分鬣蜥

**食物类型**：
- 蔬菜（深绿色叶菜为主）
- 水果（适量）
- 草本植物
- 专用龟粮

**喂食频率**：
- 幼体：每日喂食
- 成体：每日或隔日喂食

### 3. 杂食性（Omnivore）
**代表物种**：鬃狮蜥、变色龙、部分守宫

**食物类型**：
- 昆虫（蟋蟀、杜比亚蟑螂等）
- 蔬菜水果
- 专用饲料

**喂食频率**：
- 幼体：每日喂食
- 成体：每周3-4次

## 食物营养指南

### 昆虫类营养值
| 昆虫 | 蛋白质 | 脂肪 | 钙磷比 |
|------|--------|------|--------|
| 蟋蟀 | 20% | 6% | 1:1 |
| 杜比亚 | 23% | 7% | 1:1.7 |
| 面包虫 | 18% | 14% | 1:15 |
| 大麦虫 | 18% | 17% | 1:15 |

### 蔬菜营养值
| 蔬菜 | 钙含量 | 推荐程度 |
|------|--------|----------|
| 羽衣甘蓝 | 高 | ★★★★★ |
| 蒲公英叶 | 高 | ★★★★★ |
| 莴苣 | 低 | ★★☆☆☆ |
| 胡萝卜 | 中 | ★★★☆☆ |

## 喂食注意事项

### 1. 食物大小
- 食物宽度不应超过爬宠头部宽度
- 幼体喂食小型食物
- 活食可适当大小

### 2. 喂食环境
- 安静的环境利于进食
- 清理剩余食物
- 观察进食状态

### 3. 补钙与维生素
- 定期补充钙粉
- 每周1-2次维生素
- UVB照射促进钙吸收

### 4. 饮水
- 保持饮水新鲜
- 部分物种需要喷雾饮水
- 水盆大小要合适

## 常见喂食问题

### 拒食原因
1. 环境温度不适
2. 刚到新环境
3. 蜕皮期
4. 疾病

### 处理方法
- 检查环境参数
- 提供安静环境
- 尝试不同食物
- 咨询兽医
''',
        category: 'care',
        categoryId: 'care_feeding',
        difficulty: 2,
        readTimeMinutes: 10,
        author: 'WildHerd',
        tags: ['喂食', '营养', '食物'],
        isFeatured: false,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<KnowledgeTip> _getSampleTips() {
    return [
      KnowledgeTip(
        id: 'tip001',
        title: '如何判断守宫是否吃饱',
        content: '观察守宫的腹部，如果腹部鼓起来且圆润，说明已经吃饱。一般幼体每天喂食，成体每2-3天喂食一次。',
        categoryId: 'care_feeding',
        tags: ['守宫', '喂食', '判断'],
        createdAt: DateTime.now(),
      ),
      KnowledgeTip(
        id: 'tip002',
        title: '爬宠洗澡的正确方法',
        content: '使用温水（约30度），水深不超过爬宠高度的一半。轻轻清洗，避免水进入口鼻。洗澡后务必擦干并保持温暖。',
        categoryId: 'care_daily',
        tags: ['洗澡', '护理', '方法'],
        createdAt: DateTime.now(),
      ),
      KnowledgeTip(
        id: 'tip003',
        title: '如何安全抓取蛇类',
        content: '从侧面轻轻把手放在蛇身下支撑，让蛇感觉到你的手再慢慢拿起。避免从上方突然抓取，这会让蛇感到威胁。',
        categoryId: 'care_daily',
        tags: ['蛇', '抓取', '安全'],
        createdAt: DateTime.now(),
      ),
      // 更多技巧
      KnowledgeTip(
        id: 'tip004',
        title: '如何给守宫补充钙质',
        content: '在食盆中放少量钙粉，让守宫自行舔食。每周可喂食1-2次带钙粉的蟋蟀。钙粉建议选择含D3的。',
        categoryId: 'care_feeding',
        tags: ['守宫', '钙粉', '营养'],
        createdAt: DateTime.now(),
      ),
      KnowledgeTip(
        id: 'tip005',
        title: '判断陆龟是否健康',
        content: '观察陆龟的甲壳是否坚硬、眼睛是否明亮有神、鼻孔是否通畅、肛门是否干净。健康的陆龟应该爬行积极、食欲良好。',
        categoryId: 'health_prevent',
        tags: ['陆龟', '健康', '检查'],
        createdAt: DateTime.now(),
      ),
      KnowledgeTip(
        id: 'tip006',
        title: '爬宠蜕皮期护理',
        content: '蜕皮期间保持适度湿度，可适当喷雾。提供粗糙物体帮助蜕皮。不要强行拉扯未脱落的皮，以免造成伤害。',
        categoryId: 'care_daily',
        tags: ['蜕皮', '护理', '方法'],
        createdAt: DateTime.now(),
      ),
      KnowledgeTip(
        id: 'tip007',
        title: '如何让蛇类开食',
        content: '新买的蛇类先静养2-3天再喂食。可尝试用活鼠引诱，或将鼠在温水中浸泡后投喂。保持饲养箱安静，光线昏暗。',
        categoryId: 'care_feeding',
        tags: ['蛇', '开食', '方法'],
        createdAt: DateTime.now(),
      ),
      KnowledgeTip(
        id: 'tip008',
        title: '鬃狮蜥饲料昆虫大小选择',
        content: '昆虫宽度不应超过鬃狮蜥两眼之间的距离。幼体喂食针头蟋蟀，成体可喂食杜比亚蟑螂或大麦虫。',
        categoryId: 'care_feeding',
        tags: ['鬃狮蜥', '昆虫', '大小'],
        createdAt: DateTime.now(),
      ),
      KnowledgeTip(
        id: 'tip009',
        title: '龟类晒背注意事项',
        content: '提供晒背平台，让龟可以完全离开水面。避免阳光直射导致过热，可设置阴凉处。使用UVB灯也可满足需求。',
        categoryId: 'care_housing',
        tags: ['龟', '晒背', 'UVB'],
        createdAt: DateTime.now(),
      ),
      KnowledgeTip(
        id: 'tip010',
        title: '如何清洁饲养箱',
        content: '日常清洁：清除粪便和剩余食物。每周：更换垫材、清洁造景物品。每月：彻底消毒，使用宠物安全的消毒剂。',
        categoryId: 'care_daily',
        tags: ['清洁', '卫生', '方法'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<FAQ> _getSampleFAQs() {
    return [
      FAQ(
        id: 'faq001',
        question: '爬宠多久喂一次食？',
        answer: '这取决于物种和年龄。幼体通常每天喂食，成体可能每3-7天喂食一次。蛇类一般每周喂食1-2次，守宫每2-3天喂食一次。',
        categoryId: 'care_feeding',
        keywords: ['喂食频率', '多久', '食物'],
        createdAt: DateTime.now(),
      ),
      FAQ(
        id: 'faq002',
        question: '爬宠需要每天晒太阳吗？',
        answer: '大部分爬宠需要UVB照射来合成维生素D3，促进钙质吸收。如果使用UVB灯，每天照射8-12小时即可。不建议直接晒太阳，容易导致过热。',
        categoryId: 'care_housing',
        keywords: ['晒太阳', 'UVB', '光照'],
        createdAt: DateTime.now(),
      ),
      FAQ(
        id: 'faq003',
        question: '爬宠会认主人吗？',
        answer: '爬宠是冷血动物，没有像哺乳动物那样的社交本能。但它们可以学习识别主人喂食时的动作和时间，形成条件反射。与主人互动后会更加温顺。',
        categoryId: 'beginner_basics',
        keywords: ['认主人', '互动', '感情'],
        createdAt: DateTime.now(),
      ),
      FAQ(
        id: 'faq004',
        question: '爬宠冬眠需要准备什么？',
        answer: '如果你的爬宠需要冬眠，需要准备：1）逐渐降温的过渡期；2）安全冬眠箱（保湿、透气）；3）冬眠前清空肠胃；4）定期检查状态；5）准备加温设备以备不时之需。',
        categoryId: 'care_daily',
        keywords: ['冬眠', '准备', '温度'],
        createdAt: DateTime.now(),
      ),
      // 更多FAQ
      FAQ(
        id: 'faq005',
        question: '爬宠可以活多久？',
        answer: '不同物种寿命差异很大：豹纹守宫通常15-20年，玉米蛇15-20年，巴西龟30-50年，某些陆龟可达100年以上。',
        categoryId: 'beginner_basics',
        keywords: ['寿命', '年龄', '长期'],
        createdAt: DateTime.now(),
      ),
      FAQ(
        id: 'faq006',
        question: '爬宠有细菌吗？会传人吗？',
        answer: '爬宠确实可能携带一些细菌，如沙门氏菌。但只要保持良好卫生习惯，接触后洗手，就不必过度担心。建议不要让爬宠进入厨房或接触食物。',
        categoryId: 'health_prevent',
        keywords: ['细菌', '卫生', '安全'],
        createdAt: DateTime.now(),
      ),
      FAQ(
        id: 'faq007',
        question: '爬宠会叫吗？',
        answer: '大多数爬宠比较安静。但有些物种会发出声音：守宫会发出叫声，龟类会发出嘶嘶声或咕噜声，某些蜥蜴会发出警告声。',
        categoryId: 'beginner_basics',
        keywords: ['叫声', '声音', '安静'],
        createdAt: DateTime.now(),
      ),
      FAQ(
        id: 'faq008',
        question: '爬宠需要每天陪伴吗？',
        answer: '爬宠不需要像猫狗那样每天陪伴。它们是观赏性宠物，不需要社交互动。但定期观察和互动有助于了解宠物健康状况。',
        categoryId: 'beginner_basics',
        keywords: ['陪伴', '互动', '时间'],
        createdAt: DateTime.now(),
      ),
      FAQ(
        id: 'faq009',
        question: '爬宠会咬人吗？',
        answer: '大多数爬宠性格温顺，不主动攻击人。但受到威胁或误认为是食物时可能会咬人。被咬后需要清洁消毒，如果咬伤严重需就医。',
        categoryId: 'care_daily',
        keywords: ['咬人', '安全', '互动'],
        createdAt: DateTime.now(),
      ),
      FAQ(
        id: 'faq010',
        question: '爬宠需要驱虫吗？',
        answer: '野外捕获的爬宠或新买的宠物建议进行驱虫。人工繁殖的宠物如果状态良好，一般不需要定期驱虫。具体可以咨询异宠兽医。',
        categoryId: 'health_prevent',
        keywords: ['驱虫', '寄生虫', '健康'],
        createdAt: DateTime.now(),
      ),
      FAQ(
        id: 'faq011',
        question: '如何判断爬宠是否生病？',
        answer: '常见生病征兆包括：食欲下降或拒食、嗜睡、体重骤降、粪便异常、皮肤问题（如变色、溃烂）、呼吸异常、眼睛浑浊或分泌物增多。',
        categoryId: 'health_disease',
        keywords: ['生病', '症状', '健康'],
        createdAt: DateTime.now(),
      ),
      FAQ(
        id: 'faq012',
        question: '爬宠可以混养吗？',
        answer: '一般不建议混养。不同物种可能传播疾病，而且存在捕食风险。即使同物种混养，也可能出现领地争斗或互相伤害。建议单独饲养。',
        categoryId: 'care_housing',
        keywords: ['混养', '单独', '安全'],
        createdAt: DateTime.now(),
      ),
    ];
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
