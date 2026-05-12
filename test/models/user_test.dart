import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/user.dart';

void main() {
  group('User', () {
    test('creates with required fields', () {
      final user = User(id: 'u-001', name: '爬友小明');

      expect(user.id, 'u-001');
      expect(user.name, '爬友小明');
      expect(user.avatarUrl, isNull);
      expect(user.level, UserLevel.beginner);
    });

    test('creates with all fields', () {
      final user = User(
        id: 'u-002',
        name: '资深玩家',
        avatarUrl: 'https://example.com/avatar.jpg',
        level: UserLevel.advanced,
      );

      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.level, UserLevel.advanced);
    });

    group('copyWith', () {
      test('updates single field', () {
        final original = User(id: 'u-001', name: '小明');
        final updated = original.copyWith(name: '小红');

        expect(updated.name, '小红');
        expect(updated.id, 'u-001');
        expect(original.name, '小明');
      });

      test('updates level', () {
        final original = User(id: 'u-001', name: '小明', level: UserLevel.beginner);
        final updated = original.copyWith(level: UserLevel.intermediate);

        expect(updated.level, UserLevel.intermediate);
        expect(original.level, UserLevel.beginner);
      });
    });
  });

  group('UserLevel', () {
    test('beginner displayName', () {
      expect(UserLevel.beginner.displayName, '新手');
    });

    test('intermediate displayName', () {
      expect(UserLevel.intermediate.displayName, '进阶');
    });

    test('advanced displayName', () {
      expect(UserLevel.advanced.displayName, '资深');
    });

    test('difficulty ranges', () {
      expect(UserLevel.beginner.difficultyRange, [1, 2]);
      expect(UserLevel.intermediate.difficultyRange, [2, 3]);
      expect(UserLevel.advanced.difficultyRange, [4, 5]);
    });

    test('difficulty labels', () {
      expect(UserLevel.beginner.difficultyLabel, '入门级');
      expect(UserLevel.intermediate.difficultyLabel, '进阶级');
      expect(UserLevel.advanced.difficultyLabel, '专业级');
    });
  });
}
