// 成就系统数据模型
class Achievement {
  final String id;
  final String title;
  final String titleZh;
  final String description;
  final String icon;
  final AchievementType type;
  final int targetValue;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final AchievementReward? reward;

  Achievement({
    required this.id,
    required this.title,
    required this.titleZh,
    required this.description,
    required this.icon,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.reward,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'current_value': currentValue,
      'is_unlocked': isUnlocked ? 1 : 0,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  Achievement copyWith({
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      titleZh: titleZh,
      description: description,
      icon: icon,
      type: type,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      reward: reward,
    );
  }
}

// 成就类型
enum AchievementType {
  login,           // 登录相关
  reptile,         // 爬宠管理
  community,       // 社区互动
  encyclopedia,   // 知识库浏览
  qa,              // 问答互动
  article,         // 文章阅读
  habitat,         // 饲养环境
  milestone,       // 里程碑
}

// 成就奖励
class AchievementReward {
  final String type; // badge, points, unlock
  final String value;

  AchievementReward({required this.type, required this.value});
}

// 预定义成就列表
class AchievementDefinitions {
  static List<Achievement> getAll() {
    return [
      // 登录成就
      Achievement(
        id: 'first_login',
        title: 'First Step',
        titleZh: '初次见面',
        description: '首次登录应用',
        icon: '👋',
        type: AchievementType.login,
        targetValue: 1,
        reward: AchievementReward(type: 'points', value: '10'),
      ),
      Achievement(
        id: 'login_3_days',
        title: 'Getting Started',
        titleZh: '坚持不懈',
        description: '连续登录3天',
        icon: '📅',
        type: AchievementType.login,
        targetValue: 3,
        reward: AchievementReward(type: 'points', value: '30'),
      ),
      Achievement(
        id: 'login_7_days',
        title: 'Week Warrior',
        titleZh: '一周达人',
        description: '连续登录7天',
        icon: '⭐',
        type: AchievementType.login,
        targetValue: 7,
        reward: AchievementReward(type: 'badge', value: 'week_warrior'),
      ),
      Achievement(
        id: 'login_30_days',
        title: 'Month Master',
        titleZh: '月度冠军',
        description: '连续登录30天',
        icon: '🏆',
        type: AchievementType.login,
        targetValue: 30,
        reward: AchievementReward(type: 'badge', value: 'month_master'),
      ),

      // 爬宠管理成就
      Achievement(
        id: 'first_reptile',
        title: 'New Friend',
        titleZh: '新朋友',
        description: '添加第一只爬宠',
        icon: '🐍',
        type: AchievementType.reptile,
        targetValue: 1,
        reward: AchievementReward(type: 'points', value: '20'),
      ),
      Achievement(
        id: 'reptile_5',
        title: 'Zoo Keeper',
        titleZh: '小小动物园',
        description: '拥有5只爬宠',
        icon: '🦎',
        type: AchievementType.reptile,
        targetValue: 5,
        reward: AchievementReward(type: 'points', value: '50'),
      ),
      Achievement(
        id: 'reptile_10',
        title: 'Collector',
        titleZh: '收藏家',
        description: '拥有10只爬宠',
        icon: '🏠',
        type: AchievementType.reptile,
        targetValue: 10,
        reward: AchievementReward(type: 'badge', value: 'collector'),
      ),

      // 社区成就
      Achievement(
        id: 'first_post',
        title: 'Voice Out',
        titleZh: '发声',
        description: '发布第一条动态',
        icon: '📝',
        type: AchievementType.community,
        targetValue: 1,
        reward: AchievementReward(type: 'points', value: '20'),
      ),
      Achievement(
        id: 'post_10',
        title: 'Active Member',
        titleZh: '活跃达人',
        description: '发布10条动态',
        icon: '🎤',
        type: AchievementType.community,
        targetValue: 10,
        reward: AchievementReward(type: 'points', value: '100'),
      ),
      Achievement(
        id: 'like_100',
        title: 'Popular Star',
        titleZh: '人气明星',
        description: '获得100次点赞',
        icon: '❤️',
        type: AchievementType.community,
        targetValue: 100,
        reward: AchievementReward(type: 'badge', value: 'popular_star'),
      ),

      // 知识库成就
      Achievement(
        id: 'first_species',
        title: 'Explorer',
        titleZh: '探索者',
        description: '浏览第一个物种',
        icon: '🔍',
        type: AchievementType.encyclopedia,
        targetValue: 1,
        reward: AchievementReward(type: 'points', value: '10'),
      ),
      Achievement(
        id: 'species_50',
        title: 'Expert',
        titleZh: '物种专家',
        description: '浏览50个物种',
        icon: '📚',
        type: AchievementType.encyclopedia,
        targetValue: 50,
        reward: AchievementReward(type: 'points', value: '100'),
      ),
      Achievement(
        id: 'species_100',
        title: 'Professor',
        titleZh: '爬宠教授',
        description: '浏览100个物种',
        icon: '🎓',
        type: AchievementType.encyclopedia,
        targetValue: 100,
        reward: AchievementReward(type: 'badge', value: 'professor'),
      ),

      // 问答成就
      Achievement(
        id: 'first_question',
        title: 'Curious Mind',
        titleZh: '好奇宝宝',
        description: '提问第一个问题',
        icon: '❓',
        type: AchievementType.qa,
        targetValue: 1,
        reward: AchievementReward(type: 'points', value: '20'),
      ),
      Achievement(
        id: 'first_answer',
        title: 'Helper',
        titleZh: '热心肠',
        description: '回答第一个问题',
        icon: '💡',
        type: AchievementType.qa,
        targetValue: 1,
        reward: AchievementReward(type: 'points', value: '20'),
      ),
      Achievement(
        id: 'answer_10',
        title: 'Mentor',
        titleZh: '导师',
        description: '回答10个问题',
        icon: '🏫',
        type: AchievementType.qa,
        targetValue: 10,
        reward: AchievementReward(type: 'badge', value: 'mentor'),
      ),
      Achievement(
        id: 'accepted_5',
        title: 'Best Answer',
        titleZh: '最佳答案',
        description: '答案被采纳5次',
        icon: '✅',
        type: AchievementType.qa,
        targetValue: 5,
        reward: AchievementReward(type: 'points', value: '100'),
      ),

      // 文章成就
      Achievement(
        id: 'first_article',
        title: 'Reader',
        titleZh: '阅读者',
        description: '阅读第一篇文章',
        icon: '📖',
        type: AchievementType.article,
        targetValue: 1,
        reward: AchievementReward(type: 'points', value: '10'),
      ),
      Achievement(
        id: 'article_10',
        title: 'Bookworm',
        titleZh: '书虫',
        description: '阅读10篇文章',
        icon: '📕',
        type: AchievementType.article,
        targetValue: 10,
        reward: AchievementReward(type: 'points', value: '50'),
      ),
      Achievement(
        id: 'article_50',
        title: 'Scholar',
        titleZh: '学者',
        description: '阅读50篇文章',
        icon: '📗',
        type: AchievementType.article,
        targetValue: 50,
        reward: AchievementReward(type: 'badge', value: 'scholar'),
      ),

      // 饲养环境成就
      Achievement(
        id: 'first_habitat',
        title: 'Home Maker',
        titleZh: '温暖之家',
        description: '创建第一个饲养环境',
        icon: '🏠',
        type: AchievementType.habitat,
        targetValue: 1,
        reward: AchievementReward(type: 'points', value: '20'),
      ),
      Achievement(
        id: 'habitat_alert',
        title: 'Careful Owner',
        titleZh: '贴心主人',
        description: '设置5个环境提醒',
        icon: '⏰',
        type: AchievementType.habitat,
        targetValue: 5,
        reward: AchievementReward(type: 'points', value: '50'),
      ),

      // 里程碑成就
      Achievement(
        id: 'points_500',
        title: 'Rising Star',
        titleZh: '新星',
        description: '累计500积分',
        icon: '🌟',
        type: AchievementType.milestone,
        targetValue: 500,
        reward: AchievementReward(type: 'badge', value: 'rising_star'),
      ),
      Achievement(
        id: 'points_1000',
        title: 'Veteran',
        titleZh: '资深玩家',
        description: '累计1000积分',
        icon: '💎',
        type: AchievementType.milestone,
        targetValue: 1000,
        reward: AchievementReward(type: 'badge', value: 'veteran'),
      ),
      Achievement(
        id: 'all_badges',
        title: 'Master',
        titleZh: '大师',
        description: '解锁所有徽章',
        icon: '👑',
        type: AchievementType.milestone,
        targetValue: 15,
        reward: AchievementReward(type: 'badge', value: 'master'),
      ),
    ];
  }

  static Achievement? getById(String id) {
    try {
      return getAll().firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
