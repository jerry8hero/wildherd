// 道具系统模型

/// 道具类型
enum ItemType {
  food,           // 食物
  medicine,       // 药品
  evolution,      // 进化道具
  buff,           // 增益道具
  cosmetic,       // 装饰道具
  collectible,    // 收藏品
}

/// 道具效果类型
enum ItemEffectType {
  health,         // 恢复健康
  happiness,      // 增加快乐
  hunger,         // 减少饥饿
  cleanliness,    // 增加清洁
  exp,           // 获得经验
  mood,          // 改善心情
}

/// 道具定义
class PetItem {
  final String id;                    // 道具ID
  final String name;                  // 道具名称
  final String description;           // 道具描述
  final ItemType type;                // 道具类型
  final int price;                   // 购买价格
  final int sellPrice;               // 出售价格
  final Map<ItemEffectType, int> effects; // 效果
  final String? iconName;            // 图标名称

  const PetItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.price = 0,
    this.sellPrice = 0,
    this.effects = const {},
    this.iconName,
  });
}

/// 背包中的道具数量
class InventoryItem {
  final String itemId;
  final int quantity;
  final DateTime? expireDate; // 过期时间（可选）

  const InventoryItem({
    required this.itemId,
    required this.quantity,
    this.expireDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'quantity': quantity,
      'expire_date': expireDate?.toIso8601String(),
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      itemId: map['item_id'],
      quantity: map['quantity'] ?? 1,
      expireDate: map['expire_date'] != null
          ? DateTime.parse(map['expire_date'])
          : null,
    );
  }

  InventoryItem copyWith({
    String? itemId,
    int? quantity,
    DateTime? expireDate,
  }) {
    return InventoryItem(
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      expireDate: expireDate ?? this.expireDate,
    );
  }
}

