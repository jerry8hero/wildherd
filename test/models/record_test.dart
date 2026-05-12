import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/record.dart';

void main() {
  group('Record Models', () {
    group('FeedingRecord', () {
      group('Construction', () {
        test('should create FeedingRecord with all fields populated', () {
          final record = FeedingRecord(
            id: 'feeding-id-123',
            reptileId: 'reptile-id-456',
            feedingTime: DateTime(2023, 5, 15),
            foodType: '蟋蟀',
            foodAmount: 10.5,
            notes: '吃得很香',
            createdAt: DateTime(2023, 5, 15),
          );

          expect(record.id, 'feeding-id-123');
          expect(record.reptileId, 'reptile-id-456');
          expect(record.foodType, '蟋蟀');
          expect(record.foodAmount, 10.5);
          expect(record.notes, '吃得很香');
        });

        test('should create FeedingRecord with required fields only', () {
          final record = FeedingRecord(
            id: 'feeding-id-789',
            reptileId: 'reptile-id-101',
            feedingTime: DateTime(2023, 5, 15),
            foodType: '面包虫',
            createdAt: DateTime(2023, 5, 15),
          );

          expect(record.id, 'feeding-id-789');
          expect(record.reptileId, 'reptile-id-101');
          expect(record.foodAmount, isNull);
          expect(record.notes, isNull);
        });
      });

      group('toMap', () {
        test('should serialize all fields', () {
          final record = FeedingRecord(
            id: 'feeding-id-123',
            reptileId: 'reptile-id-456',
            feedingTime: DateTime(2023, 5, 15, 10, 30),
            foodType: '蟋蟀',
            foodAmount: 10.5,
            notes: '吃得很香',
            createdAt: DateTime(2023, 5, 15, 10, 30),
          );

          final map = record.toMap();

          expect(map['id'], 'feeding-id-123');
          expect(map['reptile_id'], 'reptile-id-456');
          expect(map['food_type'], '蟋蟀');
          expect(map['food_amount'], 10.5);
          expect(map['notes'], '吃得很香');
        });
      });

      group('fromMap', () {
        test('should deserialize all fields', () {
          final map = {
            'id': 'feeding-id-123',
            'reptile_id': 'reptile-id-456',
            'feeding_time': '2023-05-15T10:30:00.000',
            'food_type': '蟋蟀',
            'food_amount': 10.5,
            'notes': '吃得很香',
            'created_at': '2023-05-15T10:30:00.000',
          };

          final record = FeedingRecord.fromMap(map);

          expect(record.id, 'feeding-id-123');
          expect(record.reptileId, 'reptile-id-456');
          expect(record.foodType, '蟋蟀');
          expect(record.foodAmount, 10.5);
          expect(record.notes, '吃得很香');
        });

        test('should handle null optional fields', () {
          final map = {
            'id': 'feeding-id-123',
            'reptile_id': 'reptile-id-456',
            'feeding_time': '2023-05-15T10:30:00.000',
            'food_type': '蟋蟀',
            'food_amount': null,
            'notes': null,
            'created_at': '2023-05-15T10:30:00.000',
          };

          final record = FeedingRecord.fromMap(map);

          expect(record.foodAmount, isNull);
          expect(record.notes, isNull);
        });
      });
    });

    group('HealthRecord', () {
      test('should create with all fields', () {
        final record = HealthRecord(
          id: 'health-id-123',
          reptileId: 'reptile-id-456',
          recordDate: DateTime(2023, 5, 15),
          weight: 150.5,
          length: 45.0,
          status: 'normal',
          defecation: 'normal',
          notes: '状态良好',
          createdAt: DateTime(2023, 5, 15),
        );

        expect(record.id, 'health-id-123');
        expect(record.weight, 150.5);
        expect(record.length, 45.0);
      });

      test('should create with required fields only', () {
        final record = HealthRecord(
          id: 'health-id-789',
          reptileId: 'reptile-id-101',
          recordDate: DateTime(2023, 5, 15),
          createdAt: DateTime(2023, 5, 15),
        );

        expect(record.weight, isNull);
        expect(record.status, isNull);
      });

      test('toMap / fromMap round-trip', () {
        final original = HealthRecord(
          id: 'health-id-123',
          reptileId: 'reptile-id-456',
          recordDate: DateTime(2023, 5, 15, 10, 30),
          weight: 150.5,
          length: 45.0,
          status: 'normal',
          defecation: 'normal',
          notes: '状态良好',
          createdAt: DateTime(2023, 5, 15, 10, 30),
        );

        final restored = HealthRecord.fromMap(original.toMap());

        expect(restored.id, original.id);
        expect(restored.weight, original.weight);
        expect(restored.length, original.length);
      });
    });

    group('GrowthPhoto', () {
      test('should create with all fields', () {
        final record = GrowthPhoto(
          id: 'photo-id-123',
          reptileId: 'reptile-id-456',
          imagePath: '/path/to/photo.jpg',
          description: '可爱的小龟',
          photoDate: DateTime(2023, 5, 15),
          createdAt: DateTime(2023, 5, 15),
        );

        expect(record.id, 'photo-id-123');
        expect(record.imagePath, '/path/to/photo.jpg');
        expect(record.description, '可爱的小龟');
      });

      test('toMap / fromMap round-trip', () {
        final original = GrowthPhoto(
          id: 'photo-id-123',
          reptileId: 'reptile-id-456',
          imagePath: '/path/to/photo.jpg',
          description: '可爱的小龟',
          photoDate: DateTime(2023, 5, 15, 10, 30),
          createdAt: DateTime(2023, 5, 15, 10, 30),
        );

        final restored = GrowthPhoto.fromMap(original.toMap());

        expect(restored.id, original.id);
        expect(restored.imagePath, original.imagePath);
        expect(restored.description, original.description);
      });
    });
  });
}