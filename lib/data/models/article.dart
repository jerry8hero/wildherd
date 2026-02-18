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
  });

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
}
