// 虚拟宠物数据模型
class VirtualPet {
  final String id;
  final String speciesId;        // 关联的物种ID
  final String name;            // 宠物名称
  final String? nickname;       // 昵称
  final String? imageUrl;       // 宠物图片
  final DateTime birthDate;     // 出生日期
  final String? birthDateCustom; // 自定义出生日期字符串
  final String gender;          // 性别: male, female, unknown
  final double? weight;         // 体重(g)
  final double? length;         // 体长(cm)
  final String? morph;          // 变异/品系
  final DateTime acquiredDate;  // 获得日期
  final String? acquiredFrom;   // 获取来源
  final String? notes;          // 备注
  final int healthScore;        // 健康指数 (0-100)
  final int happiness;          // 快乐度 (0-100)
  final int hunger;            // 饥饿度 (0-100)
  final DateTime lastFed;      // 上次喂食时间
  final DateTime lastCleaned;  // 上次清洁时间
  final DateTime lastPlayed;  // 上次互动时间
  final DateTime createdAt;
  final DateTime updatedAt;

  VirtualPet({
    required this.id,
    required this.speciesId,
    required this.name,
    this.nickname,
    this.imageUrl,
    required this.birthDate,
    this.birthDateCustom,
    this.gender = 'unknown',
    this.weight,
    this.length,
    this.morph,
    required this.acquiredDate,
    this.acquiredFrom,
    this.notes,
    this.healthScore = 100,
    this.happiness = 100,
    this.hunger = 0,
    required this.lastFed,
    required this.lastCleaned,
    required this.lastPlayed,
    required this.createdAt,
    required this.updatedAt,
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

  /// 获取饥饿状态
  String getHungerStatus() {
    final hours = DateTime.now().difference(lastFed).inHours;
    if (hours < 12) return '饱';
    if (hours < 24) return '一般';
    if (hours < 48) return '饥饿';
    return '非常饥饿';
  }

  /// 获取快乐状态
  String getHappinessStatus() {
    if (happiness >= 80) return '开心';
    if (happiness >= 50) return '一般';
    return '寂寞';
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
      'weight': weight,
      'length': length,
      'morph': morph,
      'acquired_date': acquiredDate.toIso8601String(),
      'acquired_from': acquiredFrom,
      'notes': notes,
      'health_score': healthScore,
      'happiness': happiness,
      'hunger': hunger,
      'last_fed': lastFed.toIso8601String(),
      'last_cleaned': lastCleaned.toIso8601String(),
      'last_played': lastPlayed.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory VirtualPet.fromMap(Map<String, dynamic> map) {
    return VirtualPet(
      id: map['id'],
      speciesId: map['species_id'],
      name: map['name'],
      nickname: map['nickname'],
      imageUrl: map['image_url'],
      birthDate: DateTime.parse(map['birth_date']),
      birthDateCustom: map['birth_date_custom'],
      gender: map['gender'] ?? 'unknown',
      weight: map['weight']?.toDouble(),
      length: map['length']?.toDouble(),
      morph: map['morph'],
      acquiredDate: DateTime.parse(map['acquired_date']),
      acquiredFrom: map['acquired_from'],
      notes: map['notes'],
      healthScore: map['health_score'] ?? 100,
      happiness: map['happiness'] ?? 100,
      hunger: map['hunger'] ?? 0,
      lastFed: DateTime.parse(map['last_fed']),
      lastCleaned: DateTime.parse(map['last_cleaned']),
      lastPlayed: DateTime.parse(map['last_played']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  VirtualPet copyWith({
    String? id,
    String? speciesId,
    String? name,
    String? nickname,
    String? imageUrl,
    DateTime? birthDate,
    String? birthDateCustom,
    String? gender,
    double? weight,
    double? length,
    String? morph,
    DateTime? acquiredDate,
    String? acquiredFrom,
    String? notes,
    int? healthScore,
    int? happiness,
    int? hunger,
    DateTime? lastFed,
    DateTime? lastCleaned,
    DateTime? lastPlayed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VirtualPet(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      imageUrl: imageUrl ?? this.imageUrl,
      birthDate: birthDate ?? this.birthDate,
      birthDateCustom: birthDateCustom ?? this.birthDateCustom,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      morph: morph ?? this.morph,
      acquiredDate: acquiredDate ?? this.acquiredDate,
      acquiredFrom: acquiredFrom ?? this.acquiredFrom,
      notes: notes ?? this.notes,
      healthScore: healthScore ?? this.healthScore,
      happiness: happiness ?? this.happiness,
      hunger: hunger ?? this.hunger,
      lastFed: lastFed ?? this.lastFed,
      lastCleaned: lastCleaned ?? this.lastCleaned,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// 虚拟宠物活动记录
class PetActivity {
  final String id;
  final String petId;
  final String activityType; // feeding, cleaning, playing, training, health_check
  final String? notes;
  final DateTime createdAt;

  PetActivity({
    required this.id,
    required this.petId,
    required this.activityType,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'activity_type': activityType,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PetActivity.fromMap(Map<String, dynamic> map) {
    return PetActivity(
      id: map['id'],
      petId: map['pet_id'],
      activityType: map['activity_type'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// 虚拟宠物日记
class PetDiary {
  final String id;
  final String petId;
  final String title;
  final String content;
  final List<String>? images;
  final DateTime date;

  PetDiary({
    required this.id,
    required this.petId,
    required this.title,
    required this.content,
    this.images,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'title': title,
      'content': content,
      'images': images?.join(','),
      'date': date.toIso8601String(),
    };
  }

  factory PetDiary.fromMap(Map<String, dynamic> map) {
    return PetDiary(
      id: map['id'],
      petId: map['pet_id'],
      title: map['title'],
      content: map['content'],
      images: map['images'] != null && map['images'].toString().isNotEmpty
          ? map['images'].toString().split(',')
          : null,
      date: DateTime.parse(map['date']),
    );
  }
}
