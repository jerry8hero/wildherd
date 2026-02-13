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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
