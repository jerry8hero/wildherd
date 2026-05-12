import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/article.dart';

void main() {
  final testDate = DateTime(2024, 6, 15);

  group('Article', () {
    test('creates with required fields', () {
      final article = Article(
        id: 'a-001',
        title: '龟类入门指南',
        summary: '新手养龟必看',
        content: '正文内容...',
        category: 'care',
        author: '管理员',
        createdAt: testDate,
      );

      expect(article.id, 'a-001');
      expect(article.title, '龟类入门指南');
      expect(article.category, 'care');
      expect(article.readCount, 0);
      expect(article.tags, isEmpty);
      expect(article.isFeatured, isFalse);
      expect(article.difficulty, 1);
    });

    test('creates with all fields', () {
      final article = Article(
        id: 'a-002',
        title: '进阶饲养',
        summary: '摘要',
        content: '内容',
        category: 'breeding',
        author: '专家',
        imageUrl: 'https://example.com/img.jpg',
        readCount: 100,
        tags: ['龟', '饲养'],
        isFeatured: true,
        createdAt: testDate,
        updatedAt: testDate,
        categoryId: 'cat-001',
        difficulty: 3,
        readTimeMinutes: 10,
        relatedSpeciesIds: ['sp-001'],
      );

      expect(article.imageUrl, isNotNull);
      expect(article.readCount, 100);
      expect(article.tags, ['龟', '饲养']);
      expect(article.isFeatured, isTrue);
      expect(article.difficulty, 3);
    });

    group('fromMap / toMap round-trip', () {
      test('preserves all fields', () {
        final original = Article(
          id: 'a-010',
          title: '测试文章',
          summary: '摘要',
          content: '内容',
          category: 'health',
          author: '测试',
          readCount: 42,
          tags: ['标签A', '标签B'],
          isFeatured: true,
          createdAt: testDate,
          updatedAt: testDate,
          categoryId: 'cat-01',
          difficulty: 2,
        );

        final map = original.toMap();
        final restored = Article.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.category, original.category);
        expect(restored.readCount, original.readCount);
        expect(restored.tags, original.tags);
        expect(restored.isFeatured, original.isFeatured);
        expect(restored.difficulty, original.difficulty);
      });

      test('serializes boolean as int', () {
        final article = Article(
          id: 'a-011',
          title: '精选',
          summary: '',
          content: '',
          category: 'care',
          author: '',
          isFeatured: true,
          createdAt: testDate,
        );

        expect(article.toMap()['is_featured'], 1);

        final disabled = article.copyWith(isFeatured: false);
        expect(disabled.toMap()['is_featured'], 0);
      });
    });

    group('categoryName', () {
      test('maps category to Chinese', () {
        expect(Article(id: '', title: '', summary: '', content: '', category: 'care', author: '', createdAt: testDate).categoryName, '饲养护理');
        expect(Article(id: '', title: '', summary: '', content: '', category: 'health', author: '', createdAt: testDate).categoryName, '健康医疗');
        expect(Article(id: '', title: '', summary: '', content: '', category: 'breeding', author: '', createdAt: testDate).categoryName, '繁殖孵化');
      });
    });
  });
}
