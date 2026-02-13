// 爬宠种类百科模型
class ReptileSpecies {
  final String id;
  final String nameChinese;
  final String nameEnglish;
  final String scientificName;
  final String category; // 类别: snake, lizard, turtle, gecko, amphibian, arachnid
  final String? subCategory; // 子分类: aquatic, semi_aquatic, terrestrial (用于龟类)
  final String description;
  final int difficulty; // 饲养难度 1-5
  final int lifespan; // 预期寿命(年)
  final double? maxLength; // 最大长度(cm)
  final double? minTemp; // 最低温度(°C)
  final double? maxTemp; // 最高温度(°C)
  final double? minHumidity; // 最低湿度(%)
  final double? maxHumidity; // 最高湿度(%)
  final String diet; // 食性: carnivore, herbivore, omnivore
  final String? imageUrl;

  ReptileSpecies({
    required this.id,
    required this.nameChinese,
    required this.nameEnglish,
    required this.scientificName,
    required this.category,
    this.subCategory,
    required this.description,
    required this.difficulty,
    required this.lifespan,
    this.maxLength,
    this.minTemp,
    this.maxTemp,
    this.minHumidity,
    this.maxHumidity,
    required this.diet,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_chinese': nameChinese,
      'name_english': nameEnglish,
      'scientific_name': scientificName,
      'category': category,
      'sub_category': subCategory,
      'description': description,
      'difficulty': difficulty,
      'lifespan': lifespan,
      'max_length': maxLength,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'min_humidity': minHumidity,
      'max_humidity': maxHumidity,
      'diet': diet,
      'image_url': imageUrl,
    };
  }

  factory ReptileSpecies.fromMap(Map<String, dynamic> map) {
    return ReptileSpecies(
      id: map['id'],
      nameChinese: map['name_chinese'],
      nameEnglish: map['name_english'],
      scientificName: map['scientific_name'],
      category: map['category'],
      subCategory: map['sub_category'],
      description: map['description'],
      difficulty: map['difficulty'],
      lifespan: map['lifespan'],
      maxLength: map['max_length']?.toDouble(),
      minTemp: map['min_temp']?.toDouble(),
      maxTemp: map['max_temp']?.toDouble(),
      minHumidity: map['min_humidity']?.toDouble(),
      maxHumidity: map['max_humidity']?.toDouble(),
      diet: map['diet'],
      imageUrl: map['image_url'],
    );
  }
}

// 饲养指南模型
class CareGuide {
  final String id;
  final String speciesId;
  final String title;
  final String content;
  final String category; // housing, feeding, temperature, humidity, etc.

  CareGuide({
    required this.id,
    required this.speciesId,
    required this.title,
    required this.content,
    required this.category,
  });
}
