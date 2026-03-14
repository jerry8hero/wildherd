// 电子宠物数据模型 - 完整的 Tamagotchi 风格宠物系统

/// 心情状态
enum PetMood {
  happy,      // 开心
  normal,     // 一般
  sad,        // 低落
  restless,   // 烦躁
  sick,       // 生病
}

/// 外观状态（用于显示不同的表情/动画）
enum PetAppearance {
  normal,
  happy,
  sad,
  sick,
  sleeping,
  eating,
  playing,
}

/// 成长阶段
enum GrowthStage {
  juvenile,    // 幼体
  subAdult,   // 亚成
  adult,      // 成体
  senior,     // 老年
}

/// 进化阶段
enum EvolutionStage {
  none,       // 无进化
  first,      // 第一次进化
  second,     // 第二次进化
  final,      // 最终形态
}

/// 进化路线配置
class EvolutionLine {
  final String speciesId;
  final String speciesName;
  final List<EvolutionStageConfig> stages;

  const EvolutionLine({
    required this.speciesId,
    required this.speciesName,
    required this.stages,
  });
}

/// 单个进化阶段配置
class EvolutionStageConfig {
  final EvolutionStage stage;
  final String name;           // 阶段名称
  final String? nextSpeciesId; // 进化后的物种ID
  final String? nextName;       // 进化后的名称
  final int requiredLevel;     // 需要的等级
  final int requiredDays;     // 需要的年龄(天)
  final String? requiredItemId; // 需要的道具ID

  const EvolutionStageConfig({
    required this.stage,
    required this.name,
    this.nextSpeciesId,
    this.nextName,
    this.requiredLevel = 0,
    this.requiredDays = 0,
    this.requiredItemId,
  });
}

/// 电子宠物主模型
class ElectronicPet {
  final String id;
  final String speciesId;           // 物种ID
  final String name;                 // 宠物名称
  final String? nickname;           // 昵称
  final String? imageUrl;            // 宠物图片
  final DateTime birthDate;          // 出生日期
  final String? birthDateCustom;     // 自定义出生日期字符串
  final String gender;               // 性别: male, female, unknown

  // 等级系统
  final int level;                   // 等级 (1-50)
  final int experience;             // 当前经验值
  final int totalExperience;         // 累计获得经验

  // 状态系统
  final int healthScore;             // 健康指数 (0-100)
  final int happiness;               // 快乐度 (0-100)
  final int hunger;                  // 饥饿度 (0-100)
  final int cleanliness;             // 清洁度 (0-100)

  // 心情系统
  final PetMood mood;                // 当前心情
  final PetAppearance appearance;   // 当前外观状态

  // 成长阶段
  final GrowthStage growthStage;     // 成长阶段
  final EvolutionStage evolutionStage; // 进化阶段

  // 时间记录
  final DateTime lastFed;            // 上次喂食时间
  final DateTime lastCleaned;        // 上次清洁时间
  final DateTime lastPlayed;         // 上次互动时间
  final DateTime lastMoodUpdate;     // 上次心情更新时间
  final DateTime createdAt;
  final DateTime updatedAt;

  // 统计
  final int totalFed;                // 总喂食次数
  final int totalPlayed;             // 总互动次数
  final int totalCleaned;            // 总清洁次数
  final int daysAlive;               // 存活天数

  // 成就
  final List<String> unlockedAchievements; // 已解锁成就ID列表

  // 背包
  final List<String> inventoryItemIds;      // 拥有的道具ID列表

  // 健康记录
  final int consecutiveHealthyDays; // 连续健康天数

  ElectronicPet({
    required this.id,
    required this.speciesId,
    required this.name,
    this.nickname,
    this.imageUrl,
    required this.birthDate,
    this.birthDateCustom,
    this.gender = 'unknown',
    this.level = 1,
    this.experience = 0,
    this.totalExperience = 0,
    this.healthScore = 100,
    this.happiness = 100,
    this.hunger = 0,
    this.cleanliness = 100,
    this.mood = PetMood.happy,
    this.appearance = PetAppearance.normal,
    this.growthStage = GrowthStage.juvenile,
    this.evolutionStage = EvolutionStage.none,
    required this.lastFed,
    required this.lastCleaned,
    required this.lastPlayed,
    required this.lastMoodUpdate,
    required this.createdAt,
    required this.updatedAt,
    this.totalFed = 0,
    this.totalPlayed = 0,
    this.totalCleaned = 0,
    this.daysAlive = 0,
    this.unlockedAchievements = const [],
    this.inventoryItemIds = const [],
    this.consecutiveHealthyDays = 0,
  });

