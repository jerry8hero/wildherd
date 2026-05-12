import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/shedding_record.dart';

void main() {
  final testDate = DateTime(2024, 6, 15);
  final testCreated = DateTime(2024, 6, 15, 10, 30);

  group('SheddingRecord', () {
    test('creates with all fields', () {
      final record = SheddingRecord(
        id: 'sr-001',
        reptileId: 'rep-001',
        shedDate: testDate,
        completeness: 'complete',
        notes: '完美蜕皮',
        createdAt: testCreated,
      );

      expect(record.id, 'sr-001');
      expect(record.reptileId, 'rep-001');
      expect(record.shedDate, testDate);
      expect(record.completeness, 'complete');
      expect(record.notes, '完美蜕皮');
      expect(record.createdAt, testCreated);
    });

    test('creates without optional notes', () {
      final record = SheddingRecord(
        id: 'sr-002',
        reptileId: 'rep-001',
        shedDate: testDate,
        completeness: 'partial',
        createdAt: testCreated,
      );

      expect(record.notes, isNull);
    });

    group('fromMap', () {
      test('creates from map with all fields', () {
        final map = {
          'id': 'sr-001',
          'reptile_id': 'rep-001',
          'shed_date': testDate.toIso8601String(),
          'completeness': 'stuck',
          'notes': '尾部卡皮',
          'created_at': testCreated.toIso8601String(),
        };

        final record = SheddingRecord.fromMap(map);

        expect(record.id, 'sr-001');
        expect(record.reptileId, 'rep-001');
        expect(record.completeness, 'stuck');
        expect(record.notes, '尾部卡皮');
      });

      test('handles null notes', () {
        final map = {
          'id': 'sr-003',
          'reptile_id': 'rep-001',
          'shed_date': testDate.toIso8601String(),
          'completeness': 'complete',
          'notes': null,
          'created_at': testCreated.toIso8601String(),
        };

        final record = SheddingRecord.fromMap(map);
        expect(record.notes, isNull);
      });
    });

    group('toMap', () {
      test('serializes to map correctly', () {
        final record = SheddingRecord(
          id: 'sr-001',
          reptileId: 'rep-001',
          shedDate: testDate,
          completeness: 'complete',
          notes: '很好',
          createdAt: testCreated,
        );

        final map = record.toMap();

        expect(map['id'], 'sr-001');
        expect(map['reptile_id'], 'rep-001');
        expect(map['completeness'], 'complete');
        expect(map['notes'], '很好');
      });

      test('round-trip preserves data', () {
        final original = SheddingRecord(
          id: 'sr-010',
          reptileId: 'rep-005',
          shedDate: testDate,
          completeness: 'partial',
          notes: '头部蜕皮不完整',
          createdAt: testCreated,
        );

        final roundTripped = SheddingRecord.fromMap(original.toMap());

        expect(roundTripped.id, original.id);
        expect(roundTripped.reptileId, original.reptileId);
        expect(roundTripped.shedDate, original.shedDate);
        expect(roundTripped.completeness, original.completeness);
        expect(roundTripped.notes, original.notes);
        expect(roundTripped.createdAt, original.createdAt);
      });
    });
  });
}
