import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/qa.dart';

void main() {
  final testDate = DateTime(2024, 6, 15);

  group('Question', () {
    test('creates with required fields', () {
      final q = Question(
        id: 'q-001',
        title: '龟不吃东西怎么办？',
        content: '我的草龟三天没吃东西了',
        userId: 'u-001',
        userName: '小明',
        createdAt: testDate,
      );

      expect(q.id, 'q-001');
      expect(q.tags, isEmpty);
      expect(q.viewCount, 0);
      expect(q.answerCount, 0);
      expect(q.isResolved, isFalse);
    });

    test('fromMap / toMap round-trip', () {
      final original = Question(
        id: 'q-010',
        title: '蜥蜴蜕皮异常',
        content: '蜕皮不完整',
        userId: 'u-001',
        userName: '小红',
        userAvatar: 'https://example.com/avatar.jpg',
        speciesId: 'sp-001',
        speciesName: '豹纹守宫',
        tags: ['蜕皮', '守宫'],
        viewCount: 100,
        answerCount: 3,
        isResolved: true,
        acceptedAnswerId: 'a-001',
        createdAt: testDate,
        updatedAt: testDate,
      );

      final map = original.toMap();
      expect(map['is_resolved'], 1);
      expect(map['tags'], '蜕皮,守宫');

      final restored = Question.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.tags, original.tags);
      expect(restored.isResolved, isTrue);
      expect(restored.acceptedAnswerId, 'a-001');
    });
  });

  group('Answer', () {
    test('fromMap / toMap round-trip', () {
      final original = Answer(
        id: 'a-010',
        questionId: 'q-001',
        userId: 'u-002',
        userName: '专家',
        content: '提高湿度试试',
        likes: 5,
        isAccepted: true,
        createdAt: testDate,
      );

      final map = original.toMap();
      expect(map['is_accepted'], 1);

      final restored = Answer.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.questionId, original.questionId);
      expect(restored.isAccepted, isTrue);
      expect(restored.likes, original.likes);
    });
  });

  group('QATag', () {
    test('fromMap / toMap round-trip', () {
      final original = QATag(
        id: 't-001',
        name: 'shedding',
        nameZh: '蜕皮',
        questionCount: 42,
      );

      final restored = QATag.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.nameZh, '蜕皮');
      expect(restored.questionCount, 42);
    });
  });
}