  /// 获取年龄描述
  String getAge() {
    final now = DateTime.now();
    final age = now.difference(birthDate);
    if (age.inDays < 30) {
      return '${age.inDays}天';
    } else if (age.inDays < 365) {
      return '${(age.inDays / 30).floor()}个月';
    } else {
      return '${(age.inDays / 365).floor()}岁';
    }
  }

  /// 获取年龄（天数）
  int getAgeDays() {
    return DateTime.now().difference(birthDate).inDays;
  }

  /// 获取升级所需经验
  int getExperienceToNextLevel() {
    return level * 100;
  }

  /// 获取升级进度百分比
  double getLevelProgress() {
    final needed = getExperienceToNextLevel();
    return experience / needed;
  }

  /// 获取心情描述
  String getMoodText() {
    switch (mood) {
      case PetMood.happy:
        return '开心';
      case PetMood.normal:
        return '一般';
      case PetMood.sad:
        return '低落';
      case PetMood.restless:
        return '烦躁';
      case PetMood.sick:
        return '生病';
    }
  }

  /// 获取成长阶段描述
  String getGrowthStageText() {
    switch (growthStage) {
      case GrowthStage.juvenile:
        return '幼体';
      case GrowthStage.subAdult:
        return '亚成';
      case GrowthStage.adult:
        return '成体';
      case GrowthStage.senior:
        return '老年';
    }
  }

  /// 获取进化阶段描述
  String getEvolutionStageText() {
    switch (evolutionStage) {
      case EvolutionStage.none:
        return '';
      case EvolutionStage.first:
        return '(进化)';
      case EvolutionStage.second:
        return '(二阶)';
      case EvolutionStage.final:
        return '(完全体)';
    }
  }

  /// 是否可以进化
  bool canEvolve(EvolutionLine? evolutionLine) {
    if (evolutionLine == null) return false;

    final currentStageIndex = evolutionLine.stages.indexWhere(
      (s) => s.stage == evolutionStage,
    );

    if (currentStageIndex == -1 || currentStageIndex >= evolutionLine.stages.length - 1) {
      return false;
    }

    final nextStage = evolutionLine.stages[currentStageIndex + 1];
    return getAgeDays() >= nextStage.requiredDays && level >= nextStage.requiredLevel;
  }

  /// 获取心情图标
  String getMoodEmoji() {
    switch (mood) {
      case PetMood.happy:
        return '😊';
      case PetMood.normal:
        return '😐';
      case PetMood.sad:
        return '😢';
      case PetMood.restless:
        return '😤';
      case PetMood.sick:
        return '🤒';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'species_id': speciesId,
      'name': name,
      'nickname': nickname,
      'image_url': imageUrl,
      'birth_date': birthDate.toIso8601String(),
      'birth_date_custom': birthDateCustom,
      'gender': gender,
      'level': level,
      'experience': experience,
      'total_experience': totalExperience,
      'health_score': healthScore,
      'happiness': happiness,
      'hunger': hunger,
      'cleanliness': cleanliness,
      'mood': mood.index,
      'appearance': appearance.index,
      'growth_stage': growthStage.index,
      'evolution_stage': evolutionStage.index,
      'last_fed': lastFed.toIso8601String(),
      'last_cleaned': lastCleaned.toIso8601String(),
      'last_played': lastPlayed.toIso8601String(),
      'last_mood_update': lastMoodUpdate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_fed': totalFed,
      'total_played': totalPlayed,
      'total_cleaned': totalCleaned,
      'days_alive': daysAlive,
      'unlocked_achievements': unlockedAchievements.join(','),
      'inventory_item_ids': inventoryItemIds.join(','),
      'consecutive_healthy_days': consecutiveHealthyDays,
    };
  }

