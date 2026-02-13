// 喂食记录模型
class FeedingRecord {
  final String id;
  final String reptileId;
  final DateTime feedingTime;
  final String foodType; // 食物类型
  final double? foodAmount; // 食物量(g)
  final String? notes;
  final DateTime createdAt;

  FeedingRecord({
    required this.id,
    required this.reptileId,
    required this.feedingTime,
    required this.foodType,
    this.foodAmount,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reptile_id': reptileId,
      'feeding_time': feedingTime.toIso8601String(),
      'food_type': foodType,
      'food_amount': foodAmount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FeedingRecord.fromMap(Map<String, dynamic> map) {
    return FeedingRecord(
      id: map['id'],
      reptileId: map['reptile_id'],
      feedingTime: DateTime.parse(map['feeding_time']),
      foodType: map['food_type'],
      foodAmount: map['food_amount']?.toDouble(),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// 健康记录模型
class HealthRecord {
  final String id;
  final String reptileId;
  final DateTime recordDate;
  final double? weight;
  final double? length;
  final String? status; // 状态: normal, shedding, sick, etc.
  final String? defecation; // 排便: normal, abnormal, none
  final String? notes;
  final DateTime createdAt;

  HealthRecord({
    required this.id,
    required this.reptileId,
    required this.recordDate,
    this.weight,
    this.length,
    this.status,
    this.defecation,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reptile_id': reptileId,
      'record_date': recordDate.toIso8601String(),
      'weight': weight,
      'length': length,
      'status': status,
      'defecation': defecation,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      reptileId: map['reptile_id'],
      recordDate: DateTime.parse(map['record_date']),
      weight: map['weight']?.toDouble(),
      length: map['length']?.toDouble(),
      status: map['status'],
      defecation: map['defecation'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// 成长相册模型
class GrowthPhoto {
  final String id;
  final String reptileId;
  final String imagePath;
  final String? description;
  final DateTime photoDate;
  final DateTime createdAt;

  GrowthPhoto({
    required this.id,
    required this.reptileId,
    required this.imagePath,
    this.description,
    required this.photoDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reptile_id': reptileId,
      'image_path': imagePath,
      'description': description,
      'photo_date': photoDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory GrowthPhoto.fromMap(Map<String, dynamic> map) {
    return GrowthPhoto(
      id: map['id'],
      reptileId: map['reptile_id'],
      imagePath: map['image_path'],
      description: map['description'],
      photoDate: DateTime.parse(map['photo_date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
