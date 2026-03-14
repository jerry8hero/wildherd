// 成就系统模型

/// 成就类型
enum AchievementCategory {
  feeding,      // 喂食相关
  growth,       // 成长相关
  evolution,    // 进化相关
  collection,   // 收集相关
  milestone,    // 里程碑
  special,      // 特殊成就
}

/// 成就定义
class Achievement {
  final String id;                    // 成就ID
  final String name;                  // 成就名称
  final String description;           // 成就描述
  final AchievementCategory category; // 成就分类
  final int requiredValue;           // 达成条件数值
  final int expReward;               // 经验奖励
  final String? iconName;            // 图标名称

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.requiredValue,
    this.expReward = 50,
    this.iconName,
  });
}

/// 成就数据
class AchievementData {
  /// 所有成就定义
  static const List<Achievement> achievements = [
    // 喂食成就
    Achievement(
      id: 'first_feed',
      name: '初次喂食',
      description: '第一次给你的电子宠物喂食',
      category: AchievementCategory.feeding,
      requiredValue: 1,
      expReward: 20,
      iconName: 'restaurant',
    ),
    Achievement(
      id: 'feed_10',
      name: '喂食新手',
      description: '累计喂食 10 次',
      category: AchievementCategory.feeding,
      requiredValue: 10,
      expReward: 50,
      iconName: 'restaurant',
    ),
    Achievement(
      id: 'feed_50',
      name: '喂食达人',
      description: '累计喂食 50 次',
      category: AchievementCategory.feeding,
      requiredValue: 50,
      expReward: 100,
      iconName: 'restaurant',
    ),
    Achievement(
      id: 'feed_100',
      name: '喂食大师',
      description: '累计喂食 100 次',
      category: AchievementCategory.feeding,
      requiredValue: 100,
      expReward: 200,
      iconName: 'restaurant',
    ),

    // 互动成就
    Achievement(
      id: 'first_play',
      name: '初次互动',
      description: '第一次与电子宠物互动',
      category: AchievementCategory.growth,
      requiredValue: 1,
      expReward: 20,
      iconName: 'sports_esports',
    ),
    Achievement(
      id: 'play_10',
      name: '互动新手',
      description: '累计互动 10 次',
      category: AchievementCategory.growth,
      requiredValue: 10,
      expReward: 50,
      iconName: 'sports_esports',
    ),
    Achievement(
      id: 'play_50',
      name: '互动达人',
      description: '累计互动 50 次',
      category: AchievementCategory.growth,
      requiredValue: 50,
      expReward: 100,
      iconName: 'sports_esports',
    ),
    Achievement(
      id: 'play_100',
      name: '互动大师',
      description: '累计互动 100 次',
      category: AchievementCategory.growth,
      requiredValue: 100,
      expReward: 200,
      iconName: 'sports_esports',
    ),

    // 清洁成就
    Achievement(
      id: 'first_clean',
      name: '初次清洁',
      description: '第一次清洁你的电子宠物',
      category: AchievementCategory.growth,
      requiredValue: 1,
      expReward: 20,
      iconName: 'cleaning_services',
    ),
    Achievement(
      id: 'clean_10',
      name: '清洁达人',
      description: '累计清洁 10 次',
      category: AchievementCategory.growth,
      requiredValue: 10,
      expReward: 50,
      iconName: 'cleaning_services',
    ),

    // 成长成就
    Achievement(
      id: 'level_5',
      name: '初露头角',
      description: '宠物达到 5 级',
      category: AchievementCategory.growth,
      requiredValue: 5,
      expReward: 100,
      iconName: 'trending_up',
    ),
    Achievement(
      id: 'level_10',
      name: '茁壮成长',
      description: '宠物达到 10 级',
      category: AchievementCategory.growth,
      requiredValue: 10,
      expReward: 150,
      iconName: 'trending_up',
    ),
    Achievement(
      id: 'level_25',
      name: '身强力壮',
      description: '宠物达到 25 级',
      category: AchievementCategory.growth,
      requiredValue: 25,
      expReward: 300,
      iconName: 'trending_up',
    ),
    Achievement(
      id: 'level_50',
      name: '宠物大师',
      description: '宠物达到满级 50 级',
      category: AchievementCategory.growth,
      requiredValue: 50,
      expReward: 1000,
      iconName: 'military_tech',
    ),

    // 进化成就
    Achievement(
      id: 'first_evolution',
      name: '首次进化',
      description: '你的宠物第一次进化',
      category: AchievementCategory.evolution,
      requiredValue: 1,
      expReward: 200,
      iconName: 'auto_awesome',
    ),
    Achievement(
      id: 'second_evolution',
      name: '二次进化',
      description: '你的宠物完成第二次进化',
      category: AchievementCategory.evolution,
      requiredValue: 2,
      expReward: 400,
      iconName: 'auto_awesome',
    ),
    Achievement(
      id: 'final_evolution',
      name: '完全体',
      description: '你的宠物达到完全体形态',
      category: AchievementCategory.evolution,
      requiredValue: 3,
      expReward: 1000,
      iconName: 'stars',
    ),

    // 存活成就
    Achievement(
      id: 'survive_7',
      name: '一周存活',
      description: '宠物存活 7 天',
      category: AchievementCategory.milestone,
      requiredValue: 7,
      expReward: 50,
      iconName: 'cake',
    ),
    Achievement(
      id: 'survive_30',
      name: '一月存活',
      description: '宠物存活 30 天',
      category: AchievementCategory.milestone,
      requiredValue: 30,
      expReward: 150,
      iconName: 'cake',
    ),
    Achievement(
      id: 'survive_100',
      name: '百日存活',
      description: '宠物存活 100 天',
      category: AchievementCategory.milestone,
      requiredValue: 100,
      expReward: 500,
      iconName: 'cake',
    ),
    Achievement(
      id: 'survive_365',
      name: '一年存活',
      description: '宠物存活 365 天',
      category: AchievementCategory.milestone,
      requiredValue: 365,
      expReward: 2000,
      iconName: 'emoji_events',
    ),

    // 健康成就
    Achievement(
      id: 'healthy_7',
      name: '健康一周',
      description: '连续 7 天健康度保持 80 以上',
      category: AchievementCategory.milestone,
      requiredValue: 7,
      expReward: 100,
      iconName: 'favorite',
    ),
    Achievement(
      id: 'healthy_30',
      name: '健康一月',
      description: '连续 30 天健康度保持 80 以上',
      category: AchievementCategory.milestone,
      requiredValue: 30,
      expReward: 300,
      iconName: 'favorite',
    ),

    // 收集成就
    Achievement(
      id: 'collect_3_pets',
      name: '小小收集家',
      description: '同时拥有 3 只电子宠物',
      category: AchievementCategory.collection,
      requiredValue: 3,
      expReward: 100,
      iconName: 'collections',
    ),
    Achievement(
      id: 'collect_5_pets',
      name: '收集达人',
      description: '同时拥有 5 只电子宠物',
      category: AchievementCategory.collection,
      requiredValue: 5,
      expReward: 200,
      iconName: 'collections',
    ),
    Achievement(
      id: 'collect_10_pets',
      name: '爬宠收藏家',
      description: '同时拥有 10 只电子宠物',
      category: AchievementCategory.collection,
      requiredValue: 10,
      expReward: 500,
      iconName: 'collections',
    ),

    // 特殊成就
    Achievement(
      id: 'perfect_health',
      name: '完美健康',
      description: '宠物健康度达到 100',
      category: AchievementCategory.special,
      requiredValue: 100,
      expReward: 100,
      iconName: 'verified',
    ),
    Achievement(
      id: 'max_happiness',
      name: '超级开心',
      description: '宠物快乐度达到 100',
      category: AchievementCategory.special,
      requiredValue: 100,
      expReward: 100,
      iconName: 'sentiment_very_satisfied',
    ),
  ];

