import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/record.dart';
import 'package:wildherd/data/repositories/record_repository.dart';

void main() {
  late RecordRepository repository;

  setUp(() {
    repository = RecordRepository();
  });

  group('RecordRepository - FeedingRecord', () {
    final testDate = DateTime(2024, 6, 15);

    test('add and retrieve feeding record', () async {
      final record = FeedingRecord(
        id: 'feed-001',
        reptileId: 'rep-001',
        foodType: '小白鼠',
        feedingTime: testDate,
        notes: '吃得很好',
        createdAt: testDate,
      );

      await repository.addFeedingRecord(record);
      final records = await repository.getFeedingRecords('rep-001');

      expect(records, hasLength(1));
      expect(records.first.foodType, '小白鼠');
    });

    test('filters by reptileId', () async {
      await repository.addFeedingRecord(FeedingRecord(
        id: 'feed-001',
        reptileId: 'rep-001',
        foodType: '小白鼠',
        feedingTime: testDate,
        createdAt: testDate,
      ));
      await repository.addFeedingRecord(FeedingRecord(
        id: 'feed-002',
        reptileId: 'rep-002',
        foodType: '蟋蟀',
        feedingTime: testDate,
        createdAt: testDate,
      ));

      final rep1 = await repository.getFeedingRecords('rep-001');
      expect(rep1, hasLength(1));
      expect(rep1.first.foodType, '小白鼠');
    });

    test('delete feeding record', () async {
      await repository.addFeedingRecord(FeedingRecord(
        id: 'feed-010',
        reptileId: 'rep-001',
        foodType: '大麦虫',
        feedingTime: testDate,
        createdAt: testDate,
      ));

      await repository.deleteFeedingRecord('feed-010');
      final records = await repository.getFeedingRecords('rep-001');
      expect(records, isEmpty);
    });
  });

  group('RecordRepository - HealthRecord', () {
    final testDate = DateTime(2024, 6, 15);

    test('add and retrieve health record', () async {
      final record = HealthRecord(
        id: 'health-001',
        reptileId: 'rep-001',
        recordDate: testDate,
        weight: 150.5,
        length: 20.3,
        status: 'healthy',
        createdAt: testDate,
      );

      await repository.addHealthRecord(record);
      final records = await repository.getHealthRecords('rep-001');

      expect(records, hasLength(1));
      expect(records.first.weight, 150.5);
    });

    test('delete health record', () async {
      await repository.addHealthRecord(HealthRecord(
        id: 'health-010',
        reptileId: 'rep-001',
        recordDate: testDate,
        createdAt: testDate,
      ));

      await repository.deleteHealthRecord('health-010');
      final records = await repository.getHealthRecords('rep-001');
      expect(records, isEmpty);
    });
  });

  group('RecordRepository - GrowthPhoto', () {
    final testDate = DateTime(2024, 6, 15);

    test('add and retrieve growth photo', () async {
      final photo = GrowthPhoto(
        id: 'gp-001',
        reptileId: 'rep-001',
        photoDate: testDate,
        imagePath: '/path/to/photo.jpg',
        description: '成长记录',
        createdAt: testDate,
      );

      await repository.addGrowthPhoto(photo);
      final photos = await repository.getGrowthPhotos('rep-001');

      expect(photos, hasLength(1));
      expect(photos.first.imagePath, '/path/to/photo.jpg');
    });

    test('delete growth photo', () async {
      await repository.addGrowthPhoto(GrowthPhoto(
        id: 'gp-010',
        reptileId: 'rep-001',
        photoDate: testDate,
        imagePath: '/test.jpg',
        createdAt: testDate,
      ));

      await repository.deleteGrowthPhoto('gp-010');
      final photos = await repository.getGrowthPhotos('rep-001');
      expect(photos, isEmpty);
    });
  });
}
