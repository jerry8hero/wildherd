// 知识库分类模型
class KnowledgeCategory {
  final String id;
  final String name; // 分类名称
  final String nameEn; // 英文名称
  final String icon; // 图标名称
  final String description; // 分类描述
  final int sort; // 排序
  final String parentId; // 父分类ID
  final List<KnowledgeCategory> children; // 子分类

  KnowledgeCategory({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.description,
    this.sort = 0,
    this.parentId = '',
    this.children = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'icon': icon,
      'description': description,
      'sort': sort,
      'parent_id': parentId,
    };
  }

  factory KnowledgeCategory.fromMap(Map<String, dynamic> map) {
    return KnowledgeCategory(
      id: map['id'],
      name: map['name'],
      nameEn: map['name_en'],
      icon: map['icon'],
      description: map['description'],
      sort: map['sort'] ?? 0,
      parentId: map['parent_id'] ?? '',
    );
  }

  // 判断是否为顶级分类
  bool get isTopLevel => parentId.isEmpty;

  // 获取分类的图标
  String get iconName => icon;
}

// 预定义的知识库分类
class KnowledgeCategories {
  static List<KnowledgeCategory> getDefaultCategories() {
    return [
      // 顶级分类
      KnowledgeCategory(
        id: 'beginner',
        name: '新手入门',
        nameEn: 'Getting Started',
        icon: 'school',
        description: '爬宠新手必看的基础知识',
        sort: 1,
      ),
      KnowledgeCategory(
        id: 'species',
        name: '物种百科',
        nameEn: 'Species Encyclopedia',
        icon: 'pets',
        description: '各类爬宠物种的详细介绍',
        sort: 2,
      ),
      KnowledgeCategory(
        id: 'care',
        name: '饲养指南',
        nameEn: 'Care Guide',
        icon: 'home',
        description: '饲养环境、喂食、日常护理',
        sort: 3,
      ),
      KnowledgeCategory(
        id: 'health',
        name: '疾病健康',
        nameEn: 'Health',
        icon: 'medical_services',
        description: '常见疾病、预防保健、用药指南',
        sort: 4,
      ),
      KnowledgeCategory(
        id: 'breeding',
        name: '繁殖技术',
        nameEn: 'Breeding',
        icon: 'egg',
        description: '繁殖条件、孵化技术、幼体护理',
        sort: 5,
      ),
      KnowledgeCategory(
        id: 'equipment',
        name: '器材设备',
        nameEn: 'Equipment',
        icon: 'build',
        description: '饲养箱、温控设备、灯具器材',
        sort: 6,
      ),

      // 新手入门子分类
      KnowledgeCategory(
        id: 'beginner_basics',
        name: '基础知识',
        nameEn: 'Basics',
        icon: 'lightbulb',
        description: '爬宠饲养的基本概念',
        sort: 1,
        parentId: 'beginner',
      ),
      KnowledgeCategory(
        id: 'beginner_guide',
        name: '选购指南',
        nameEn: 'Buying Guide',
        icon: 'shopping_cart',
        description: '如何选择适合自己的爬宠',
        sort: 2,
        parentId: 'beginner',
      ),
      KnowledgeCategory(
        id: 'beginner_species',
        name: '入门物种',
        nameEn: 'Beginner Species',
        icon: 'star',
        description: '适合新手的爬宠品种推荐',
        sort: 3,
        parentId: 'beginner',
      ),

      // 饲养指南子分类
      KnowledgeCategory(
        id: 'care_housing',
        name: '环境设置',
        nameEn: 'Habitat Setup',
        icon: 'house',
        description: '饲养箱和环境布置',
        sort: 1,
        parentId: 'care',
      ),
      KnowledgeCategory(
        id: 'care_feeding',
        name: '喂食营养',
        nameEn: 'Feeding',
        icon: 'restaurant',
        description: '食物选择和喂食方法',
        sort: 2,
        parentId: 'care',
      ),
      KnowledgeCategory(
        id: 'care_daily',
        name: '日常护理',
        nameEn: 'Daily Care',
        icon: 'favorite',
        description: '日常护理和健康管理',
        sort: 3,
        parentId: 'care',
      ),

      // 疾病健康子分类
      KnowledgeCategory(
        id: 'health_disease',
        name: '常见疾病',
        nameEn: 'Common Diseases',
        icon: 'warning',
        description: '爬宠常见疾病及治疗',
        sort: 1,
        parentId: 'health',
      ),
      KnowledgeCategory(
        id: 'health_prevent',
        name: '预防保健',
        nameEn: 'Prevention',
        icon: 'shield',
        description: '疾病预防和保健方法',
        sort: 2,
        parentId: 'health',
      ),
      KnowledgeCategory(
        id: 'health_medicine',
        name: '用药指南',
        nameEn: 'Medication',
        icon: 'medication',
        description: '常用药物及使用方法',
        sort: 3,
        parentId: 'health',
      ),

      // 繁殖技术子分类
      KnowledgeCategory(
        id: 'breeding_conditions',
        name: '繁殖条件',
        nameEn: 'Breeding Conditions',
        icon: 'science',
        description: '繁殖所需环境和条件',
        sort: 1,
        parentId: 'breeding',
      ),
      KnowledgeCategory(
        id: 'breeding_incubation',
        name: '孵化技术',
        nameEn: 'Incubation',
        icon: 'thermostat',
        description: '蛋的孵化方法和技巧',
        sort: 2,
        parentId: 'breeding',
      ),
      KnowledgeCategory(
        id: 'breeding_baby',
        name: '幼体护理',
        nameEn: 'Baby Care',
        icon: 'child_care',
        description: '幼体的喂养和护理',
        sort: 3,
        parentId: 'breeding',
      ),

      // 器材设备子分类
      KnowledgeCategory(
        id: 'equipment_enclosure',
        name: '饲养箱',
        nameEn: 'Enclosure',
        icon: 'dashboard',
        description: '各种饲养箱的选择',
        sort: 1,
        parentId: 'equipment',
      ),
      KnowledgeCategory(
        id: 'equipment_temperature',
        name: '温控设备',
        nameEn: 'Temperature Control',
        icon: 'device_thermostat',
        description: '加热设备和温控器',
        sort: 2,
        parentId: 'equipment',
      ),
      KnowledgeCategory(
        id: 'equipment_lighting',
        name: '灯具器材',
        nameEn: 'Lighting',
        icon: 'lightbulb',
        description: 'UV灯、加热灯等',
        sort: 3,
        parentId: 'equipment',
      ),
    ];
  }

  // 获取顶级分类
  static List<KnowledgeCategory> getTopCategories() {
    return getDefaultCategories()
        .where((c) => c.parentId.isEmpty)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));
  }

  // 根据父ID获取子分类
  static List<KnowledgeCategory> getSubCategories(String parentId) {
    return getDefaultCategories()
        .where((c) => c.parentId == parentId)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));
  }

  // 根据ID获取分类
  static KnowledgeCategory? getCategoryById(String id) {
    try {
      return getDefaultCategories().firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
