export 'exhibition_repository.dart';
export 'price_alert_repository.dart';

import '../local/database_helper.dart';
import '../models/reptile.dart';
import '../models/record.dart';
import '../models/community.dart';
import '../models/encyclopedia.dart';
import '../models/article.dart';
import '../models/qa.dart';
import '../models/medical.dart';

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
