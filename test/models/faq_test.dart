import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/faq.dart';

void main() {
  final testDate = DateTime(2024, 6, 15);

  group('FAQ', () {
    test('creates with required fields', () {
      final faq = FAQ(
        id: 'faq-001',
        question: '乌龟多久喂一次？',
        answer: '一般3-5天喂一次',
        categoryId: 'feeding',
        createdAt: testDate,
      );

      expect(faq.id, 'faq-001');
      expect(faq.question, '乌龟多久喂一次？');
      expect(faq.keywords, isEmpty);
      expect(faq.viewCount, 0);
      expect(faq.helpfulCount, 0);
    });

    test('fromMap / toMap round-trip', () {
      final original = FAQ(
        id: 'faq-010',
        question: '蜥蜴蜕皮怎么办？',
        answer: '保持湿度',
        categoryId: 'shedding',
        speciesId: 'sp-001',
        keywords: ['蜕皮', '蜥蜴'],
        viewCount: 50,
        helpfulCount: 30,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final restored = FAQ.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.question, original.question);
      expect(restored.answer, original.answer);
      expect(restored.categoryId, original.categoryId);
      expect(restored.speciesId, original.speciesId);
      expect(restored.keywords, original.keywords);
      expect(restored.viewCount, original.viewCount);
      expect(restored.helpfulCount, original.helpfulCount);
    });
  });
}