/// 道具数据
class ItemData {
  /// 所有道具定义
  static const List<PetItem> items = [
    // 食物类
    PetItem(
      id: 'mouse',
      name: '乳鼠',
      description: '爬宠的优质高蛋白食物',
      type: ItemType.food,
      price: 10,
      sellPrice: 5,
      effects: {
        ItemEffectType.hunger: 30,
        ItemEffectType.exp: 5,
      },
      iconName: 'pest_control',
    ),
    PetItem(
      id: 'cricket',
      name: '蟋蟀',
      description: '活体昆虫，增加互动乐趣',
      type: ItemType.food,
      price: 8,
      sellPrice: 4,
      effects: {
        ItemEffectType.hunger: 20,
        ItemEffectType.happiness: 5,
        ItemEffectType.exp: 5,
      },
      iconName: 'bug_report',
    ),
    PetItem(
      id: 'mealworm',
      name: '面包虫',
      description: '常见的高蛋白饲料',
      type: ItemType.food,
      price: 5,
      sellPrice: 2,
      effects: {
        ItemEffectType.hunger: 15,
        ItemEffectType.exp: 3,
      },
      iconName: 'eco',
    ),
    PetItem(
      id: 'vegetables',
      name: '蔬菜',
      description: '草食爬宠的健康食物',
      type: ItemType.food,
      price: 5,
      sellPrice: 2,
      effects: {
        ItemEffectType.hunger: 20,
        ItemEffectType.health: 5,
        ItemEffectType.exp: 3,
      },
      iconName: 'eco',
    ),
    PetItem(
      id: 'fruits',
      name: '水果',
      description: '甜甜的水果零食',
      type: ItemType.food,
      price: 8,
      sellPrice: 4,
      effects: {
        ItemEffectType.hunger: 15,
        ItemEffectType.happiness: 10,
        ItemEffectType.exp: 3,
      },
      iconName: 'nutrition',
    ),
    PetItem(
      id: 'premium_food',
      name: '高级饲料',
      description: '营养丰富的精品饲料',
      type: ItemType.food,
      price: 30,
      sellPrice: 15,
      effects: {
        ItemEffectType.hunger: 50,
        ItemEffectType.health: 10,
        ItemEffectType.happiness: 10,
        ItemEffectType.exp: 15,
      },
      iconName: 'diamond',
    ),

    // 药品类
    PetItem(
      id: 'health_potion',
      name: '生命药水',
      description: '恢复 30 点健康值',
      type: ItemType.medicine,
      price: 50,
      sellPrice: 25,
      effects: {
        ItemEffectType.health: 30,
      },
      iconName: 'local_drink',
    ),
    PetItem(
      id: 'super_health_potion',
      name: '超级生命药水',
      description: '恢复 80 点健康值',
      type: ItemType.medicine,
      price: 100,
      sellPrice: 50,
      effects: {
        ItemEffectType.health: 80,
      },
      iconName: 'science',
    ),
    PetItem(
      id: 'antidote',
      name: '解毒药',
      description: '治疗生病状态',
      type: ItemType.medicine,
      price: 80,
      sellPrice: 40,
      effects: {
        ItemEffectType.mood: 20,
      },
      iconName: 'healing',
    ),

    // 进化道具类
    PetItem(
      id: 'evolution_stone',
      name: '进化石',
      description: '宠物进化必需的特殊道具',
      type: ItemType.evolution,
      price: 500,
      sellPrice: 250,
      effects: {},
      iconName: 'auto_awesome',
    ),
    PetItem(
      id: 'growth_hormone',
      name: '生长激素',
      description: '促进宠物成长的特殊激素',
      type: ItemType.evolution,
      price: 300,
      sellPrice: 150,
      effects: {
        ItemEffectType.exp: 100,
      },
      iconName: 'biotech',
    ),
    PetItem(
      id: 'ink_stone',
      name: '墨石化',
      description: '草龟墨化进化的特殊道具',
      type: ItemType.evolution,
      price: 800,
      sellPrice: 400,
      effects: {},
      iconName: 'dark_mode',
    ),
    PetItem(
      id: 'pattern_token',
      name: '花纹符印',
      description: '改变守宫花纹的道具',
      type: ItemType.evolution,
      price: 600,
      sellPrice: 300,
      effects: {},
      iconName: 'texture',
    ),

    // 增益道具类
    PetItem(
      id: 'happiness_charm',
      name: '快乐符',
      description: '增加 30 点快乐度',
      type: ItemType.buff,
      price: 40,
      sellPrice: 20,
      effects: {
        ItemEffectType.happiness: 30,
      },
      iconName: 'sentiment_satisfied',
    ),
    PetItem(
      id: 'cleanliness_spray',
      name: '清洁喷雾',
      description: '立即恢复清洁度到 100',
      type: ItemType.buff,
      price: 30,
      sellPrice: 15,
      effects: {
        ItemEffectType.cleanliness: 100,
      },
      iconName: 'water_drop',
    ),
    PetItem(
      id: 'exp_boost',
      name: '经验加成',
      description: '下次获得的经验翻倍',
      type: ItemType.buff,
      price: 80,
      sellPrice: 40,
      effects: {
        ItemEffectType.exp: 100,
      },
      iconName: 'bolt',
    ),
    PetItem(
      id: 'time_capsule',
      name: '时间胶囊',
      description: '暂停状态衰减 1 小时',
      type: ItemType.buff,
      price: 100,
      sellPrice: 50,
      effects: {},
      iconName: 'schedule',
    ),

    // 装饰类
    PetItem(
      id: 'hat',
      name: '可爱帽子',
      description: '让宠物戴上可爱的小帽子',
      type: ItemType.cosmetic,
      price: 50,
      sellPrice: 25,
      effects: {
        ItemEffectType.happiness: 10,
      },
      iconName: 'face',
    ),
    PetItem(
      id: 'bow',
      name: '漂亮蝴蝶结',
      description: '给宠物戴上漂亮的蝴蝶结',
      type: ItemType.cosmetic,
      price: 50,
      sellPrice: 25,
      effects: {
        ItemEffectType.happiness: 10,
      },
      iconName: 'stars',
    ),
    PetItem(
      id: 'costume',
      name: '可爱服装',
      description: '给宠物穿上可爱的服装',
      type: ItemType.cosmetic,
      price: 100,
      sellPrice: 50,
      effects: {
        ItemEffectType.happiness: 20,
      },
      iconName: 'checkroom',
    ),

    // 收藏品类
    PetItem(
      id: 'trophy',
      name: '奖杯',
      description: '成就达成的纪念奖杯',
      type: ItemType.collectible,
      price: 0,
      sellPrice: 0,
      effects: {},
      iconName: 'emoji_events',
    ),
    PetItem(
      id: 'rare_egg',
      name: '稀有蛋',
      description: '可以孵化出特殊宠物的蛋',
      type: ItemType.collectible,
      price: 1000,
      sellPrice: 500,
      effects: {},
      iconName: 'egg',
    ),
  ];

  /// 获取所有道具
  static List<PetItem> getAllItems() => items;

  /// 根据ID获取道具
  static PetItem? getById(String id) {
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 根据类型获取道具
  static List<PetItem> getByType(ItemType type) {
    return items.where((item) => item.type == type).toList();
  }

  /// 获取可购买的道具（价格 > 0）
  static List<PetItem> getPurchasableItems() {
    return items.where((item) => item.price > 0).toList();
  }

  /// 获取食物类道具
  static List<PetItem> getFoodItems() => getByType(ItemType.food);

  /// 获取药品类道具
  static List<PetItem> getMedicineItems() => getByType(ItemType.medicine);

  /// 获取进化道具
  static List<PetItem> getEvolutionItems() => getByType(ItemType.evolution);
}
