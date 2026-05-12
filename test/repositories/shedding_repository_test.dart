import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/shedding_record.dart';
import 'package:wildherd/data/repositories/shedding_repository.dart';

void main() {
  late SheddingRepository repository;

  setUp(() {
    repository = SheddingRepository();
  });

  group('SheddingRepository', () {
    final testDate = DateTime(2024, 6, 15);
    final testCreated = DateTime(2024, 6, 15, 10, 0);

    test('starts empty', () async {
      final records = await repository.getSheddingRecords('rep-001');
      expect(records, isEmpty);
    });

    test('add and retrieve shedding record', () async {
      final record = SheddingRecord(
        id: 'shed-001',
        reptileId: 'rep-001',
        shedDate: testDate,
        completeness: 'complete',
        notes: '完美蜕皮',
        createdAt: testCreated,
      );

      await repository.addSheddingRecord(record);
      final records = await repository.getSheddingRecords('rep-001');

      expect(records, hasLength(1));
      expect(records.first.completeness, 'complete');
      expect(records.first.notes, '完美蜕皮');
    });

    test('filters by reptileId', () async {
      await repository.addSheddingRecord(SheddingRecord(
        id: 'shed-001',
        reptileId: 'rep-001',
        shedDate: testDate,
        completeness: 'complete',
        createdAt: testCreated,
      ));
      await repository.addSheddingRecord(SheddingRecord(
        id: 'shed-002',
        reptileId: 'rep-002',
        shedDate: testDate,
        completeness: 'partial',
        createdAt: testCreated,
      ));

      final rep1 = await repository.getSheddingRecords('rep-001');
      expect(rep1, hasLength(1));
      expect(rep1.first.completeness, 'complete');

      final rep2 = await repository.getSheddingRecords('rep-002');
      expect(rep2, hasLength(1));
      expect(rep2.first.completeness, 'partial');
    });

    test('delete shedding record', () async {
      await repository.addSheddingRecord(SheddingRecord(
        id: 'shed-010',
        reptileId: 'rep-001',
        shedDate: testDate,
        completeness: 'stuck',
        notes: '尾部卡皮',
        createdAt: testCreated,
      ));

      await repository.deleteSheddingRecord('shed-010');
      final records = await repository.getSheddingRecords('rep-001');
      expect(records, isEmpty);
    });

    test('multiple records for same reptile', () async {
      for (var i = 0; i < 3; i++) {
        await repository.addSheddingRecord(SheddingRecord(
          id: 'shed-$i',
          reptileId: 'rep-001',
          shedDate: testDate.subtract(Duration(days: i * 30)),
          completeness: i == 2 ? 'partial' : 'complete',
          createdAt: testCreated,
        ));
      }

      final records = await repository.getSheddingRecords('rep-001');
      expect(records, hasLength(3));
    });
  });
}
