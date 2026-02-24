// 问答系统数据模型

// 问答问题模型
class Question {
  final String id;
  final String title;
  final String content;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? speciesId; // 关联的物种（可选）
  final String? speciesName; // 物种名称
  final List<String> tags; // 标签
  final int viewCount; // 浏览次数
  final int answerCount; // 回答数量
  final bool isResolved; // 是否已解决
  final String? acceptedAnswerId; // 采纳的回答ID
  final DateTime createdAt;
  final DateTime? updatedAt;

  Question({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.speciesId,
    this.speciesName,
    this.tags = const [],
    this.viewCount = 0,
    this.answerCount = 0,
    this.isResolved = false,
    this.acceptedAnswerId,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'species_id': speciesId,
      'species_name': speciesName,
      'tags': tags.join(','),
      'view_count': viewCount,
      'answer_count': answerCount,
      'is_resolved': isResolved ? 1 : 0,
      'accepted_answer_id': acceptedAnswerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      userId: map['user_id'],
      userName: map['user_name'],
      userAvatar: map['user_avatar'],
      speciesId: map['species_id'],
      speciesName: map['species_name'],
      tags: map['tags'] != null && map['tags'].toString().isNotEmpty
          ? map['tags'].toString().split(',')
          : [],
      viewCount: map['view_count'] ?? 0,
      answerCount: map['answer_count'] ?? 0,
      isResolved: map['is_resolved'] == 1,
      acceptedAnswerId: map['accepted_answer_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}

// 问答回答模型
class Answer {
  final String id;
  final String questionId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final int likes; // 点赞数
  final bool isAccepted; // 是否被采纳
  final DateTime createdAt;
  final DateTime? updatedAt;

  Answer({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.likes = 0,
    this.isAccepted = false,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'likes': likes,
      'is_accepted': isAccepted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'],
      questionId: map['question_id'],
      userId: map['user_id'],
      userName: map['user_name'],
      userAvatar: map['user_avatar'],
      content: map['content'],
      likes: map['likes'] ?? 0,
      isAccepted: map['is_accepted'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}

// 问答标签模型
class QATag {
  final String id;
  final String name;
  final String nameZh;
  final int questionCount;

  QATag({
    required this.id,
    required this.name,
    required this.nameZh,
    this.questionCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_zh': nameZh,
      'question_count': questionCount,
    };
  }

  factory QATag.fromMap(Map<String, dynamic> map) {
    return QATag(
      id: map['id'],
      name: map['name'],
      nameZh: map['name_zh'],
      questionCount: map['question_count'] ?? 0,
    );
  }
}
