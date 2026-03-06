// 饲养知识文章模型
class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category; // feeding, health, housing, breeding, species
  final String? imageUrl;
  final String author;
  final int readCount;
  final List<String> tags;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;
  // 知识库扩展字段
  final String? categoryId; // 知识库分类ID
  final int difficulty; // 难度等级 1-5 (1=新手, 5=专家)
  final int readTimeMinutes; // 预计阅读时间(分钟)
  final List<String> relatedSpeciesIds; // 关联物种ID列表
  final bool isCollection; // 是否被收藏

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    this.imageUrl,
    required this.author,
    this.readCount = 0,
    this.tags = const [],
    this.isFeatured = false,
    required this.createdAt,
    this.updatedAt,
    this.categoryId,
    this.difficulty = 1,
    this.readTimeMinutes = 5,
    this.relatedSpeciesIds = const [],
    this.isCollection = false,
  });

  // 复制方法
  Article copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? category,
    String? imageUrl,
    String? author,
    int? readCount,
    List<String>? tags,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryId,
    int? difficulty,
    int? readTimeMinutes,
    List<String>? relatedSpeciesIds,
    bool? isCollection,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      readCount: readCount ?? this.readCount,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryId: categoryId ?? this.categoryId,
      difficulty: difficulty ?? this.difficulty,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      relatedSpeciesIds: relatedSpeciesIds ?? this.relatedSpeciesIds,
      isCollection: isCollection ?? this.isCollection,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'category': category,
      'image_url': imageUrl,
      'author': author,
      'read_count': readCount,
      'tags': tags.join(','),
      'is_featured': isFeatured ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category_id': categoryId,
      'difficulty': difficulty,
      'read_time_minutes': readTimeMinutes,
      'related_species_ids': relatedSpeciesIds.join(','),
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      title: map['title'],
      summary: map['summary'],
      content: map['content'],
      category: map['category'],
      imageUrl: map['image_url'],
      author: map['author'],
      readCount: map['read_count'] ?? 0,
      tags: map['tags'] != null && map['tags'].isNotEmpty
          ? map['tags'].split(',')
          : [],
      isFeatured: map['is_featured'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      categoryId: map['category_id'],
      difficulty: map['difficulty'] ?? 1,
      readTimeMinutes: map['read_time_minutes'] ?? 5,
      relatedSpeciesIds: map['related_species_ids'] != null &&
              map['related_species_ids'].isNotEmpty
          ? map['related_species_ids'].split(',')
          : [],
    );
  }

  String get categoryName {
    switch (category) {
      case 'feeding':
        return '饲养';
      case 'health':
        return '健康';
      case 'housing':
        return '环境';
      case 'breeding':
        return '繁殖';
      case 'species':
        return '物种';
      default:
        return category;
    }
  }

  // 获取难度等级名称
  String get difficultyName {
    switch (difficulty) {
      case 1:
        return '入门';
      case 2:
        return '初级';
      case 3:
        return '中级';
      case 4:
        return '高级';
      case 5:
        return '专家';
      default:
        return '入门';
    }
  }

  // 获取难度等级颜色
  int get difficultyColorValue {
    switch (difficulty) {
      case 1:
        return 0xFF4CAF50; // 绿色
      case 2:
        return 0xFF8BC34A; // 浅绿
      case 3:
        return 0xFFFFC107; // 黄色
      case 4:
        return 0xFFFF9800; // 橙色
      case 5:
        return 0xFFF44336; // 红色
      default:
        return 0xFF4CAF50;
    }
  }
}