  factory ElectronicPet.fromMap(Map<String, dynamic> map) {
    return ElectronicPet(
      id: map['id'],
      speciesId: map['species_id'],
      name: map['name'],
      nickname: map['nickname'],
      imageUrl: map['image_url'],
      birthDate: DateTime.parse(map['birth_date']),
      birthDateCustom: map['birth_date_custom'],
      gender: map['gender'] ?? 'unknown',
      level: map['level'] ?? 1,
      experience: map['experience'] ?? 0,
      totalExperience: map['total_experience'] ?? 0,
      healthScore: map['health_score'] ?? 100,
      happiness: map['happiness'] ?? 100,
      hunger: map['hunger'] ?? 0,
      cleanliness: map['cleanliness'] ?? 100,
      mood: PetMood.values[map['mood'] ?? 0],
      appearance: PetAppearance.values[map['appearance'] ?? 0],
      growthStage: GrowthStage.values[map['growth_stage'] ?? 0],
      evolutionStage: EvolutionStage.values[map['evolution_stage'] ?? 0],
      lastFed: DateTime.parse(map['last_fed']),
      lastCleaned: DateTime.parse(map['last_cleaned']),
      lastPlayed: DateTime.parse(map['last_played']),
      lastMoodUpdate: DateTime.parse(map['last_mood_update']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      totalFed: map['total_fed'] ?? 0,
      totalPlayed: map['total_played'] ?? 0,
      totalCleaned: map['total_cleaned'] ?? 0,
      daysAlive: map['days_alive'] ?? 0,
      unlockedAchievements: map['unlocked_achievements'] != null && map['unlocked_achievements'].toString().isNotEmpty
          ? map['unlocked_achievements'].toString().split(',')
          : [],
      inventoryItemIds: map['inventory_item_ids'] != null && map['inventory_item_ids'].toString().isNotEmpty
          ? map['inventory_item_ids'].toString().split(',')
          : [],
      consecutiveHealthyDays: map['consecutive_healthy_days'] ?? 0,
    );
  }

  ElectronicPet copyWith({
    String? id,
    String? speciesId,
    String? name,
    String? nickname,
    String? imageUrl,
    DateTime? birthDate,
    String? birthDateCustom,
    String? gender,
    int? level,
    int? experience,
    int? totalExperience,
    int? healthScore,
    int? happiness,
    int? hunger,
    int? cleanliness,
    PetMood? mood,
    PetAppearance? appearance,
    GrowthStage? growthStage,
    EvolutionStage? evolutionStage,
    DateTime? lastFed,
    DateTime? lastCleaned,
    DateTime? lastPlayed,
    DateTime? lastMoodUpdate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalFed,
    int? totalPlayed,
    int? totalCleaned,
    int? daysAlive,
    List<String>? unlockedAchievements,
    List<String>? inventoryItemIds,
    int? consecutiveHealthyDays,
  }) {
    return ElectronicPet(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      imageUrl: imageUrl ?? this.imageUrl,
      birthDate: birthDate ?? this.birthDate,
      birthDateCustom: birthDateCustom ?? this.birthDateCustom,
      gender: gender ?? this.gender,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      totalExperience: totalExperience ?? this.totalExperience,
      healthScore: healthScore ?? this.healthScore,
      happiness: happiness ?? this.happiness,
      hunger: hunger ?? this.hunger,
      cleanliness: cleanliness ?? this.cleanliness,
      mood: mood ?? this.mood,
      appearance: appearance ?? this.appearance,
      growthStage: growthStage ?? this.growthStage,
      evolutionStage: evolutionStage ?? this.evolutionStage,
      lastFed: lastFed ?? this.lastFed,
      lastCleaned: lastCleaned ?? this.lastCleaned,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      lastMoodUpdate: lastMoodUpdate ?? this.lastMoodUpdate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalFed: totalFed ?? this.totalFed,
      totalPlayed: totalPlayed ?? this.totalPlayed,
      totalCleaned: totalCleaned ?? this.totalCleaned,
      daysAlive: daysAlive ?? this.daysAlive,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      inventoryItemIds: inventoryItemIds ?? this.inventoryItemIds,
      consecutiveHealthyDays: consecutiveHealthyDays ?? this.consecutiveHealthyDays,
    );
  }

  /// 创建新宠物
  factory ElectronicPet.create({
    required String id,
    required String speciesId,
    required String name,
    String? nickname,
    String gender = 'unknown',
  }) {
    final now = DateTime.now();
    return ElectronicPet(
      id: id,
      speciesId: speciesId,
      name: name,
      nickname: nickname,
      birthDate: now,
      gender: gender,
      lastFed: now,
      lastCleaned: now,
      lastPlayed: now,
      lastMoodUpdate: now,
      createdAt: now,
      updatedAt: now,
    );
  }
}
