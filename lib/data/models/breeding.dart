// 繁殖相关数据模型

/// 繁殖批次状态
enum BreedingStatus {
  mating,      // 交配中
  laid,        // 已产蛋
  incubating,  // 孵化中
  hatched,     // 已出壳
  failed,      // 失败
  cancelled,   // 取消
}

/// 蛋的受精状态
enum EggFertility {
  fertile,     // 受精
  infertile,   // 未受精
  unknown,     // 未知
}

/// 蛋的孵化状态
enum EggHatchStatus {
  hatched,     // 已出壳
  died,        // 死亡
  culled,      // 淘汰
  pending,     // 待孵化
}

/// 蛋的状态
enum EggStatus {
  incubating,  // 孵化中
  hatched,     // 已出壳
  died,        // 死亡
  infertile,   // 无精蛋
}

/// 苗子状态
enum OffspringStatus {
  alive,       // 存活
  sold,        // 已出售
  gifted,      // 已赠送
  deceased,    // 死亡
}

/// 提醒类型
enum ReminderType {
  brumationStart,    // 冬化开始
  brumationEnd,      // 冬化结束
  heating,           // 升温刺激
  mating,            // 交配期
  eggLaying,        // 产蛋期
  candling,          // 照蛋
  hatching,          // 出壳
}

/// 繁殖批次 - 记录一次完整的繁殖周期
class BreedingBatch {
  final String id;
  final String reptileId;      // 母体ID
  final String? fatherId;      // 父体ID（可选）
  final String reptileName;
  final String species;
  final DateTime matingDate;  // 交配日期
  final DateTime? eggLayingDate; // 产蛋日期
  final int? eggCount;         // 产蛋数量
  final DateTime? incubationStartDate; // 孵化开始日期
  final DateTime? expectedHatchDate;   // 预计出壳日期
  final int? hatchedCount;     // 实际出壳数量
  final String? status;        // 繁殖状态
  final String? notes;         // 备注
  final DateTime createdAt;
  final DateTime updatedAt;

