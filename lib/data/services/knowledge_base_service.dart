import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 知识库数据模型
class KnowledgeCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int count;

  KnowledgeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.count = 0,
  });

  factory KnowledgeCategory.fromJson(Map<String, dynamic> json) {
    return KnowledgeCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'pets',
      description: json['description'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class Species {
  final String id;
  final String nameChinese;
  final String nameEnglish;
  final String scientificName;
  final String category;
  final String description;
  final int difficulty;
  final String lifespan;
  final String size;
  final String distribution;
  final String habitat;
  final String diet;
  final String temperature;
  final String humidity;
  final String feeding;
  final String housing;
  final String care;
  final String? breeding; // 繁殖指南
  final String? commonDiseases; // 常见疾病
  final String? selectionTips; // 选购建议
  final String? personality; // 性格特点
  final String? morphs; // 品系变异
  final List<String> tags;
  final String imageUrl;

  Species({
    required this.id,
    required this.nameChinese,
    required this.nameEnglish,
    required this.scientificName,
    required this.category,
    required this.description,
    this.difficulty = 1,
    this.lifespan = '',
    this.size = '',
    this.distribution = '',
    this.habitat = '',
    this.diet = '',
    this.temperature = '',
    this.humidity = '',
    this.feeding = '',
    this.housing = '',
    this.care = '',
    this.breeding,
    this.commonDiseases,
    this.selectionTips,
    this.personality,
    this.morphs,
    this.tags = const [],
    this.imageUrl = '',
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      id: json['id'] ?? '',
      nameChinese: json['nameChinese'] ?? '',
      nameEnglish: json['nameEnglish'] ?? '',
      scientificName: json['scientificName'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 1,
      lifespan: json['lifespan'] ?? '',
      size: json['size'] ?? '',
      distribution: json['distribution'] ?? '',
      habitat: json['habitat'] ?? '',
      diet: json['diet'] ?? '',
      temperature: json['temperature'] ?? '',
      humidity: json['humidity'] ?? '',
      feeding: json['feeding'] ?? '',
      housing: json['housing'] ?? '',
      care: json['care'] ?? '',
      breeding: json['breeding'],
      commonDiseases: json['commonDiseases'],
      selectionTips: json['selectionTips'],
      personality: json['personality'],
      morphs: json['morphs'],
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  // 获取难度名称
  String get difficultyName {
    switch (difficulty) {
      case 1:
        return '入门';
      case 2:
        return '进阶';
      case 3:
        return '高级';
      default:
        return '入门';
    }
  }

  // 获取分类图标
  String get categoryIcon {
    switch (category) {
      case 'turtle':
        return '🐢';
      case 'lizard':
        return '🦎';
      case 'gecko':
        return '🦎';
      case 'snake':
        return '🐍';
      case 'amphibian':
        return '🐸';
      default:
        return '🐾';
    }
  }
}

class KnowledgeBase {
  final String version;
  final String lastUpdated;
  final List<KnowledgeCategory> categories;
  final List<Species> species;

  KnowledgeBase({
    required this.version,
    required this.lastUpdated,
    required this.categories,
    required this.species,
  });

  factory KnowledgeBase.fromJson(Map<String, dynamic> json) {
    return KnowledgeBase(
      version: json['version'] ?? '1.0',
      lastUpdated: json['lastUpdated'] ?? '',
      categories: (json['categories'] as List?)
              ?.map((c) => KnowledgeCategory.fromJson(c))
              .toList() ??
          [],
      species: (json['species'] as List?)
              ?.map((s) => Species.fromJson(s))
              .toList() ??
          [],
    );
  }
}

/// 知识库数据服务
class KnowledgeBaseService {
  static const String _dataFile = 'assets/data/knowledge_base_v2.json';
  static KnowledgeBase? _cache;

  /// 加载知识库数据
  static Future<KnowledgeBase> load() async {
    if (_cache != null) {
      return _cache!;
    }

    try {
      final jsonString = await rootBundle.loadString(_dataFile);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      _cache = KnowledgeBase.fromJson(jsonData);
      return _cache!;
    } catch (e) {
      debugPrint('加载知识库失败: $e');
      return KnowledgeBase(
        version: '1.0',
        lastUpdated: '',
        categories: [],
        species: [],
      );
    }
  }

  /// 获取所有物种
  static Future<List<Species>> getAllSpecies() async {
    final kb = await load();
    return kb.species;
  }

  /// 按分类获取物种
  static Future<List<Species>> getSpeciesByCategory(String categoryId) async {
    final kb = await load();
    return kb.species.where((s) => s.category == categoryId).toList();
  }

  /// 获取物种详情
  static Future<Species?> getSpeciesDetail(String id) async {
    final kb = await load();
    try {
      return kb.species.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 搜索物种
  static Future<List<Species>> searchSpecies(String keyword) async {
    final kb = await load();
    final kw = keyword.toLowerCase();
    return kb.species.where((s) {
      return s.nameChinese.toLowerCase().contains(kw) ||
          s.nameEnglish.toLowerCase().contains(kw) ||
          s.scientificName.toLowerCase().contains(kw) ||
          s.description.toLowerCase().contains(kw) ||
          s.tags.any((t) => t.toLowerCase().contains(kw));
    }).toList();
  }

  /// 获取所有分类
  static Future<List<KnowledgeCategory>> getCategories() async {
    final kb = await load();
    return kb.categories;
  }

  /// 获取入门级物种
  static Future<List<Species>> getBeginnerSpecies() async {
    final kb = await load();
    return kb.species.where((s) => s.difficulty == 1).toList();
  }

  /// 清除缓存
  static void clearCache() {
    _cache = null;
  }
}
