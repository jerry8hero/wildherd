// 用户数据模型
class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final UserLevel level;

  User({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.level = UserLevel.beginner,
  });

  User copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    UserLevel? level,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
    );
  }
}

// 用户经验等级
enum UserLevel {
  beginner,   // 新手
  intermediate, // 进阶
  advanced,   // 资深
}

extension UserLevelExtension on UserLevel {
  String get displayName {
    switch (this) {
      case UserLevel.beginner:
        return '新手';
      case UserLevel.intermediate:
        return '进阶';
      case UserLevel.advanced:
        return '资深';
    }
  }

  String get description {
    switch (this) {
      case UserLevel.beginner:
        return '适合零经验爱好者，易于饲养的宠物';
      case UserLevel.intermediate:
        return '需要一定饲养经验';
      case UserLevel.advanced:
        return '适合有丰富经验的爱好者';
    }
  }

  // 对应的难度范围
  List<int> get difficultyRange {
    switch (this) {
      case UserLevel.beginner:
        return [1, 2];
      case UserLevel.intermediate:
        return [2, 3];
      case UserLevel.advanced:
        return [4, 5];
    }
  }

  // 获取难度标签颜色
  String get difficultyLabel {
    switch (this) {
      case UserLevel.beginner:
        return '入门级';
      case UserLevel.intermediate:
        return '进阶级';
      case UserLevel.advanced:
        return '专业级';
    }
  }
}