  BreedingBatch({
    required this.id,
    required this.reptileId,
    this.fatherId,
    required this.reptileName,
    required this.species,
    required this.matingDate,
    this.eggLayingDate,
    this.eggCount,
    this.incubationStartDate,
    this.expectedHatchDate,
    this.hatchedCount,
    this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reptile_id': reptileId,
      'father_id': fatherId,
      'reptile_name': reptileName,
      'species': species,
      'mating_date': matingDate.toIso8601String(),
      'egg_laying_date': eggLayingDate?.toIso8601String(),
      'egg_count': eggCount,
      'incubation_start_date': incubationStartDate?.toIso8601String(),
      'expected_hatch_date': expectedHatchDate?.toIso8601String(),
      'hatched_count': hatchedCount,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BreedingBatch.fromMap(Map<String, dynamic> map) {
    return BreedingBatch(
      id: map['id'],
      reptileId: map['reptile_id'],
      fatherId: map['father_id'],
      reptileName: map['reptile_name'],
      species: map['species'],
      matingDate: DateTime.parse(map['mating_date']),
      eggLayingDate: map['egg_laying_date'] != null
          ? DateTime.parse(map['egg_laying_date'])
          : null,
      eggCount: map['egg_count']?.toInt(),
      incubationStartDate: map['incubation_start_date'] != null
          ? DateTime.parse(map['incubation_start_date'])
          : null,
      expectedHatchDate: map['expected_hatch_date'] != null
          ? DateTime.parse(map['expected_hatch_date'])
          : null,
      hatchedCount: map['hatched_count']?.toInt(),
      status: map['status'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  BreedingBatch copyWith({
    String? id,
    String? reptileId,
    String? fatherId,
    String? reptileName,
    String? species,
    DateTime? matingDate,
    DateTime? eggLayingDate,
    int? eggCount,
    DateTime? incubationStartDate,
    DateTime? expectedHatchDate,
    int? hatchedCount,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BreedingBatch(
      id: id ?? this.id,
      reptileId: reptileId ?? this.reptileId,
      fatherId: fatherId ?? this.fatherId,
      reptileName: reptileName ?? this.reptileName,
      species: species ?? this.species,
      matingDate: matingDate ?? this.matingDate,
      eggLayingDate: eggLayingDate ?? this.eggLayingDate,
      eggCount: eggCount ?? this.eggCount,
      incubationStartDate: incubationStartDate ?? this.incubationStartDate,
      expectedHatchDate: expectedHatchDate ?? this.expectedHatchDate,
      hatchedCount: hatchedCount ?? this.hatchedCount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 获取当前繁殖阶段
  String get stage {
    if (status == 'hatched') return '已出壳';
    if (status == 'incubating' || incubationStartDate != null) return '孵化中';
    if (status == 'laid' || eggLayingDate != null) return '已产蛋';
    if (status == 'mating' || status == null) return '交配中';
    return '未知';
  }
}

/// 繁殖蛋 - 记录每颗蛋的状态
class BreedingEgg {
  final String id;
  final String batchId;          // 所属批次
  final int eggNumber;            // 蛋的编号
  final String? fertility;       // fertile, infertile, unknown
  final DateTime? candlingDate;   // 照蛋日期
  final String? candlingResult;   // 照蛋结果
  final DateTime? hatchDate;      // 出壳日期
  final String? hatchStatus;     // hatched, died, culled
  final String? offspringId;       // 如果出壳，关联的苗子ID
  final String? notes;            // 备注
  final DateTime createdAt;
  final DateTime updatedAt;

  BreedingEgg({
    required this.id,
    required this.batchId,
    required this.eggNumber,
    this.fertility,
    this.candlingDate,
    this.candlingResult,
    this.hatchDate,
    this.hatchStatus,
    this.offspringId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batch_id': batchId,
      'egg_number': eggNumber,
      'fertility': fertility,
      'candling_date': candlingDate?.toIso8601String(),
      'candling_result': candlingResult,
      'hatch_date': hatchDate?.toIso8601String(),
      'hatch_status': hatchStatus,
      'offspring_id': offspringId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BreedingEgg.fromMap(Map<String, dynamic> map) {
    return BreedingEgg(
      id: map['id'],
      batchId: map['batch_id'],
      eggNumber: map['egg_number'],
      fertility: map['fertility'],
      candlingDate: map['candling_date'] != null
          ? DateTime.parse(map['candling_date'])
          : null,
      candlingResult: map['candling_result'],
      hatchDate: map['hatch_date'] != null
          ? DateTime.parse(map['hatch_date'])
          : null,
      hatchStatus: map['hatch_status'],
      offspringId: map['offspring_id'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  BreedingEgg copyWith({
    String? id,
    String? batchId,
    int? eggNumber,
    String? fertility,
    DateTime? candlingDate,
    String? candlingResult,
    DateTime? hatchDate,
    String? hatchStatus,
    String? offspringId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BreedingEgg(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      eggNumber: eggNumber ?? this.eggNumber,
      fertility: fertility ?? this.fertility,
      candlingDate: candlingDate ?? this.candlingDate,
      candlingResult: candlingResult ?? this.candlingResult,
      hatchDate: hatchDate ?? this.hatchDate,
      hatchStatus: hatchStatus ?? this.hatchStatus,
      offspringId: offspringId ?? this.offspringId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 苗子档案 - 记录繁殖出的苗子
class Offspring {
  final String id;
  final String? parentBatchId;   // 所属繁殖批次
  final String? parentId;         // 母体ID
  final String? fatherId;         // 父体ID
  final String name;
  final String species;
  final String? morph;             // 变异基因
  final String? gender;           // 性别
  final DateTime? birthDate;
  final double? birthWeight;      // 出生体重
  final double? currentWeight;    // 当前体重
  final double? currentLength;    // 当前体长
  final String? imagePath;
  final String? status;           // alive, sold, gifted, deceased
  final String? notes;            // 备注
  final DateTime createdAt;
  final DateTime updatedAt;

  Offspring({
    required this.id,
    this.parentBatchId,
    this.parentId,
    this.fatherId,
    required this.name,
    required this.species,
    this.morph,
    this.gender,
    this.birthDate,
    this.birthWeight,
    this.currentWeight,
    this.currentLength,
    this.imagePath,
    this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_batch_id': parentBatchId,
      'parent_id': parentId,
      'father_id': fatherId,
      'name': name,
      'species': species,
      'morph': morph,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'birth_weight': birthWeight,
      'current_weight': currentWeight,
      'current_length': currentLength,
      'image_path': imagePath,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Offspring.fromMap(Map<String, dynamic> map) {
    return Offspring(
      id: map['id'],
      parentBatchId: map['parent_batch_id'],
      parentId: map['parent_id'],
      fatherId: map['father_id'],
      name: map['name'],
      species: map['species'],
      morph: map['morph'],
      gender: map['gender'],
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'])
          : null,
      birthWeight: map['birth_weight']?.toDouble(),
      currentWeight: map['current_weight']?.toDouble(),
      currentLength: map['current_length']?.toDouble(),
      imagePath: map['image_path'],
      status: map['status'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Offspring copyWith({
    String? id,
    String? parentBatchId,
    String? parentId,
    String? fatherId,
    String? name,
    String? species,
    String? morph,
    String? gender,
    DateTime? birthDate,
    double? birthWeight,
    double? currentWeight,
    double? currentLength,
    String? imagePath,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Offspring(
      id: id ?? this.id,
      parentBatchId: parentBatchId ?? this.parentBatchId,
      parentId: parentId ?? this.parentId,
      fatherId: fatherId ?? this.fatherId,
      name: name ?? this.name,
      species: species ?? this.species,
      morph: morph ?? this.morph,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthWeight: birthWeight ?? this.birthWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      currentLength: currentLength ?? this.currentLength,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 苗子成长记录
class OffspringGrowth {
  final String id;
  final String offspringId;
  final DateTime recordDate;
  final double? weight;
  final double? length;
  final String? feedingStatus;     // 喂食状态
  final String? sheddingStatus;   // 蜕皮状态
  final String? notes;
  final DateTime createdAt;

  OffspringGrowth({
    required this.id,
    required this.offspringId,
    required this.recordDate,
    this.weight,
    this.length,
    this.feedingStatus,
    this.sheddingStatus,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'offspring_id': offspringId,
      'record_date': recordDate.toIso8601String(),
      'weight': weight,
      'length': length,
      'feeding_status': feedingStatus,
      'shedding_status': sheddingStatus,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory OffspringGrowth.fromMap(Map<String, dynamic> map) {
    return OffspringGrowth(
      id: map['id'],
      offspringId: map['offspring_id'],
      recordDate: DateTime.parse(map['record_date']),
      weight: map['weight']?.toDouble(),
      length: map['length']?.toDouble(),
      feedingStatus: map['feeding_status'],
      sheddingStatus: map['shedding_status'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  OffspringGrowth copyWith({
    String? id,
    String? offspringId,
    DateTime? recordDate,
    double? weight,
    double? length,
    String? feedingStatus,
    String? sheddingStatus,
    String? notes,
    DateTime? createdAt,
  }) {
    return OffspringGrowth(
      id: id ?? this.id,
      offspringId: offspringId ?? this.offspringId,
      recordDate: recordDate ?? this.recordDate,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      feedingStatus: feedingStatus ?? this.feedingStatus,
      sheddingStatus: sheddingStatus ?? this.sheddingStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 冬化温度记录
class BrumationTemp {
  final String id;
  final String reptileId;
  final DateTime recordDate;
  final double temperature;
  final double? humidity;
  final String? notes;
  final DateTime createdAt;

  BrumationTemp({
    required this.id,
    required this.reptileId,
    required this.recordDate,
    required this.temperature,
    this.humidity,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reptile_id': reptileId,
      'record_date': recordDate.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BrumationTemp.fromMap(Map<String, dynamic> map) {
    return BrumationTemp(
      id: map['id'],
      reptileId: map['reptile_id'],
      recordDate: DateTime.parse(map['record_date']),
      temperature: map['temperature'].toDouble(),
      humidity: map['humidity']?.toDouble(),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  BrumationTemp copyWith({
    String? id,
    String? reptileId,
    DateTime? recordDate,
    double? temperature,
    double? humidity,
    String? notes,
    DateTime? createdAt,
  }) {
    return BrumationTemp(
      id: id ?? this.id,
      reptileId: reptileId ?? this.reptileId,
      recordDate: recordDate ?? this.recordDate,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 繁殖提醒
class BreedingReminder {
  final String id;
  final String reptileId;
  final String? reptileName;
  final String type;              // 提醒类型
  final DateTime scheduledDate;    // 计划日期
  final bool isTriggered;          // 是否已触发
  final String? notes;
  final DateTime createdAt;

  BreedingReminder({
    required this.id,
    required this.reptileId,
    this.reptileName,
    required this.type,
    required this.scheduledDate,
    this.isTriggered = false,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reptile_id': reptileId,
      'reptile_name': reptileName,
      'type': type,
      'scheduled_date': scheduledDate.toIso8601String(),
      'is_triggered': isTriggered ? '1' : '0',
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BreedingReminder.fromMap(Map<String, dynamic> map) {
    return BreedingReminder(
      id: map['id'],
      reptileId: map['reptile_id'],
      reptileName: map['reptile_name'],
      type: map['type'],
      scheduledDate: DateTime.parse(map['scheduled_date']),
      isTriggered: map['is_triggered'] == '1',
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  BreedingReminder copyWith({
    String? id,
    String? reptileId,
    String? reptileName,
    String? type,
    DateTime? scheduledDate,
    bool? isTriggered,
    String? notes,
    DateTime? createdAt,
  }) {
    return BreedingReminder(
      id: id ?? this.id,
      reptileId: reptileId ?? this.reptileId,
      reptileName: reptileName ?? this.reptileName,
      type: type ?? this.type,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isTriggered: isTriggered ?? this.isTriggered,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 获取提醒类型的中文名称
  String get typeName {
    switch (type) {
      case 'brumation_start':
        return '冬化开始';
      case 'brumation_end':
        return '冬化结束';
      case 'heating':
        return '升温刺激';
      case 'mating':
        return '交配期';
      case 'egg_laying':
        return '产蛋期';
      case 'candling':
        return '照蛋';
      case 'hatching':
        return '出壳';
      default:
        return type;
    }
  }
}

/// 繁殖经验日志
class BreedingLog {
  final String id;
  final String? batchId;           // 可选关联繁殖批次
  final String reptileId;
  final String? reptileName;
  final DateTime logDate;
  final String title;
  final String content;
  final List<String>? tags;
  final DateTime createdAt;

  BreedingLog({
    required this.id,
    this.batchId,
    required this.reptileId,
    this.reptileName,
    required this.logDate,
    required this.title,
    required this.content,
    this.tags,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batch_id': batchId,
      'reptile_id': reptileId,
      'reptile_name': reptileName,
      'log_date': logDate.toIso8601String(),
      'title': title,
      'content': content,
      'tags': tags?.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BreedingLog.fromMap(Map<String, dynamic> map) {
    return BreedingLog(
      id: map['id'],
      batchId: map['batch_id'],
      reptileId: map['reptile_id'],
      reptileName: map['reptile_name'],
      logDate: DateTime.parse(map['log_date']),
      title: map['title'],
      content: map['content'],
      tags: map['tags']?.split(','),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  BreedingLog copyWith({
    String? id,
    String? batchId,
    String? reptileId,
    String? reptileName,
    DateTime? logDate,
    String? title,
    String? content,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return BreedingLog(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      reptileId: reptileId ?? this.reptileId,
      reptileName: reptileName ?? this.reptileName,
      logDate: logDate ?? this.logDate,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 繁殖统计数据
class BreedingStats {
  final int totalBatches;       // 总繁殖批次
  final int totalEggs;          // 总产蛋数
  final int hatchedCount;       // 孵化数
  final int survivedCount;       // 成活数
  final double hatchRate;       // 孵化率
  final double survivalRate;    // 成活率
  final Map<String, int> speciesStats; // 按物种统计

  BreedingStats({
    required this.totalBatches,
    required this.totalEggs,
    required this.hatchedCount,
    required this.survivedCount,
    required this.hatchRate,
    required this.survivalRate,
    required this.speciesStats,
  });
}
