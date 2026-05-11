import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/lib/data/models/reptile.dart';

void main() {
  group('Reptile', () {
    group('Construction with all fields', () {
      test('should create Reptile with all fields populated', () {
        final reptile = Reptile(
          id: 'test-id-123',
          name: 'Test Reptile',
          species: 'Test Species',
          speciesChinese: '测试物种',
          gender: 'male',
          birthDate: DateTime(2020, 1, 15),
          weight: 150.5,
          length: 20.3,
          imagePath: '/path/to/image.jpg',
          acquisitionDate: DateTime(2021, 5, 20),
          acquisitionSource: '购买',
          breedingStatus: '可用',
          lastBreedingDate: DateTime(2022, 3, 10),
          clutchCount: 3,
          notes: '测试备注',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        expect(reptile.id, equals('test-id-123'));
        expect(reptile.name, equals('Test Reptile'));
        expect(reptile.species, equals('Test Species'));
        expect(reptile.speciesChinese, equals('测试物种'));
        expect(reptile.gender, equals('male'));
        expect(reptile.birthDate, equals(DateTime(2020, 1, 15)));
        expect(reptile.weight, equals(150.5));
        expect(reptile.length, equals(20.3));
        expect(reptile.imagePath, equals('/path/to/image.jpg'));
        expect(reptile.acquisitionDate, equals(DateTime(2021, 5, 20)));
        expect(reptile.acquisitionSource, equals('购买'));
        expect(reptile.breedingStatus, equals('可用'));
        expect(reptile.lastBreedingDate, equals(DateTime(2022, 3, 10)));
        expect(reptile.clutchCount, equals(3));
        expect(reptile.notes, equals('测试备注'));
        expect(reptile.createdAt, equals(DateTime(2023, 1, 1)));
        expect(reptile.updatedAt, equals(DateTime(2023, 1, 1)));
      });
    });

    group('Construction with minimal fields', () {
      test('should create Reptile with only required fields', () {
        final reptile = Reptile(
          id: 'minimal-id',
          name: 'Minimal Reptile',
          species: 'Minimal Species',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        expect(reptile.id, equals('minimal-id'));
        expect(reptile.name, equals('Minimal Reptile'));
        expect(reptile.species, equals('Minimal Species'));
        expect(reptile.speciesChinese, isNull);
        expect(reptile.gender, isNull);
        expect(reptile.birthDate, isNull);
        expect(reptile.weight, isNull);
        expect(reptile.length, isNull);
        expect(reptile.imagePath, isNull);
        expect(reptile.acquisitionDate, isNull);
        expect(reptile.acquisitionSource, isNull);
        expect(reptile.breedingStatus, isNull);
        expect(reptile.lastBreedingDate, isNull);
        expect(reptile.clutchCount, isNull);
        expect(reptile.notes, isNull);
        expect(reptile.createdAt, equals(DateTime(2023, 1, 1)));
        expect(reptile.updatedAt, equals(DateTime(2023, 1, 1)));
      });
    });

    group('copyWith', () {
      test('should create copy with all fields modified', () {
        final original = Reptile(
          id: 'original-id',
          name: 'Original',
          species: 'Original Species',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        final copy = original.copyWith(
          id: 'new-id',
          name: 'New Name',
          species: 'New Species',
          speciesChinese: '新物种',
          gender: 'female',
          birthDate: DateTime(2020, 1, 1),
          weight: 100.0,
          length: 15.0,
          imagePath: '/new/path.jpg',
          acquisitionDate: DateTime(2021, 1, 1),
          acquisitionSource: '赠送',
          breedingStatus: '繁殖中',
          lastBreedingDate: DateTime(2022, 1, 1),
          clutchCount: 5,
          notes: '新备注',
          createdAt: DateTime(2023, 2, 1),
          updatedAt: DateTime(2023, 2, 1),
        );

        expect(copy.id, equals('new-id'));
        expect(copy.name, equals('New Name'));
        expect(copy.species, equals('New Species'));
        expect(copy.speciesChinese, equals('新物种'));
        expect(copy.gender, equals('female'));
        expect(copy.birthDate, equals(DateTime(2020, 1, 1)));
        expect(copy.weight, equals(100.0));
        expect(copy.length, equals(15.0));
        expect(copy.imagePath, equals('/new/path.jpg'));
        expect(copy.acquisitionDate, equals(DateTime(2021, 1, 1)));
        expect(copy.acquisitionSource, equals('赠送'));
        expect(copy.breedingStatus, equals('繁殖中'));
        expect(copy.lastBreedingDate, equals(DateTime(2022, 1, 1)));
        expect(copy.clutchCount, equals(5));
        expect(copy.notes, equals('新备注'));
        expect(copy.createdAt, equals(DateTime(2023, 2, 1)));
        expect(copy.updatedAt, equals(DateTime(2023, 2, 1)));
      });

      test('should create copy with only one field modified', () {
        final original = Reptile(
          id: 'original-id',
          name: 'Original',
          species: 'Original Species',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        final copy = original.copyWith(name: 'Modified Name');

        expect(copy.id, equals('original-id'));
        expect(copy.name, equals('Modified Name'));
        expect(copy.species, equals('Original Species'));
        expect(copy.createdAt, equals(DateTime(2023, 1, 1)));
        expect(copy.updatedAt, equals(DateTime(2023, 1, 1)));
      });

      test('should not modify original when creating copy', () {
        final original = Reptile(
          id: 'original-id',
          name: 'Original',
          species: 'Original Species',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        original.copyWith(name: 'Modified Name');

        expect(original.name, equals('Original'));
      });

      test('should handle null values in copyWith', () {
        final original = Reptile(
          id: 'original-id',
          name: 'Original',
          species: 'Original Species',
          gender: 'male',
          notes: 'Original notes',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        final copy = original.copyWith(
          gender: null,
          notes: null,
        );

        expect(copy.gender, isNull);
        expect(copy.notes, isNull);
        expect(copy.name, equals('Original'));
        expect(copy.species, equals('Original Species'));
      });
    });
  });
}