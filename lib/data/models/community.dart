// 社区动态模型
class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final List<String> images;
  final String? reptileSpecies;
  final int likes;
  final int comments;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.images,
    this.reptileSpecies,
    this.likes = 0,
    this.comments = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'images': images.join(','),
      'reptile_species': reptileSpecies,
      'likes': likes,
      'comments': comments,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['user_id'],
      userName: map['user_name'],
      userAvatar: map['user_avatar'],
      content: map['content'],
      images: map['images'] != null && map['images'].isNotEmpty
          ? (map['images'] as String).split(',')
          : [],
      reptileSpecies: map['reptile_species'],
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// 评论模型
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      postId: map['post_id'],
      userId: map['user_id'],
      userName: map['user_name'],
      userAvatar: map['user_avatar'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
