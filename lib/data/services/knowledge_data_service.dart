import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/article.dart';
import '../models/knowledge_tip.dart';
import '../models/faq.dart';

/// 知识库数据服务
/// 从JSON文件加载知识库内容
class KnowledgeDataService {
  static const String _dataFilePath = 'assets/data/knowledge_base.json';

  /// 从JSON文件加载所有数据
  static Future<KnowledgeData?> loadFromJson() async {
    try {
      final jsonString = await rootBundle.loadString(_dataFilePath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return KnowledgeData.fromJson(jsonData);
    } catch (e) {
      print('加载知识库数据失败: $e');
      return null;
    }
  }
}

/// 知识库数据模型
class KnowledgeData {
  final String version;
  final DateTime lastUpdated;
  final List<Article> articles;
  final List<KnowledgeTip> tips;
  final List<FAQ> faqs;

  KnowledgeData({
    required this.version,
    required this.lastUpdated,
    required this.articles,
    required this.tips,
    required this.faqs,
  });

  factory KnowledgeData.fromJson(Map<String, dynamic> json) {
    return KnowledgeData(
      version: json['version'] ?? '1.0',
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      articles: (json['articles'] as List?)
              ?.map((a) => _articleFromJson(a))
              .toList() ??
          [],
      tips: (json['tips'] as List?)
              ?.map((t) => _tipFromJson(t))
              .toList() ??
          [],
      faqs: (json['faqs'] as List?)
              ?.map((f) => _faqFromJson(f))
              .toList() ??
          [],
    );
  }

  static Article _articleFromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      categoryId: json['categoryId'],
      difficulty: json['difficulty'] ?? 1,
      readTimeMinutes: json['readTimeMinutes'] ?? 5,
      author: json['author'] ?? '',
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      isFeatured: json['isFeatured'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  static KnowledgeTip _tipFromJson(Map<String, dynamic> json) {
    return KnowledgeTip(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      categoryId: json['categoryId'] ?? '',
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  static FAQ _faqFromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      categoryId: json['categoryId'] ?? '',
      keywords: (json['keywords'] as List?)?.cast<String>() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