  /// 获取所有成就
  static List<Achievement> getAllAchievements() => achievements;

  /// 根据ID获取成就
  static Achievement? getById(String id) {
    try {
      return achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 根据分类获取成就
  static List<Achievement> getByCategory(AchievementCategory category) {
    return achievements.where((a) => a.category == category).toList();
  }

  /// 检查是否达成成就（返回新解锁的成就ID列表）
  static List<String> checkAchievements({
    required int totalFed,
    required int totalPlayed,
    required int totalCleaned,
    required int level,
    required int evolutionStage,
    required int daysAlive,
    required int consecutiveHealthyDays,
    required int healthScore,
    required int happiness,
    required List<String> unlockedAchievements,
  }) {
    final newlyUnlocked = <String>[];

    for (final achievement in achievements) {
      if (unlockedAchievements.contains(achievement.id)) continue;

      bool unlocked = false;

      switch (achievement.id) {
        case 'first_feed':
        case 'feed_10':
        case 'feed_50':
        case 'feed_100':
          unlocked = totalFed >= achievement.requiredValue;
          break;
        case 'first_play':
        case 'play_10':
        case 'play_50':
        case 'play_100':
          unlocked = totalPlayed >= achievement.requiredValue;
          break;
        case 'first_clean':
        case 'clean_10':
          unlocked = totalCleaned >= achievement.requiredValue;
          break;
        case 'level_5':
        case 'level_10':
        case 'level_25':
        case 'level_50':
          unlocked = level >= achievement.requiredValue;
          break;
        case 'first_evolution':
        case 'second_evolution':
        case 'final_evolution':
          unlocked = evolutionStage >= achievement.requiredValue;
          break;
        case 'survive_7':
        case 'survive_30':
        case 'survive_100':
        case 'survive_365':
          unlocked = daysAlive >= achievement.requiredValue;
          break;
        case 'healthy_7':
        case 'healthy_30':
          unlocked = consecutiveHealthyDays >= achievement.requiredValue;
          break;
        case 'perfect_health':
          unlocked = healthScore >= achievement.requiredValue;
          break;
        case 'max_happiness':
          unlocked = happiness >= achievement.requiredValue;
          break;
      }

      if (unlocked) {
        newlyUnlocked.add(achievement.id);
      }
    }

    return newlyUnlocked;
  }
}
