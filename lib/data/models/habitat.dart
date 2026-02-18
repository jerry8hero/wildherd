// 饲养环境数据模型

class HabitatEnvironment {
  final String id;
  final String reptileId;
  final String reptileName;
  final String speciesId;
  final double temperature; // 温度 (°C)
  final double humidity; // 湿度 (%)
  final double? uvIndex; // UV指数
  final String? substrate; // 垫材类型
  final String? lighting; // 照明类型
  final double? tankSize; // 饲养箱尺寸 (升)
  final String? heating; // 加热方式
  final String? ventilation; // 通风情况
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HabitatEnvironment({
    required this.id,
    required this.reptileId,
    required this.reptileName,
    required this.speciesId,
    required this.temperature,
    required this.humidity,
    this.uvIndex,
    this.substrate,
    this.lighting,
    this.tankSize,
    this.heating,
    this.ventilation,
    this.createdAt,
    this.updatedAt,
  });

  factory HabitatEnvironment.fromMap(Map<String, dynamic> map) {
    return HabitatEnvironment(
      id: map['id'] ?? '',
      reptileId: map['reptile_id'] ?? '',
      reptileName: map['reptile_name'] ?? '',
      speciesId: map['species_id'] ?? '',
      temperature: (map['temperature'] ?? 25).toDouble(),
      humidity: (map['humidity'] ?? 50).toDouble(),
      uvIndex: map['uv_index']?.toDouble(),
      substrate: map['substrate'],
      lighting: map['lighting'],
      tankSize: map['tank_size']?.toDouble(),
      heating: map['heating'],
      ventilation: map['ventilation'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reptile_id': reptileId,
      'reptile_name': reptileName,
      'species_id': speciesId,
      'temperature': temperature,
      'humidity': humidity,
      'uv_index': uvIndex,
      'substrate': substrate,
      'lighting': lighting,
      'tank_size': tankSize,
      'heating': heating,
      'ventilation': ventilation,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  HabitatEnvironment copyWith({
    String? id,
    String? reptileId,
    String? reptileName,
    String? speciesId,
    double? temperature,
    double? humidity,
    double? uvIndex,
    String? substrate,
    String? lighting,
    double? tankSize,
    String? heating,
    String? ventilation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitatEnvironment(
      id: id ?? this.id,
      reptileId: reptileId ?? this.reptileId,
      reptileName: reptileName ?? this.reptileName,
      speciesId: speciesId ?? this.speciesId,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      uvIndex: uvIndex ?? this.uvIndex,
      substrate: substrate ?? this.substrate,
      lighting: lighting ?? this.lighting,
      tankSize: tankSize ?? this.tankSize,
      heating: heating ?? this.heating,
      ventilation: ventilation ?? this.ventilation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// 物种标准环境参数
class HabitatStandard {
  final String speciesId;
  final double minTemp;
  final double maxTemp;
  final double idealTemp;
  final double minHumidity;
  final double maxHumidity;
  final double? idealHumidity;
  final double? idealUV;
  final List<String> suitableSubstrates;
  final String lightingNeed;
  final int minTankSize;
  final String? heatingRecommendation;
  final String? ventilationNeed;

  HabitatStandard({
    required this.speciesId,
    required this.minTemp,
    required this.maxTemp,
    required this.idealTemp,
    required this.minHumidity,
    required this.maxHumidity,
    this.idealHumidity,
    this.idealUV,
    required this.suitableSubstrates,
    required this.lightingNeed,
    required this.minTankSize,
    this.heatingRecommendation,
    this.ventilationNeed,
  });

  factory HabitatStandard.fromMap(Map<String, dynamic> map) {
    return HabitatStandard(
      speciesId: map['species_id'] ?? '',
      minTemp: (map['min_temp'] ?? 20).toDouble(),
      maxTemp: (map['max_temp'] ?? 30).toDouble(),
      idealTemp: (map['ideal_temp'] ?? 25).toDouble(),
      minHumidity: (map['min_humidity'] ?? 30).toDouble(),
      maxHumidity: (map['max_humidity'] ?? 70).toDouble(),
      idealHumidity: map['ideal_humidity']?.toDouble(),
      idealUV: map['ideal_uv']?.toDouble(),
      suitableSubstrates: map['suitable_substrates'] != null
          ? List<String>.from(map['suitable_substrates'])
          : [],
      lightingNeed: map['lighting_need'] ?? '需适量UVB',
      minTankSize: map['min_tank_size'] ?? 60,
      heatingRecommendation: map['heating_recommendation'],
      ventilationNeed: map['ventilation_need'],
    );
  }
}

// 环境评分
class HabitatScore {
  final double temperatureScore;
  final double humidityScore;
  final double uvScore;
  final double spaceScore;
  final double overallScore;
  final List<HabitatSuggestion> suggestions;

  HabitatScore({
    required this.temperatureScore,
    required this.humidityScore,
    required this.uvScore,
    required this.spaceScore,
    required this.overallScore,
    required this.suggestions,
  });
}

// 改进建议
class HabitatSuggestion {
  final String title;
  final String description;
  final String category; // temperature, humidity, uv, space, substrate, lighting
  final String priority; // high, medium, low

  HabitatSuggestion({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
  });
}

// 垫材选项
class SubstrateOption {
  final String id;
  final String name;
  final String description;
  final List<String> suitableFor;

  SubstrateOption({
    required this.id,
    required this.name,
    required this.description,
    required this.suitableFor,
  });
}

// 照明选项
class LightingOption {
  final String id;
  final String name;
  final String description;
  final double? uvValue;

  LightingOption({
    required this.id,
    required this.name,
    required this.description,
    this.uvValue,
  });
}

// 常用垫材列表
class SubstrateOptions {
  static List<SubstrateOption> get all => [
    SubstrateOption(
      id: 'coconut_fiber',
      name: '椰糠',
      description: '保湿性好，适合热带种类',
      suitableFor: ['gecko', 'lizard', 'amphibian'],
    ),
    SubstrateOption(
      id: 'soil_mix',
      name: '土沙混合',
      description: '保湿透气，适合造景',
      suitableFor: ['lizard', 'gecko'],
    ),
    SubstrateOption(
      id: 'reptile_carpet',
      name: '爬宠毯',
      description: '易于清洁，适合新手',
      suitableFor: ['snake', 'lizard'],
    ),
    SubstrateOption(
      id: 'paper_towel',
      name: '厨房纸',
      description: '方便更换，适合观察排泄',
      suitableFor: ['snake', 'gecko', 'lizard'],
    ),
    SubstrateOption(
      id: 'sand',
      name: '爬沙',
      description: '适合沙漠种类',
      suitableFor: ['lizard', 'gecko'],
    ),
    SubstrateOption(
      id: 'bark',
      name: '树皮',
      description: '保湿性好，适合热带种类',
      suitableFor: ['snake', 'lizard'],
    ),
    SubstrateOption(
      id: 'gravel',
      name: '砾石',
      description: '适合水龟',
      suitableFor: ['turtle'],
    ),
  ];
}

// 常用照明列表
class LightingOptions {
  static List<LightingOption> get all => [
    LightingOption(
      id: 'uvb_tube',
      name: 'UVB灯管',
      description: '提供UVB照射，促进钙吸收',
      uvValue: 10.0,
    ),
    LightingOption(
      id: 'uvb_compact',
      name: 'UVB节能灯',
      description: '节省空间，适合小饲养箱',
      uvValue: 5.0,
    ),
    LightingOption(
      id: 'mercury_vapor',
      name: '汞灯',
      description: '同时提供加热和UVB',
      uvValue: 12.0,
    ),
    LightingOption(
      id: 'halogen',
      name: '卤素灯',
      description: '加热效果好',
      uvValue: 0,
    ),
    LightingOption(
      id: 'led',
      name: 'LED灯',
      description: '节能，适合观赏',
      uvValue: 0,
    ),
    LightingOption(
      id: 'none',
      name: '无特殊照明',
      description: '不需要额外UVB',
      uvValue: 0,
    ),
  ];
}
