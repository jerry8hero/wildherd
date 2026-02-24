import '../data/models/exhibition.dart';
import '../data/models/article.dart';
import '../data/models/encyclopedia.dart';
import '../data/models/qa.dart';
import '../data/models/medical.dart';

/// 知识分析器
/// 用于分析资讯内容，生成摘要，建立知识索引，以便快速回答问题
class KnowledgeAnalyzer {
  static final KnowledgeAnalyzer _instance = KnowledgeAnalyzer._internal();
  factory KnowledgeAnalyzer() => _instance;
  KnowledgeAnalyzer._internal();

  // 知识摘要存储
  final Map<String, KnowledgeSummary> _summaries = {};

  // 关键词索引
  final Map<String, List<KnowledgeItem>> _keywordIndex = {};

  // 物种知识库
  final Map<String, SpeciesKnowledge> _speciesKnowledge = {};

  /// 分析并存储所有知识
  Future<void> analyzeAll({
    required List<Exhibition> exhibitions,
    required List<Article> articles,
    required List<ReptileSpecies> species,
    required List<Question> questions,
    required List<Disease> diseases,
  }) async {
    // 分析展览活动
    await _analyzeExhibitions(exhibitions);

    // 分析文章
    await _analyzeArticles(articles);

    // 分析物种知识
    await _analyzeSpecies(species);

    // 分析问答
    await _analyzeQuestions(questions);

    // 分析疾病
    await _analyzeDiseases(diseases);

    // 构建关键词索引
    _buildKeywordIndex();
  }

  /// 分析展览活动
  Future<void> _analyzeExhibitions(List<Exhibition> exhibitions) async {
    for (var exhibition in exhibitions) {
      final summary = KnowledgeSummary(
        id: 'exhibition_${exhibition.id}',
        title: exhibition.title,
        type: KnowledgeType.exhibition,
        keywords: _extractKeywords('${exhibition.title} ${exhibition.content}'),
        summary: _generateSummary(exhibition.content, maxLength: 200),
        relatedSpecies: _extractSpeciesMentions(exhibition.content),
        metadata: {
          'location': exhibition.location,
          'organizer': exhibition.organizer,
          'startTime': exhibition.startTime.toIso8601String(),
          'endTime': exhibition.endTime?.toIso8601String(),
        },
      );
      _summaries[summary.id] = summary;
    }
  }

  /// 分析文章
  Future<void> _analyzeArticles(List<Article> articles) async {
    for (var article in articles) {
      final summary = KnowledgeSummary(
        id: 'article_${article.id}',
        title: article.title,
        type: KnowledgeType.article,
        keywords: _extractKeywords('${article.title} ${article.summary} ${article.content}'),
        summary: _generateSummary(article.content, maxLength: 300),
        relatedSpecies: _extractSpeciesMentions(article.content),
        tags: article.tags,
        metadata: {
          'category': article.category,
          'author': article.author,
          'readCount': article.readCount,
        },
      );
      _summaries[summary.id] = summary;
    }
  }

  /// 分析物种知识
  Future<void> _analyzeSpecies(List<ReptileSpecies> speciesList) async {
    for (var species in speciesList) {
      final knowledge = SpeciesKnowledge(
        id: species.id,
        nameChinese: species.nameChinese,
        nameEnglish: species.nameEnglish,
        scientificName: species.scientificName,
        category: species.category,
        difficulty: species.difficulty,
        lifespan: species.lifespan,
        diet: species.diet,
        temperatureRange: TemperatureRange(
          min: species.minTemp ?? 0,
          max: species.maxTemp ?? 0,
        ),
        humidityRange: HumidityRange(
          min: species.minHumidity ?? 0,
          max: species.maxHumidity ?? 0,
        ),
        careSummary: _generateCareSummary(species),
        commonIssues: _extractCommonIssues(species.category),
      );
      _speciesKnowledge[species.id] = knowledge;

      // 同时创建摘要
      final summary = KnowledgeSummary(
        id: 'species_${species.id}',
        title: species.nameChinese,
        type: KnowledgeType.species,
        keywords: _extractKeywords(
          '${species.nameChinese} ${species.nameEnglish} ${species.scientificName} ${species.description}',
        ),
        summary: species.description,
        relatedSpecies: [species.nameChinese],
        metadata: {
          'difficulty': species.difficulty,
          'lifespan': species.lifespan,
          'diet': species.diet,
          'category': species.category,
        },
      );
      _summaries[summary.id] = summary;
    }
  }

