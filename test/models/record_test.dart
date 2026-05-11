import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/lib/data/models/record.dart';

void main() {
  group('Record Models', () {
    group('FeedingRecord', () {
      group('Construction', () {
        test('should create FeedingRecord with all fields populated', () {
          final record = FeedingRecord(
            id: 'feeding-id-123',
            reptileId: 'reptile-id-456',
            feedingTime: DateTime(2023, 5, 15, 10, 30),
            foodType: 'crickets',
            foodAmount: 5.0,
            notes: ' feeding completed',
            createdAt: DateTime(2023, 5, 15, 10, 35),
          );

          expect(record.id, equals('feeding-id-123'));
          expect(record.reptileId, equals('reptile-id-456'));
          expect(record.feedingTime, equals(DateTime(2023, 5, 15, 10, 30)));
          expect(record.foodType, equals('crickets'));
          expect(record.foodAmount, equals(5.0));
          expect(record.notes, equals(' feeding completed'));
          expect(record.createdAt, equals(DateTime(2023, 5, 15, 10, 35)));
        });

        test('should create FeedingRecord with minimal required fields', () {
          final record = FeedingRecord(
            id: 'minimal-feeding',
            reptileId: 'reptile-id',
            feedingTime: DateTime(2023, 5, 15),
            foodType: 'food',
            createdAt: DateTime(2023, 5, 15),
          );

          expect(record.id, equals('minimal-feeding'));
          expect(record.reptileId, equals('reptile-id'));
          expect(record.feedingTime, equals(DateTime(2023, 5, 15)));
          expect(record.foodType, equals('food'));
          expect(record.foodAmount, isNull);
          expect(record.notes, isNull);
          expect(record.createdAt, equals(DateTime(2023, 5, 15)));
        });
      });

      group('Field validation', () {
        test('should require id field', () {
          expect(
            () => FeedingRecord(
              id: '',
              reptileId: 'reptile-id',
              feedingTime: DateTime(2023, 5, 15),
              foodType: 'food',
              createdAt: DateTime(2023, 5, 15),
            ),
            throwsA(isA<TypeError>()),
          );
        });

        test('should require reptileId field', () {
          expect(
            () => FeedingRecord(
              id: 'feeding-id',
              reptileId: null,
              feedingTime: DateTime(2023, 5, 15),
              foodType: 'food',
              createdAt: DateTime(2023, 5, 15),
            ),
            throwsA(isA<TypeError>()),
          );
        });

        test('should require feedingTime field', () {
          expect(
            () => FeedingRecord(
              id: 'feeding-id',
              reptileId: 'reptile-id',
              feedingTime: null,
              foodType: 'food',
              createdAt: DateTime(2023, 5, 15),
            ),
            throwsA(isA<TypeError>()),
          );
        });

        test('should require foodType field', () {
          expect(
            () => FeedingRecord(
              id: 'feeding-id',
              reptileId: 'reptile-id',
              feedingTime: DateTime(2023, 5, 15),
              foodType: null,
              createdAt: DateTime(2023, 5, 15),
            ),
            throwsA(isA<TypeError>()),
          );
        });

        test('should require createdAt field', () {
          expect(
            () => FeedingRecord(
              id: 'feeding-id',
              reptileId: 'reptile-id',
              feedingTime: DateTime(2023, 5, 15),
              foodType: 'food',
              createdAt: null,
            ),
            throwsA(isA<TypeError>()),
          );
        });
      });
    });

    group('HealthRecord', () {
      group('Construction', () {
        test('should create HealthRecord with all fields populated', () {
          final record = HealthRecord(
            id: 'health-id-123',
            reptileId: 'reptile-id-456',
            recordDate: DateTime(2023, 5, 15),
            weight: 150.5,
            length: 20.3,
            status: 'normal',
            defecation: 'normal',
            notes: 'Health check completed',
            createdAt: DateTime(2023, 5, 15, 11, 0),
          );

          expect(record.id, equals('health-id-123'));
          expect(record.reptileId, equals('reptile-id-456'));
          expect(record.recordDate, equals(DateTime(2023, 5, 15)));
          expect(record.weight, equals(150.5));
          expect(record.length, equals(20.3));
          expect(record.status, equals('normal'));
          expect(record.defecation, equals('normal'));
          expect(record.notes, equals('Health check completed'));
          expect(record.createdAt, equals(DateTime(2023, 5, 15, 11, 0)));
        });

        test('should create HealthRecord with minimal required fields', () {
          final record = HealthRecord(
            id: 'minimal-health',
            reptileId: 'reptile-id',
            recordDate: DateTime(2023, 5, 15),
            createdAt: DateTime(2023, 5, 15),
          );

          expect(record.id, equals('minimal-health'));
          expect(record.reptileId, equals('reptile-id'));
          expect(record.recordDate, equals(DateTime(2023, 5, 15)));
          expect(record.weight, isNull);
          expect(record.length, isNull);
          expect(record.status, isNull);
          expect(record.defecation, isNull);
          expect(record.notes, isNull);
          expect(record.createdAt, equals(DateTime(2023, 5, 15)));
        });
      });

      group('Field validation', () {
        test('should require id field', () {
          expect(
            () => HealthRecord(
              id: '',
              reptileId: 'reptile-id',
              recordDate: DateTime(2023, 5, 15),
              createdAt: DateTime(2023, 5, 15),
            ),
            throwsA(isA<TypeError>()),
          );
        });

        test('should require reptileId field', () {
          expect(
            () => HealthRecord(
              id: 'health-id',
              reptileId: null,
              recordDate: DateTime(2023, 5, 15),
              createdAt: DateTime(2023, 5, 15),
            ),
            throwsA(isA<TypeError>()),
          );
        });

        test('should require recordDate field', () {
          expect(
            () => HealthRecord(
              id: 'health-id',
              reptileId: 'reptile-id',
              recordDate: null,
              createdAt: DateTime(2023, 5, 15),
            ),
            throwsA(isA<TypeError>()),
          );
        });

        test('should require createdAt field', () {
          expect(
            () => HealthRecord(
              id: 'health-id',
              reptileId: 'reptile-id',
              recordDate: DateTime(2023, 5, 15),
              createdAt: null,
            ),
            throwsA(isA<TypeError>()),
          );
        });
      });
    });

    group('GrowthPhoto', () {
      group('Construction', () {
        test('should create GrowthPhoto with all fields populated', () {
          final photo = GrowthPhoto(
            id: 'photo-id-123',
            reptileId: 'reptile-id-456',
            imagePath: '/path/to/photo.jpg',
            description: 'Growth milestone',
            photoDate: DateTime(2023, 5, 15),
            createdAt: DateTime(2023, 5, 15, 12, 0),
          );

          expect(photo.id, equals('photo-id-123'));
          expect(photo.reptileId, equals('reptile-id-456'));
          expect(photo.imagePath, equals('/path/to/photo.jpg'));
          expect(photo.description, equals('Growth milestone'));
          expect(photo.photoDate, equals(DateTime(2023, 5, 15)));
          expect(photo.createdAt, equals(DateTime(2023, 5, 15, 12, 0)));
        });

        test('should create GrowthPhoto with minimal required fields', () {
          final photo = GrowthPhoto(
            id: 'minimal-photo',
            reptileId: 'reptile-id',
            imagePath: '/path/to/photo.jpg',
            photoDate: DateTime(2023, 5, 15),
            createdAt: DateTime(2023, 5, 15),
          );

          expect(photo.id, equals('minimal-photo'));
          expect(photo.reptileId, equals('reptile-id'));
          expect(photo.imagePath, equals('/path/to/photo.jpg'));
          expect(photo.description, isNull);
          expect(photo.photoDate, equals(DateTime(2023, 5, 15)));
          expect(photo.createdAt, equals(DateTime(2023, 5, 15)));
        });
      });

      group('Field validation', () {
        test('should require id field', () {
          expect(
            () => GrowthPhoto(
              id: '',
              reptileId: 'reptile-id',
              imagePath: '/path/to/photo.jpg',
              photoDate: DateTime(2023, 5, 15),
              createdAt: DateTime(2023, 5, 15),
            ),
            throwsA(isA<TypeError>()),
          );
        });

        test('should require reptileId field', () {
          expect(
            () => GrowthPhoto(
              id: 'photo-id',
              reptileId: null,
              imagePath: '/path/to/photo.jpg',
              photoDate: DateTime(2023, 5, 15),
              createdAt: DateTime(2023, 5, 15),
            ),
            throwsA(isA<TypeError>()),
          );
        });

        test('should require imagePath field', () {
          expect(
            () => GrowthPhoto(
              id: 'photo-id',
              reptileId: 'reptile-id',
              imagePath: null,
              photoDate: DateTime(2023, 5, 15),
              createdAt: DateTime(2023, 5, 15),
            ),
            throwsA(isA<TypeError>()),
          );
        });

        test('should require photoDate field', () {
          expect(
            () => GrowthPhoto(
              id: 'photo-id',
              reptileId: 'reptile-id',
              imagePath: '/path/to/photo.jpg',
              photoDate: null,
              createdAt: DateTime(2023, 5, 15),
            ),
            throwsA(isA<TypeError>()),
          );
        });

        test('should require createdAt field', () {
          expect(
            () => GrowthPhoto(
              id: 'photo-id',
              reptileId: 'reptile-id',
              imagePath: '/path/to/photo.jpg',
              photoDate: DateTime(2023, 5, 15),
              createdAt: null,
            ),
            throwsA(isA<TypeError>()),
          );
        });
      });
    });
  });
}