import '../local/database_helper.dart';
import '../models/qa.dart';

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
