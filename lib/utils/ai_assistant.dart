import 'knowledge_analyzer.dart';

/// AI 助手
/// 基于知识库分析，快速给出建议
class AIAssistant {
  static final AIAssistant _instance = AIAssistant._internal();
  factory AIAssistant() => _instance;
  AIAssistant._internal();

  final KnowledgeAnalyzer _analyzer = KnowledgeAnalyzer();

  bool _isInitialized = false;

  /// 初始化知识库
  Future<void> initialize({
    required List<dynamic> exhibitions,
    required List<dynamic> articles,
    required List<dynamic> species,
    required List<dynamic> questions,
    required List<dynamic> diseases,
  }) async {
    if (_isInitialized) return;

    await _analyzer.analyzeAll(
      exhibitions: exhibitions.cast(),
      articles: articles.cast(),
      species: species.cast(),
      questions: questions.cast(),
      diseases: diseases.cast(),
    );

    _isInitialized = true;
  }

  /// 回答问题
  String answer(String question) {
    if (!_isInitialized) {
      return '知识库尚未加载完成，请稍后再试。';
    }

    // 分析问题类型
    final questionType = _analyzeQuestionType(question);

    switch (questionType) {
      case QuestionType.speciesRecommendation:
        return _recommendSpecies(question);
      case QuestionType.careGuide:
        return _provideCareGuide(question);
      case QuestionType.disease:
        return _handleDisease(question);
      case QuestionType.exhibition:
        return _findExhibition(question);
      case QuestionType.general:
        return _handleGeneral(question);
    }
  }

  /// 分析问题类型
  QuestionType _analyzeQuestionType(String question) {
    final q = question.toLowerCase();

    // 物种推荐
    if (q.contains('推荐') || q.contains('适合') || q.contains('新手') ||
        q.contains('好养') || q.contains('入门')) {
      return QuestionType.speciesRecommendation;
    }

    // 饲养指南
    if (q.contains('饲养') || q.contains('喂食') || q.contains('温度') ||
        q.contains('湿度') || q.contains('环境')) {
      return QuestionType.careGuide;
    }

    // 疾病
    if (q.contains('病') || q.contains('症状') || q.contains('治疗') ||
        q.contains('怎么办')) {
      return QuestionType.disease;
    }

    // 展览
    if (q.contains('展览') || q.contains('活动') || q.contains('展会')) {
      return QuestionType.exhibition;
    }

    return QuestionType.general;
  }

  /// 推荐物种
  String _recommendSpecies(String question) {
    final q = question.toLowerCase();
    final allSpecies = _analyzer.getAllSpeciesKnowledge();

    // 根据用户偏好筛选
    List<SpeciesKnowledge> recommended;

    if (q.contains('新手') || q.contains('入门') || q.contains('第一次')) {
      // 推荐难度1-2的物种
      recommended = allSpecies.where((s) => s.difficulty <= 2).take(5).toList();
    } else if (q.contains('蛇')) {
      recommended = allSpecies.where((s) => s.category == 'snake').take(5).toList();
    } else if (q.contains('守宫') || q.contains('壁虎')) {
      recommended = allSpecies.where((s) => s.category == 'gecko').take(5).toList();
    } else if (q.contains('龟')) {
      recommended = allSpecies.where((s) => s.category == 'turtle').take(5).toList();
    } else if (q.contains('蜥')) {
      recommended = allSpecies.where((s) => s.category == 'lizard').take(5).toList();
    } else {
      // 默认推荐简单物种
      recommended = allSpecies.where((s) => s.difficulty <= 2).take(5).toList();
    }

    if (recommended.isEmpty) {
      return '抱歉，没有找到符合条件的物种推荐。';
    }

    final buffer = StringBuffer();
    buffer.writeln('根据您的需求，为您推荐以下物种：\n');

    for (var i = 0; i < recommended.length; i++) {
      final s = recommended[i];
      buffer.writeln('${i + 1}. ${s.nameChinese} (${s.nameEnglish})');
      buffer.writeln('   饲养难度: ${_getDifficultyText(s.difficulty)}');
      buffer.writeln('   预期寿命: ${s.lifespan}年');
      buffer.writeln('   食性: ${_getDietText(s.diet)}');
      buffer.writeln('   温度: ${s.temperatureRange.min}-${s.temperatureRange.max}°C');
      buffer.writeln();
    }

    buffer.writeln('如需了解具体物种的详细信息，请告诉我物种名称。');

    return buffer.toString();
  }

