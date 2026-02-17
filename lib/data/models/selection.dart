// 候选宠物模型
class CandidatePet {
  final String id;
  final String speciesId;
  final String speciesName;
  final String name;
  final String? imageUrl;
  final List<CheckItem> checks;
  final DateTime createdAt;

  CandidatePet({
    required this.id,
    required this.speciesId,
    required this.speciesName,
    required this.name,
    this.imageUrl,
    required this.checks,
    required this.createdAt,
  });

  // 计算评分
  double get score {
    if (checks.isEmpty) return 0;
    int totalWeight = checks.fold(0, (sum, item) => sum + item.weight);
    int passedWeight = checks
        .where((item) => item.isChecked)
        .fold(0, (sum, item) => sum + item.weight);
    if (totalWeight == 0) return 0;
    return (passedWeight / totalWeight) * 100;
  }

  // 获取已检查项数量
  int get checkedCount => checks.where((item) => item.isChecked).length;

  // 获取进度百分比
  double get progress => checks.isEmpty ? 0 : checkedCount / checks.length;

  CandidatePet copyWith({
    String? id,
    String? speciesId,
    String? speciesName,
    String? name,
    String? imageUrl,
    List<CheckItem>? checks,
    DateTime? createdAt,
  }) {
    return CandidatePet(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      speciesName: speciesName ?? this.speciesName,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      checks: checks ?? this.checks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'species_id': speciesId,
      'species_name': speciesName,
      'name': name,
      'image_url': imageUrl,
      'checks': checks.map((c) => c.toMap()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CandidatePet.fromMap(Map<String, dynamic> map) {
    return CandidatePet(
      id: map['id'],
      speciesId: map['species_id'],
      speciesName: map['species_name'],
      name: map['name'],
      imageUrl: map['image_url'],
      checks: (map['checks'] as List)
          .map((c) => CheckItem.fromMap(c))
          .toList(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// 检查项模型
class CheckItem {
  final String id;
  final String title;
  final String? description;
  final bool isChecked;
  final int weight;

  CheckItem({
    required this.id,
    required this.title,
    this.description,
    this.isChecked = false,
    required this.weight,
  });

  CheckItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isChecked,
    int? weight,
  }) {
    return CheckItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isChecked: isChecked ?? this.isChecked,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_checked': isChecked,
      'weight': weight,
    };
  }

  factory CheckItem.fromMap(Map<String, dynamic> map) {
    return CheckItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isChecked: map['is_checked'] ?? false,
      weight: map['weight'] ?? 1,
    );
  }
}

// 获取某类别的默认检查项
List<CheckItem> getDefaultChecks(String category) {
  switch (category) {
    case 'snake':
      return [
        CheckItem(id: '1', title: '精神状态良好', description: '反应灵敏,活泼好动', weight: 3),
        CheckItem(id: '2', title: '体表无外伤', description: '无咬伤、划伤等', weight: 2),
        CheckItem(id: '3', title: '进食正常', description: '能够正常进食', weight: 3),
        CheckItem(id: '4', title: '蜕皮完整', description: '无卡皮现象', weight: 2),
        CheckItem(id: '5', title: '眼睛明亮', description: '无分泌物、凹陷', weight: 2),
        CheckItem(id: '6', title: '活动正常', description: '游动/爬行正常', weight: 2),
        CheckItem(id: '7', title: '排泄正常', description: '粪便正常', weight: 2),
        CheckItem(id: '8', title: '人工繁殖', description: 'CB个体更易饲养', weight: 1),
        CheckItem(id: '9', title: '口腔健康', description: '无红肿、黏液', weight: 2),
        CheckItem(id: '10', title: '体重正常', description: '体型饱满不过瘦', weight: 2),
      ];
    case 'lizard':
      return [
        CheckItem(id: '1', title: '精神状态良好', description: '反应灵敏', weight: 3),
        CheckItem(id: '2', title: '四肢健全', description: '无残疾、畸形', weight: 3),
        CheckItem(id: '3', title: '皮肤完整', description: '无溃烂、破损', weight: 2),
        CheckItem(id: '4', title: '眼睛明亮', description: '无分泌物', weight: 2),
        CheckItem(id: '5', title: '进食积极', description: '愿意主动进食', weight: 3),
        CheckItem(id: '6', title: '体重正常', description: '肌肉结实', weight: 2),
        CheckItem(id: '7', title: '尾巴完整', description: '无断裂', weight: 2),
        CheckItem(id: '8', title: '人工繁殖', description: 'CB个体', weight: 1),
        CheckItem(id: '9', title: '无寄生虫', description: '体表无虫', weight: 2),
        CheckItem(id: '10', title: '排便正常', description: '粪便成型', weight: 2),
      ];
    case 'turtle':
      return [
        CheckItem(id: '1', title: '精神状态良好', description: '反应灵敏', weight: 3),
        CheckItem(id: '2', title: '龟甲完整', description: '无软甲、畸形', weight: 3),
        CheckItem(id: '3', title: '四肢有力', description: '挣扎有力', weight: 2),
        CheckItem(id: '4', title: '鼻孔通畅', description: '无分泌物', weight: 2),
        CheckItem(id: '5', title: '眼睛明亮', description: '无白膜、肿胀', weight: 2),
        CheckItem(id: '6', title: '进食正常', description: '愿意进食', weight: 3),
        CheckItem(id: '7', title: '排泄正常', description: '粪便成型', weight: 2),
        CheckItem(id: '8', title: '体重正常', description: '体型饱满', weight: 2),
        CheckItem(id: '9', title: '人工繁殖', description: 'CB个体', weight: 1),
        CheckItem(id: '10', title: '无腐甲', description: '甲壳无腐烂', weight: 3),
      ];
    case 'gecko':
      return [
        CheckItem(id: '1', title: '精神状态良好', description: '活泼好动', weight: 3),
        CheckItem(id: '2', title: '脚趾完整', description: '无脱落', weight: 3),
        CheckItem(id: '3', title: '尾巴完整', description: '断尾影响品相', weight: 2),
        CheckItem(id: '4', title: '皮肤完整', description: '无溃烂', weight: 2),
        CheckItem(id: '5', title: '眼睛明亮', description: '无凹陷', weight: 2),
        CheckItem(id: '6', title: '进食正常', description: '愿意进食', weight: 3),
        CheckItem(id: '7', title: '体重正常', description: '体型饱满', weight: 2),
        CheckItem(id: '8', title: '趾垫完好', description: '能正常攀爬', weight: 3),
        CheckItem(id: '9', title: '人工繁殖', description: 'CB个体', weight: 1),
        CheckItem(id: '10', title: '无寄生虫', description: '体表干净', weight: 2),
      ];
    case 'amphibian':
      return [
        CheckItem(id: '1', title: '精神状态良好', description: '反应灵敏', weight: 3),
        CheckItem(id: '2', title: '皮肤完整', description: '无溃烂、破损', weight: 3),
        CheckItem(id: '3', title: '四肢健全', description: '跳跃有力', weight: 2),
        CheckItem(id: '4', title: '眼睛凸起', description: '无凹陷', weight: 2),
        CheckItem(id: '5', title: '进食正常', description: '愿意进食', weight: 3),
        CheckItem(id: '6', title: '体型正常', description: '不过瘦', weight: 2),
        CheckItem(id: '7', title: '无外伤', description: '无擦伤', weight: 2),
        CheckItem(id: '8', title: '排泄正常', description: '粪便正常', weight: 2),
        CheckItem(id: '9', title: '人工繁殖', description: 'CB个体', weight: 1),
        CheckItem(id: '10', title: '无寄生虫', description: '干净健康', weight: 2),
      ];
    default:
      return [
        CheckItem(id: '1', title: '精神状态良好', description: '反应灵敏', weight: 3),
        CheckItem(id: '2', title: '身体无外伤', description: '无明显伤口', weight: 2),
        CheckItem(id: '3', title: '进食正常', description: '愿意进食', weight: 3),
        CheckItem(id: '4', title: '体重正常', description: '体型适中', weight: 2),
        CheckItem(id: '5', title: '活动正常', description: '行为正常', weight: 2),
        CheckItem(id: '6', title: '排泄正常', description: '粪便成型', weight: 2),
        CheckItem(id: '7', title: '人工繁殖', description: 'CB个体', weight: 1),
        CheckItem(id: '8', title: '无寄生虫', description: '体表干净', weight: 2),
      ];
  }
}
