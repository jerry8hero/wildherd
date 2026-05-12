import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/breeding.dart';

void main() {
  final testDate = DateTime(2024, 6, 15);

  group('BreedingBatch', () {
    test('creates with required fields', () {
      final batch = BreedingBatch(
        id: 'bb-001',
        reptileId: 'rep-001',
        maleId: 'rep-002',
        femaleId: 'rep-003',
        matingDate: testDate,
        createdAt: testDate,
      );

      expect(batch.id, 'bb-001');
      expect(batch.reptileId, 'rep-001');
      expect(batch.status, 'mating');
    });

    test('fromMap / toMap round-trip', () {
      final original = BreedingBatch(
        id: 'bb-010',
        reptileId: 'rep-010',
        maleId: 'rep-011',
        femaleId: 'rep-012',
        matingDate: testDate,
        eggLayingDate: testDate,
        expectedHatchDate: testDate.add(const Duration(days: 60)),
        eggCount: 8,
        fertileCount: 6,
        hatchedCount: 5,
        status: 'hatched',
        notes: '顺利孵化',
        createdAt: testDate,
      );

      final restored = BreedingBatch.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.eggCount, 8);
      expect(restored.fertileCount, 6);
      expect(restored.hatchedCount, 5);
      expect(restored.status, 'hatched');
    });
  });

  group('BreedingEgg', () {
    test('fromMap / toMap round-trip', () {
      final original = BreedingEgg(
        id: 'be-001',
        batchId: 'bb-001',
        eggNumber: 1,
        isFertile: true,
        candlingResult: '正常发育',
        hatchStatus: 'hatched',
        hatchDate: testDate,
        createdAt: testDate,
      );

      final map = original.toMap();
      expect(map['is_fertile'], 1);
      expect(map['hatch_status'], 'hatched');

      final restored = BreedingEgg.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.isFertile, isTrue);
      expect(restored.hatchStatus, 'hatched');
    });
  });

  group('Offspring', () {
    test('fromMap / toMap round-trip', () {
      final original = Offspring(
        id: 'of-001',
        batchId: 'bb-001',
        name: '宝宝一号',
        gender: 'male',
        status: 'healthy',
        createdAt: testDate,
      );

      final restored = Offspring.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.name, '宝宝一号');
      expect(restored.gender, 'male');
    });
  });
}
