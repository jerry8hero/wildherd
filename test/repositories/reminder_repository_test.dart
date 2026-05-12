import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/feeding_reminder.dart';
import 'package:wildherd/data/repositories/reminder_repository.dart';

void main() {
  late ReminderRepository repository;

  setUp(() {
    repository = ReminderRepository();
  });

  group('ReminderRepository', () {
    final testCreated = DateTime(2024, 6, 15, 10, 0);

    test('starts empty', () async {
      final reminders = await repository.getAllReminders();
      expect(reminders, isEmpty);
    });

    test('add and retrieve reminder', () async {
      final reminder = FeedingReminder(
        id: 'fr-001',
        reptileId: 'rep-001',
        reptileName: '小龟龟',
        foodType: '小白鼠',
        intervalDays: 5,
        feedTimeHour: 9,
        feedTimeMinute: 0,
        enabled: true,
        createdAt: testCreated,
      );

      await repository.addReminder(reminder);
      final all = await repository.getAllReminders();

      expect(all, hasLength(1));
      expect(all.first.reptileName, '小龟龟');
      expect(all.first.foodType, '小白鼠');
    });

    test('get reminders for specific reptile', () async {
      await repository.addReminder(FeedingReminder(
        id: 'fr-001',
        reptileId: 'rep-001',
        reptileName: '小龟龟',
        foodType: '小白鼠',
        intervalDays: 5,
        feedTimeHour: 9,
        feedTimeMinute: 0,
        createdAt: testCreated,
      ));
      await repository.addReminder(FeedingReminder(
        id: 'fr-002',
        reptileId: 'rep-002',
        reptileName: '大蜥蜴',
        foodType: '蟋蟀',
        intervalDays: 3,
        feedTimeHour: 10,
        feedTimeMinute: 30,
        createdAt: testCreated,
      ));

      final rep1Reminders = await repository.getRemindersForReptile('rep-001');
      expect(rep1Reminders, hasLength(1));
      expect(rep1Reminders.first.reptileName, '小龟龟');
    });

    test('update reminder (upsert)', () async {
      final original = FeedingReminder(
        id: 'fr-010',
        reptileId: 'rep-001',
        reptileName: '小龟龟',
        foodType: '小白鼠',
        intervalDays: 5,
        feedTimeHour: 9,
        feedTimeMinute: 0,
        enabled: true,
        createdAt: testCreated,
      );

      await repository.addReminder(original);

      final updated = original.copyWith(enabled: false);
      await repository.updateReminder(updated);

      final all = await repository.getAllReminders();
      expect(all, hasLength(1));
      expect(all.first.enabled, isFalse);
    });

    test('delete reminder', () async {
      await repository.addReminder(FeedingReminder(
        id: 'fr-020',
        reptileId: 'rep-001',
        reptileName: '小龟龟',
        foodType: '小白鼠',
        intervalDays: 5,
        feedTimeHour: 9,
        feedTimeMinute: 0,
        createdAt: testCreated,
      ));

      await repository.deleteReminder('fr-020');
      final all = await repository.getAllReminders();
      expect(all, isEmpty);
    });

    test('add multiple reminders', () async {
      for (var i = 0; i < 3; i++) {
        await repository.addReminder(FeedingReminder(
          id: 'fr-$i',
          reptileId: 'rep-001',
          reptileName: '爬宠$i',
          foodType: '食物$i',
          intervalDays: i + 1,
          feedTimeHour: 9 + i,
          feedTimeMinute: 0,
          createdAt: testCreated,
        ));
      }

      final all = await repository.getAllReminders();
      expect(all, hasLength(3));
    });
  });
}