  /// 分析问答
  Future<void> _analyzeQuestions(List<Question> questions) async {
    for (var question in questions) {
      final summary = KnowledgeSummary(
        id: 'question_${question.id}',
        title: question.title,
        type: KnowledgeType.question,
        keywords: _extractKeywords('${question.title} ${question.content}'),
        summary: _generateSummary(question.content, maxLength: 150),
        relatedSpecies: question.speciesName != null ? [question.speciesName!] : [],
        tags: question.tags,
        metadata: {
          'answerCount': question.answerCount,
          'isResolved': question.isResolved,
          'viewCount': question.viewCount,
        },
      );
      _summaries[summary.id] = summary;
    }
  }

  /// 分析疾病
  Future<void> _analyzeDiseases(List<Disease> diseases) async {
    for (var disease in diseases) {
      final summary = KnowledgeSummary(
        id: 'disease_${disease.id}',
        title: disease.nameZh,
        type: KnowledgeType.disease,
        keywords: _extractKeywords(
          '${disease.nameZh} ${disease.name} ${disease.description} ${disease.treatment}',
        ),
        summary: '症状: ${disease.symptoms.join(", ")}\n治疗: ${_generateSummary(disease.treatment, maxLength: 100)}',
        relatedSpecies: disease.relatedSpecies != null ? [disease.relatedSpecies!] : [],
        metadata: {
          'category': disease.category,
          'isEmergency': disease.isEmergency,
        },
      );
      _summaries[summary.id] = summary;
    }
  }

  /// 构建关键词索引
  void _buildKeywordIndex() {
    _keywordIndex.clear();
    for (var summary in _summaries.values) {
      for (var keyword in summary.keywords) {
        if (!_keywordIndex.containsKey(keyword)) {
          _keywordIndex[keyword] = [];
        }
        _keywordIndex[keyword]!.add(KnowledgeItem(
          id: summary.id,
          title: summary.title,
          type: summary.type,
        ));
      }
    }
  }

  /// 提取关键词
  List<String> _extractKeywords(String text) {
    // 简单的关键词提取
    final words = text.toLowerCase().split(RegExp(r'[\s,，。、]+'));
    final keywords = <String>[];

    // 过滤并提取有意义的词
    for (var word in words) {
      if (word.length >= 2) {
        keywords.add(word);
      }
    }

    // 去重并返回
    return keywords.toSet().toList();
  }

  /// 生成摘要
  String _generateSummary(String content, {int maxLength = 200}) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  /// 提取物种提及
  List<String> _extractSpeciesMentions(String text) {
    final species = <String>[];

    // 常见的物种关键词
    final speciesKeywords = [
      '玉米蛇', '球蟒', '黑王蛇', '豹纹守宫', '睫角守宫', '巨人守宫',
      '绿鬣蜥', '鬃狮蜥', '蓝舌石龙子', '红耳龟', '草龟', '黄缘闭壳龟',
      '角蛙', '蝾螈', '蜘蛛',
    ];

    for (var keyword in speciesKeywords) {
      if (text.contains(keyword)) {
        species.add(keyword);
      }
    }

    return species;
  }

