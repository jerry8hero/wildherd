// 用户收藏模型
class KnowledgeCollection {
  final String id;
  final String itemId; // 被收藏的内容ID
  final String itemType; // 收藏类型: article, tip, species, question
  final String title; // 收藏标题
  final String? summary; // 收藏摘要
  final String? imageUrl; // 封面图
  final DateTime collectedAt;

  KnowledgeCollection({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.title,
    this.summary,
    this.imageUrl,
    required this.collectedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'item_type': itemType,
      'title': title,
      'summary': summary,
      'image_url': imageUrl,
      'collected_at': collectedAt.toIso8601String(),
    };
  }

  factory KnowledgeCollection.fromMap(Map<String, dynamic> map) {
    return KnowledgeCollection(
      id: map['id'],
      itemId: map['item_id'],
      itemType: map['item_type'],
      title: map['title'],
      summary: map['summary'],
      imageUrl: map['image_url'],
      collectedAt: DateTime.parse(map['collected_at']),
    );
  }

  // 获取收藏类型的显示名称
  String get itemTypeName {
    switch (itemType) {
      case 'article':
        return '文章';
      case 'tip':
        return '技巧';
      case 'species':
        return '物种';
      case 'question':
        return '问答';
      default:
        return '内容';
    }
  }

  // 获取收藏类型的图标
  String get itemTypeIcon {
    switch (itemType) {
      case 'article':
        return 'article';
      case 'tip':
        return 'lightbulb';
      case 'species':
        return 'pets';
      case 'question':
        return 'question_answer';
      default:
        return 'bookmark';
    }
  }
}

// 阅读历史模型
class ReadHistory {
  final String id;
  final String itemId;
  final String itemType;
  final String title;
  final String? imageUrl;
  final DateTime readAt;
  final int readDuration; // 阅读时长(秒)

  ReadHistory({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.title,
    this.imageUrl,
    required this.readAt,
    this.readDuration = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'item_type': itemType,
      'title': title,
      'image_url': imageUrl,
      'read_at': readAt.toIso8601String(),
      'read_duration': readDuration,
    };
  }

  factory ReadHistory.fromMap(Map<String, dynamic> map) {
    return ReadHistory(
      id: map['id'],
      itemId: map['item_id'],
      itemType: map['item_type'],
      title: map['title'],
      imageUrl: map['image_url'],
      readAt: DateTime.parse(map['read_at']),
      readDuration: map['read_duration'] ?? 0,
    );
  }
}
