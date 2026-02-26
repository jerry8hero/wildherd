// 爬宠数据模型
class Reptile {
  final String id;
  final String name;
  final String species; // 种类
  final String? speciesChinese; // 中文名
  final String? gender; // 性别
  final DateTime? birthDate; // 出生日期
  final double? weight; // 体重(g)
  final double? length; // 体长(cm)
  final String? imagePath; // 头像路径
  final DateTime? acquisitionDate; // 获取日期
  final String? acquisitionSource; // 获取来源(购买/赠送/捡获等)
  final String? breedingStatus; // 繁殖状态(可用/繁殖中/退役)
  final DateTime? lastBreedingDate; // 上次繁殖日期
  final int? clutchCount; // 产卵次数
  final String? notes; // 备注
  final DateTime createdAt;
  final DateTime updatedAt;

  Reptile({
    required this.id,
    required this.name,
    required this.species,
    this.speciesChinese,
    this.gender,
    this.birthDate,
    this.weight,
    this.length,
    this.imagePath,
    this.acquisitionDate,
    this.acquisitionSource,
    this.breedingStatus,
    this.lastBreedingDate,
    this.clutchCount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'species_chinese': speciesChinese,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'weight': weight,
      'length': length,
      'image_path': imagePath,
      'acquisition_date': acquisitionDate?.toIso8601String(),
      'acquisition_source': acquisitionSource,
      'breeding_status': breedingStatus,
      'last_breeding_date': lastBreedingDate?.toIso8601String(),
      'clutch_count': clutchCount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Reptile.fromMap(Map<String, dynamic> map) {
    return Reptile(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      speciesChinese: map['species_chinese'],
      gender: map['gender'],
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'])
          : null,
      weight: map['weight']?.toDouble(),
      length: map['length']?.toDouble(),
      imagePath: map['image_path'],
      acquisitionDate: map['acquisition_date'] != null
          ? DateTime.parse(map['acquisition_date'])
          : null,
      acquisitionSource: map['acquisition_source'],
      breedingStatus: map['breeding_status'],
      lastBreedingDate: map['last_breeding_date'] != null
          ? DateTime.parse(map['last_breeding_date'])
          : null,
      clutchCount: map['clutch_count']?.toInt(),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Reptile copyWith({
    String? id,
    String? name,
    String? species,
    String? speciesChinese,
    String? gender,
    DateTime? birthDate,
    double? weight,
    double? length,
    String? imagePath,
    DateTime? acquisitionDate,
    String? acquisitionSource,
    String? breedingStatus,
    DateTime? lastBreedingDate,
    int? clutchCount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reptile(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      speciesChinese: speciesChinese ?? this.speciesChinese,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      imagePath: imagePath ?? this.imagePath,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      acquisitionSource: acquisitionSource ?? this.acquisitionSource,
      breedingStatus: breedingStatus ?? this.breedingStatus,
      lastBreedingDate: lastBreedingDate ?? this.lastBreedingDate,
      clutchCount: clutchCount ?? this.clutchCount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