  /// 生成饲养摘要
  String _generateCareSummary(ReptileSpecies species) {
    return '''
饲养难度: ${_getDifficultyText(species.difficulty)}
预期寿命: ${species.lifespan}年
食性: ${_getDietText(species.diet)}
温度: ${species.minTemp ?? 0}°C - ${species.maxTemp ?? 0}°C
湿度: ${species.minHumidity ?? 0}% - ${species.maxHumidity ?? 0}%
''';
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

  /// 提取常见问题
  List<String> _extractCommonIssues(String category) {
    switch (category) {
      case 'snake':
        return ['拒食', '蜕皮困难', '呼吸道感染', '螨虫'];
      case 'gecko':
        return ['断尾', '趾炎', '蜕皮困难', '拒食'];
      case 'turtle':
        return ['烂甲', '肺炎', '眼病', '腐皮'];
      case 'lizard':
        return ['代谢性骨病', '便秘', '呼吸道感染'];
      default:
        return [];
    }
  }

  // ===== 公共接口 =====

  /// 根据关键词搜索知识
  List<KnowledgeItem> searchByKeyword(String keyword) {
    final kw = keyword.toLowerCase();
    return _keywordIndex[kw] ?? [];
  }

  /// 根据物种获取知识
  SpeciesKnowledge? getSpeciesKnowledge(String speciesId) {
    return _speciesKnowledge[speciesId];
  }

  /// 根据物种名称获取知识
  SpeciesKnowledge? getSpeciesByName(String name) {
    for (var knowledge in _speciesKnowledge.values) {
      if (knowledge.nameChinese.contains(name) ||
          knowledge.nameEnglish.toLowerCase().contains(name.toLowerCase())) {
        return knowledge;
      }
    }
    return null;
  }

  /// 获取所有物种列表
  List<SpeciesKnowledge> getAllSpeciesKnowledge() {
    return _speciesKnowledge.values.toList();
  }

  /// 获取知识摘要
  KnowledgeSummary? getSummary(String id) {
    return _summaries[id];
  }

  /// 获取所有摘要
  List<KnowledgeSummary> getAllSummaries() {
    return _summaries.values.toList();
  }

  /// 根据类型获取摘要
  List<KnowledgeSummary> getSummariesByType(KnowledgeType type) {
    return _summaries.values.where((s) => s.type == type).toList();
  }

  /// 生成回答建议
  String generateSuggestion(String query) {
    final items = searchByKeyword(query);

    if (items.isEmpty) {
      return '抱歉，我没有找到与"$query"相关的知识。';
    }

    final buffer = StringBuffer();
    buffer.writeln('我找到了以下相关信息：\n');

    // 按类型分组
    final grouped = <KnowledgeType, List<KnowledgeItem>>{};
    for (var item in items) {
      grouped.putIfAbsent(item.type, () => []).add(item);
    }

    for (var entry in grouped.entries) {
      buffer.writeln('【${_getTypeName(entry.key)}】');
      for (var i = 0; i < entry.value.length && i < 3; i++) {
        buffer.writeln('  ${i + 1}. ${entry.value[i].title}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _getTypeName(KnowledgeType type) {
    switch (type) {
      case KnowledgeType.exhibition: return '展览活动';
      case KnowledgeType.article: return '知识文章';
      case KnowledgeType.species: return '物种百科';
      case KnowledgeType.question: return '问答';
      case KnowledgeType.disease: return '疾病';
    }
  }
}

/// 知识类型
enum KnowledgeType {
  exhibition,
  article,
  species,
  question,
  disease,
}

/// 知识摘要
class KnowledgeSummary {
  final String id;
  final String title;
  final KnowledgeType type;
  final List<String> keywords;
  final String summary;
  final List<String> relatedSpecies;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;

  KnowledgeSummary({
    required this.id,
    required this.title,
    required this.type,
    required this.keywords,
    required this.summary,
    this.relatedSpecies = const [],
    this.tags,
    this.metadata,
  });
}

/// 知识项（用于搜索结果）
class KnowledgeItem {
  final String id;
  final String title;
  final KnowledgeType type;

  KnowledgeItem({
    required this.id,
    required this.title,
    required this.type,
  });
}

/// 物种知识
class SpeciesKnowledge {
  final String id;
  final String nameChinese;
  final String nameEnglish;
  final String scientificName;
  final String category;
  final int difficulty;
  final int lifespan;
  final String diet;
  final TemperatureRange temperatureRange;
  final HumidityRange humidityRange;
  final String careSummary;
  final List<String> commonIssues;

  SpeciesKnowledge({
    required this.id,
    required this.nameChinese,
    required this.nameEnglish,
    required this.scientificName,
    required this.category,
    required this.difficulty,
    required this.lifespan,
    required this.diet,
    required this.temperatureRange,
    required this.humidityRange,
    required this.careSummary,
    required this.commonIssues,
  });
}

/// 温度范围
class TemperatureRange {
  final double min;
  final double max;

  TemperatureRange({required this.min, required this.max});
}

/// 湿度范围
class HumidityRange {
  final double min;
  final double max;

  HumidityRange({required this.min, required this.max});
}
