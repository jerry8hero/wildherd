// 混养兼容性等级
enum CompatibilityLevel {
  compatible,    // 可以混养
  incompatible,  // 不能混养
  cautious,      // 需谨慎
}

// 类别名称映射
const Map<String, String> categoryNames = {
  'snake': '蛇类',
  'lizard': '蜥蜴',
  'turtle': '龟类',
  'gecko': '守宫',
  'amphibian': '两栖',
  'arachnid': '蜘蛛',
  'insect': '昆虫',
  'mammal': '哺乳',
  'bird': '鸟类',
  'fish': '鱼类',
};

// 兼容性矩阵
// key: "category1_category2" (按字母顺序)
const Map<String, CompatibilityLevel> compatibilityMatrix = {
  // 蛇类
  'snake_lizard': CompatibilityLevel.incompatible,
  'snake_turtle': CompatibilityLevel.incompatible,
  'snake_gecko': CompatibilityLevel.incompatible,
  'snake_amphibian': CompatibilityLevel.incompatible,
  'snake_arachnid': CompatibilityLevel.incompatible,
  'snake_insect': CompatibilityLevel.incompatible,
  'snake_mammal': CompatibilityLevel.incompatible,
  'snake_bird': CompatibilityLevel.incompatible,
  'snake_fish': CompatibilityLevel.incompatible,

  // 蜥蜴
  'lizard_turtle': CompatibilityLevel.cautious,
  'lizard_gecko': CompatibilityLevel.cautious,
  'lizard_amphibian': CompatibilityLevel.incompatible,
  'lizard_arachnid': CompatibilityLevel.incompatible,
  'lizard_insect': CompatibilityLevel.cautious,
  'lizard_mammal': CompatibilityLevel.incompatible,
  'lizard_bird': CompatibilityLevel.incompatible,
  'lizard_fish': CompatibilityLevel.incompatible,

  // 龟类
  'turtle_gecko': CompatibilityLevel.incompatible,
  'turtle_amphibian': CompatibilityLevel.cautious,
  'turtle_arachnid': CompatibilityLevel.incompatible,
  'turtle_insect': CompatibilityLevel.cautious,
  'turtle_mammal': CompatibilityLevel.incompatible,
  'turtle_bird': CompatibilityLevel.incompatible,
  'turtle_fish': CompatibilityLevel.cautious,

  // 守宫
  'gecko_amphibian': CompatibilityLevel.incompatible,
  'gecko_arachnid': CompatibilityLevel.incompatible,
  'gecko_insect': CompatibilityLevel.cautious,
  'gecko_mammal': CompatibilityLevel.incompatible,
  'gecko_bird': CompatibilityLevel.incompatible,
  'gecko_fish': CompatibilityLevel.incompatible,

  // 两栖
  'amphibian_arachnid': CompatibilityLevel.incompatible,
  'amphibian_insect': CompatibilityLevel.cautious,
  'amphibian_mammal': CompatibilityLevel.incompatible,
  'amphibian_bird': CompatibilityLevel.incompatible,
  'amphibian_fish': CompatibilityLevel.cautious,

  // 蜘蛛
  'spider_insect': CompatibilityLevel.cautious,
  'spider_mammal': CompatibilityLevel.incompatible,
  'spider_bird': CompatibilityLevel.incompatible,
  'spider_fish': CompatibilityLevel.incompatible,

  // 哺乳
  'mammal_bird': CompatibilityLevel.cautious,
  'mammal_fish': CompatibilityLevel.incompatible,

  // 鸟类
  'bird_fish': CompatibilityLevel.incompatible,
};

// 获取两个类别的兼容性
CompatibilityLevel getCompatibility(String cat1, String cat2) {
  if (cat1 == cat2) return CompatibilityLevel.compatible;

  // 生成key (按字母顺序)
  final cats = [cat1, cat2]..sort();
  final key = '${cats[0]}_${cats[1]}';

  return compatibilityMatrix[key] ?? CompatibilityLevel.incompatible;
}

// 兼容性显示文本
String getCompatibilityText(CompatibilityLevel level) {
  switch (level) {
    case CompatibilityLevel.compatible:
      return '可以混养';
    case CompatibilityLevel.incompatible:
      return '不能混养';
    case CompatibilityLevel.cautious:
      return '需谨慎';
  }
}

// 获取兼容性颜色
int getCompatibilityColor(CompatibilityLevel level) {
  switch (level) {
    case CompatibilityLevel.compatible:
      return 0xFF4CAF50; // 绿色
    case CompatibilityLevel.incompatible:
      return 0xFFE53935; // 红色
    case CompatibilityLevel.cautious:
      return 0xFFFF9800; // 橙色
  }
}

// 混养注意事项
const Map<String, List<String>> cautions = {
  'snake': [
    '蛇类是肉食动物，会捕食其他小型动物',
    '部分蛇类有领地意识，需要单独饲养',
    '温度和湿度要求与其他动物差异较大',
    '蛇类可能携带寄生虫，注意隔离',
  ],
  'lizard': [
    '鬃狮蜥等大型蜥蜴可能捕食小型动物',
    '部分蜥蜴有领地意识',
    '需要特定的UVB光照条件',
    '温度要求较高，需配备加热设备',
  ],
  'turtle': [
    '水龟需要较大的水域环境',
    '陆龟需要干燥的饲养环境',
    '部分龟类有攻击性',
    '可能携带沙门氏菌',
  ],
  'gecko': [
    '守宫多为夜行性，需要特定环境',
    '部分守宫有领地意识',
    '体型较小，容易被其他动物捕食',
    '需要较高的湿度',
  ],
  'amphibian': [
    '两栖动物皮肤敏感，容易受化学品伤害',
    '部分两栖类有毒性',
    '需要湿润的环境',
    '可能携带蛙壶菌等病原体',
  ],
  'arachnid': [
    '蜘蛛多为捕食性，会捕食其他动物',
    '部分蜘蛛有剧毒',
    '需要单独饲养',
    '对环境要求特殊',
  ],
  'insect': [
    '昆虫可能是其他动物的猎物',
    '部分昆虫有防御机制',
    '需要特定的食物和环境',
    '繁殖速度快',
  ],
  'mammal': [
    '哺乳动物可能携带病原体',
    '部分动物有强烈领地意识',
    '需要足够的活动空间',
    '噪音和气味可能影响其他动物',
  ],
  'bird': [
    '鸟类可能携带病原体',
    '部分鸟类有强烈的领地意识',
    '需要足够的飞行空间',
    '噪音可能影响其他动物',
  ],
  'fish': [
    '鱼类需要特定的水质条件',
    '水温要求与其他动物不同',
    '可能携带寄生虫',
    '需要过滤和增氧设备',
  ],
};

// 推荐的混养方案
const List<Map<String, String>> recommendedCombinations = [
  {
    'title': '守宫+昆虫',
    'description': '某些守宫可以与小型昆虫混养，但需注意大小差异',
    'categories': 'gecko,insect',
  },
  {
    'title': '水龟+鱼类（大型）',
    'description': '大型鱼（如金鱼）可以与水龟混养，但需注意水质',
    'categories': 'turtle,fish',
  },
  {
    'title': '陆龟+守宫（不同饲养箱）',
    'description': '可以放在同一房间但需要独立的饲养箱',
    'categories': 'turtle,gecko',
  },
  {
    'title': '鸟类+哺乳（需监督）',
    'description': '某些鸟类和哺乳动物可以和平相处，但需要逐步适应',
    'categories': 'bird,mammal',
  },
];

// 获取某类别宠物的注意事项
List<String> getCautions(String category) {
  return cautions[category] ?? [];
}
