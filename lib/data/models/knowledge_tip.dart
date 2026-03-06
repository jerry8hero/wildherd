// 饲养技巧模型
class KnowledgeTip {
  final String id;
  final String title;
  final String content;
  final String categoryId; // 关联的知识分类ID
  final String? speciesId; // 关联的物种ID(可选)
  final List<String> tags;
  final int helpfulCount; // 点赞数
  final DateTime createdAt;

  KnowledgeTip({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    this.speciesId,
    this.tags = const [],
    this.helpfulCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'species_id': speciesId,
      'tags': tags.join(','),
      'helpful_count': helpfulCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory KnowledgeTip.fromMap(Map<String, dynamic> map) {
    return KnowledgeTip(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      categoryId: map['category_id'],
      speciesId: map['species_id'],
      tags: map['tags'] != null && map['tags'].isNotEmpty
          ? map['tags'].split(',')
          : [],
      helpfulCount: map['helpful_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  KnowledgeTip copyWith({
    String? id,
    String? title,
    String? content,
    String? categoryId,
    String? speciesId,
    List<String>? tags,
    int? helpfulCount,
    DateTime? createdAt,
  }) {
    return KnowledgeTip(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      speciesId: speciesId ?? this.speciesId,
      tags: tags ?? this.tags,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
