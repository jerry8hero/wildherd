import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/encyclopedia.dart';

void main() {
  group('ReptileSpecies', () {
    test('creates with required fields', () {
      final species = ReptileSpecies(
        id: 'sp-001',
        nameChinese: '草龟',
        nameEnglish: 'Chinese Pond Turtle',
        scientificName: 'Mauremys reevesii',
        category: 'turtle',
        description: '常见的淡水龟',
        difficulty: 1,
        lifespan: 30,
        diet: 'omnivore',
      );

      expect(species.id, 'sp-001');
      expect(species.nameChinese, '草龟');
      expect(species.difficulty, 1);
      expect(species.diet, 'omnivore');
      expect(species.minTemp, isNull);
    });

    test('creates with all fields', () {
      final species = ReptileSpecies(
        id: 'sp-002',
        nameChinese: '豹纹守宫',
        nameEnglish: 'Leopard Gecko',
        scientificName: 'Eublepharis macularius',
        category: 'lizard',
        description: '适合新手的蜥蜴',
        difficulty: 1,
        lifespan: 15,
        diet: 'insectivore',
        minTemp: 25.0,
        maxTemp: 32.0,
        minHumidity: 30.0,
        maxHumidity: 50.0,
      );

      expect(species.minTemp, 25.0);
      expect(species.maxTemp, 32.0);
    });

    test('fromMap / toMap round-trip', () {
      final original = ReptileSpecies(
        id: 'sp-010',
        nameChinese: '红耳龟',
        nameEnglish: 'Red-eared Slider',
        scientificName: 'Trachemys scripta',
        category: 'turtle',
        description: '巴西龟',
        difficulty: 2,
        lifespan: 40,
        diet: 'omnivore',
        subCategory: '水龟',
        maxLength: 30.0,
        minTemp: 22.0,
        maxTemp: 30.0,
        minHumidity: 50.0,
        maxHumidity: 80.0,
        imageUrl: 'https://example.com/turtle.jpg',
      );

      final restored = ReptileSpecies.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.nameChinese, original.nameChinese);
      expect(restored.scientificName, original.scientificName);
      expect(restored.difficulty, original.difficulty);
      expect(restored.maxLength, original.maxLength);
      expect(restored.minTemp, original.minTemp);
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'id': 'sp-020',
        'name_chinese': '测试龟',
        'name_english': 'Test Turtle',
        'scientific_name': 'Testus testus',
        'category': 'turtle',
        'description': '测试',
      };

      final species = ReptileSpecies.fromMap(map);

      expect(species.difficulty, 1);
      expect(species.lifespan, 10);
      expect(species.diet, 'omnivore');
    });
  });

  group('CareGuide', () {
    test('creates with required fields', () {
      final guide = CareGuide(
        id: 'cg-001',
        speciesId: 'sp-001',
        title: '饲养指南',
        content: '详细内容...',
        category: 'care',
      );

      expect(guide.id, 'cg-001');
      expect(guide.speciesId, 'sp-001');
      expect(guide.category, 'care');
    });

    test('toMap serializes correctly', () {
      final guide = CareGuide(
        id: 'cg-001',
        speciesId: 'sp-001',
        title: '温度管理',
        content: '保持25-30度',
        category: 'environment',
      );

      final map = guide.toMap();

      expect(map['id'], 'cg-001');
      expect(map['species_id'], 'sp-001');
      expect(map['category'], 'environment');
    });
  });
}
