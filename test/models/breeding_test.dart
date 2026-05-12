import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/breeding.dart';

void main() {
  final testDate = DateTime(2024, 6, 15);

  group('BreedingBatch', () {
    test('creates with required fields', () {
      final batch = BreedingBatch(
        id: 'bb-001',
        reptileId: 'rep-001',
        fatherId: 'rep-002',
        reptileName: 'Test Reptile',
        species: 'Test Species',
        matingDate: testDate,
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(batch.id, 'bb-001');
      expect(batch.reptileId, 'rep-001');
      expect(batch.fatherId, 'rep-002');
    });

    test('fromMap / toMap round-trip', () {
      final original = BreedingBatch(
        id: 'bb-010',
        reptileId: 'rep-010',
        fatherId: 'rep-011',
        reptileName: 'Test Reptile',
        species: 'Test Species',
        matingDate: testDate,
        eggLayingDate: testDate,
        expectedHatchDate: testDate.add(const Duration(days: 60)),
        eggCount: 8,
        hatchedCount: 5,
        status: 'hatched',
        notes: '顺利孵化',
        createdAt: testDate,
        updatedAt: testDate,
      );

      final restored = BreedingBatch.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.eggCount, 8);
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
        fertility: 'fertile',
        candlingResult: '正常发育',
        hatchStatus: 'hatched',
        hatchDate: testDate,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final map = original.toMap();
      expect(map['fertility'], 'fertile');
      expect(map['hatch_status'], 'hatched');

      final restored = BreedingEgg.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.fertility, 'fertile');
      expect(restored.hatchStatus, 'hatched');
    });
  });

  group('Offspring', () {
    test('fromMap / toMap round-trip', () {
      final original = Offspring(
        id: 'of-001',
        parentBatchId: 'bb-001',
        name: '宝宝一号',
        species: 'Test Species',
        gender: 'male',
        status: 'alive',
        createdAt: testDate,
        updatedAt: testDate,
      );

      final restored = Offspring.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.name, '宝宝一号');
      expect(restored.gender, 'male');
    });
  });
}