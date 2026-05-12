import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/feeding_reminder.dart';

void main() {
  final testCreated = DateTime(2024, 6, 15, 10, 30);
  final testTriggered = DateTime(2024, 6, 20, 9, 0);

  group('FeedingReminder', () {
    test('creates with all fields', () {
      final reminder = FeedingReminder(
        id: 'fr-001',
        reptileId: 'rep-001',
        reptileName: '小龟龟',
        foodType: '小白鼠',
        intervalDays: 5,
        feedTimeHour: 9,
        feedTimeMinute: 30,
        enabled: true,
        lastTriggered: testTriggered,
        createdAt: testCreated,
      );

      expect(reminder.id, 'fr-001');
      expect(reminder.reptileId, 'rep-001');
      expect(reminder.reptileName, '小龟龟');
      expect(reminder.foodType, '小白鼠');
      expect(reminder.intervalDays, 5);
      expect(reminder.feedTimeHour, 9);
      expect(reminder.feedTimeMinute, 30);
      expect(reminder.enabled, isTrue);
      expect(reminder.lastTriggered, testTriggered);
      expect(reminder.createdAt, testCreated);
    });

    test('default enabled is true', () {
      final reminder = FeedingReminder(
        id: 'fr-002',
        reptileId: 'rep-001',
        reptileName: '大蜥蜴',
        foodType: '蟋蟀',
        intervalDays: 3,
        feedTimeHour: 10,
        feedTimeMinute: 0,
        createdAt: testCreated,
      );

      expect(reminder.enabled, isTrue);
      expect(reminder.lastTriggered, isNull);
    });

    group('fromMap', () {
      test('parses enabled from int', () {
        final map = {
          'id': 'fr-001',
          'reptile_id': 'rep-001',
          'reptile_name': '小龟龟',
          'food_type': '小白鼠',
          'interval_days': 5,
          'feed_time_hour': 9,
          'feed_time_minute': 30,
          'enabled': 1,
          'last_triggered': testTriggered.toIso8601String(),
          'created_at': testCreated.toIso8601String(),
        };

        final reminder = FeedingReminder.fromMap(map);
        expect(reminder.enabled, isTrue);
      });

      test('parses disabled from int 0', () {
        final map = {
          'id': 'fr-002',
          'reptile_id': 'rep-002',
          'reptile_name': '大蜥蜴',
          'food_type': '蟋蟀',
          'interval_days': 3,
          'feed_time_hour': 10,
          'feed_time_minute': 0,
          'enabled': 0,
          'last_triggered': null,
          'created_at': testCreated.toIso8601String(),
        };

        final reminder = FeedingReminder.fromMap(map);
        expect(reminder.enabled, isFalse);
        expect(reminder.lastTriggered, isNull);
      });
    });

    group('toMap', () {
      test('serializes enabled as int', () {
        final reminder = FeedingReminder(
          id: 'fr-001',
          reptileId: 'rep-001',
          reptileName: '小龟龟',
          foodType: '小白鼠',
          intervalDays: 5,
          feedTimeHour: 9,
          feedTimeMinute: 30,
          enabled: true,
          createdAt: testCreated,
        );

        final map = reminder.toMap();
        expect(map['enabled'], 1);
      });

      test('serializes disabled as 0', () {
        final reminder = FeedingReminder(
          id: 'fr-002',
          reptileId: 'rep-002',
          reptileName: '大蜥蜴',
          foodType: '蟋蟀',
          intervalDays: 3,
          feedTimeHour: 10,
          feedTimeMinute: 0,
          enabled: false,
          createdAt: testCreated,
        );

        final map = reminder.toMap();
        expect(map['enabled'], 0);
      });

      test('round-trip preserves data', () {
        final original = FeedingReminder(
          id: 'fr-100',
          reptileId: 'rep-010',
          reptileName: '龟龟',
          foodType: '大麦虫',
          intervalDays: 7,
          feedTimeHour: 14,
          feedTimeMinute: 30,
          enabled: true,
          lastTriggered: testTriggered,
          createdAt: testCreated,
        );

        final roundTripped = FeedingReminder.fromMap(original.toMap());

        expect(roundTripped.id, original.id);
        expect(roundTripped.reptileId, original.reptileId);
        expect(roundTripped.reptileName, original.reptileName);
        expect(roundTripped.foodType, original.foodType);
        expect(roundTripped.intervalDays, original.intervalDays);
        expect(roundTripped.feedTimeHour, original.feedTimeHour);
        expect(roundTripped.feedTimeMinute, original.feedTimeMinute);
        expect(roundTripped.enabled, original.enabled);
        expect(roundTripped.lastTriggered, original.lastTriggered);
        expect(roundTripped.createdAt, original.createdAt);
      });
    });

    group('copyWith', () {
      test('updates enabled', () {
        final original = FeedingReminder(
          id: 'fr-001',
          reptileId: 'rep-001',
          reptileName: '小龟龟',
          foodType: '小白鼠',
          intervalDays: 5,
          feedTimeHour: 9,
          feedTimeMinute: 30,
          enabled: true,
          createdAt: testCreated,
        );

        final updated = original.copyWith(enabled: false);
        expect(updated.enabled, isFalse);
        expect(updated.id, original.id);
        expect(updated.foodType, original.foodType);
      });

      test('updates lastTriggered', () {
        final original = FeedingReminder(
          id: 'fr-001',
          reptileId: 'rep-001',
          reptileName: '小龟龟',
          foodType: '小白鼠',
          intervalDays: 5,
          feedTimeHour: 9,
          feedTimeMinute: 30,
          createdAt: testCreated,
        );

        final updated = original.copyWith(lastTriggered: testTriggered);
        expect(updated.lastTriggered, testTriggered);
        expect(original.lastTriggered, isNull);
      });
    });
  });
}