  /// 提供饲养指南
  String _provideCareGuide(String question) {
    // 提取物种名称
    String? speciesName;
    final allSpecies = _analyzer.getAllSpeciesKnowledge();

    for (var s in allSpecies) {
      if (question.contains(s.nameChinese) ||
          question.toLowerCase().contains(s.nameEnglish.toLowerCase())) {
        speciesName = s.nameChinese;
        break;
      }
    }

    if (speciesName == null) {
      // 尝试搜索相关知识
      final results = _analyzer.searchByKeyword(question);
      if (results.isNotEmpty) {
        return _analyzer.generateSuggestion(question);
      }
      return '请告诉我您想了解哪种爬宠的饲养方法？';
    }

    final knowledge = _analyzer.getSpeciesByName(speciesName);
    if (knowledge == null) {
      return '抱歉，我没有找到关于$speciesName的详细信息。';
    }

    return '''
【${knowledge.nameChinese} 饲养指南】

${knowledge.careSummary}

【常见问题】
${knowledge.commonIssues.map((e) => '- $e').join('\n')}

如需了解更多，请告诉我具体问题。
''';
  }

  /// 处理疾病相关问题
  String _handleDisease(String question) {
    final results = _analyzer.searchByKeyword(question);

    final diseases = results
        .where((r) => r.type == KnowledgeType.disease)
        .take(3)
        .toList();

    if (diseases.isEmpty) {
      return '抱歉，没有找到相关的疾病信息。建议您描述一下宠物的具体症状。';
    }

    final buffer = StringBuffer();
    buffer.writeln('我找到以下可能相关的疾病信息：\n');

    for (var i = 0; i < diseases.length; i++) {
      final summary = _analyzer.getSummary(diseases[i].id);
      if (summary != null) {
        buffer.writeln('${i + 1}. ${summary.title}');
        buffer.writeln('   ${summary.summary}');
        buffer.writeln();
      }
    }

    buffer.writeln('如果需要更详细的医疗建议，请咨询专业兽医。');

    return buffer.toString();
  }

  /// 查找展览
  String _findExhibition(String question) {
    final results = _analyzer.searchByKeyword(question);

    final exhibitions = results
        .where((r) => r.type == KnowledgeType.exhibition)
        .take(5)
        .toList();

    if (exhibitions.isEmpty) {
      return '目前没有找到相关的展览活动信息。';
    }

    final buffer = StringBuffer();
    buffer.writeln('为您找到以下展览活动：\n');

    for (var i = 0; i < exhibitions.length; i++) {
      final summary = _analyzer.getSummary(exhibitions[i].id);
      if (summary != null) {
        final location = summary.metadata?['location'] ?? '';
        final organizer = summary.metadata?['organizer'] ?? '';
        buffer.writeln('${i + 1}. ${summary.title}');
        if (location.isNotEmpty) buffer.writeln('   地点: $location');
        if (organizer.isNotEmpty) buffer.writeln('   主办: $organizer');
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// 处理一般问题
  String _handleGeneral(String question) {
    final results = _analyzer.searchByKeyword(question);

    if (results.isEmpty) {
      return '''抱歉，我不太理解您的问题。

您可以尝试问以下类型的问题：
- 推荐适合新手的爬宠
- XXX物种怎么饲养
- 蛇类常见疾病有哪些
- 最近有什么展览活动
''';
    }

    return _analyzer.generateSuggestion(question);
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1: return '非常简单';
      case 2: return '简单';
      case 3: return '中等';
      case 4: return '较难';
      case 5: return '困难';
      default: return '未知';
    }
  }

  String _getDietText(String diet) {
    switch (diet) {
      case 'carnivore': return '肉食性';
      case 'herbivore': return '草食性';
      case 'omnivore': return '杂食性';
      default: return diet;
    }
  }
}

/// 问题类型
enum QuestionType {
  speciesRecommendation, // 物种推荐
  careGuide, // 饲养指南
  disease, // 疾病
  exhibition, // 展览
  general, // 一般
}
