// 常见问题(FAQ)模型
class FAQ {
  final String id;
  final String question;
  final String answer;
  final String categoryId; // 关联的知识分类ID
  final String? speciesId; // 关联的物种ID(可选)
  final List<String> keywords; // 搜索关键词
  final int viewCount; // 查看次数
  final int helpfulCount; // 认为有帮助的次数
  final DateTime createdAt;
  final DateTime? updatedAt;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.categoryId,
    this.speciesId,
    this.keywords = const [],
    this.viewCount = 0,
    this.helpfulCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category_id': categoryId,
      'species_id': speciesId,
      'keywords': keywords.join(','),
      'view_count': viewCount,
      'helpful_count': helpfulCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory FAQ.fromMap(Map<String, dynamic> map) {
    return FAQ(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
      categoryId: map['category_id'],
      speciesId: map['species_id'],
      keywords: map['keywords'] != null && map['keywords'].isNotEmpty
          ? map['keywords'].split(',')
          : [],
      viewCount: map['view_count'] ?? 0,
      helpfulCount: map['helpful_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  FAQ copyWith({
    String? id,
    String? question,
    String? answer,
    String? categoryId,
    String? speciesId,
    List<String>? keywords,
    int? viewCount,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FAQ(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      categoryId: categoryId ?? this.categoryId,
      speciesId: speciesId ?? this.speciesId,
      keywords: keywords ?? this.keywords,
      viewCount: viewCount ?? this.viewCount,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
