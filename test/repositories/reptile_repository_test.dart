import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/reptile.dart';
import 'package:wildherd/data/repositories/reptile_repository.dart';

void main() {
  late ReptileRepository repository;

  setUp(() {
    repository = ReptileRepository();
  });

  group('ReptileRepository', () {
    final testDate = DateTime(2024, 6, 15);

    test('starts empty', () async {
      final reptiles = await repository.getAllReptiles();
      expect(reptiles, isEmpty);
    });

    test('add and retrieve reptile', () async {
      final reptile = Reptile(
        id: 'rep-001',
        name: '小龟龟',
        species: '草龟',
        createdAt: testDate,
        updatedAt: testDate,
      );

      await repository.addReptile(reptile);
      final all = await repository.getAllReptiles();

      expect(all, hasLength(1));
      expect(all.first.id, 'rep-001');
      expect(all.first.name, '小龟龟');
    });

    test('get single reptile by id', () async {
      final reptile = Reptile(
        id: 'rep-002',
        name: '大蜥蜴',
        species: '鬃狮蜥',
        createdAt: testDate,
        updatedAt: testDate,
      );

      await repository.addReptile(reptile);
      final found = await repository.getReptile('rep-002');

      expect(found, isNotNull);
      expect(found!.name, '大蜥蜴');
    });

    test('getReptile returns null for non-existent id', () async {
      final found = await repository.getReptile('non-existent');
      expect(found, isNull);
    });

    test('update reptile', () async {
      final reptile = Reptile(
        id: 'rep-003',
        name: '原名称',
        species: '草龟',
        createdAt: testDate,
        updatedAt: testDate,
      );

      await repository.addReptile(reptile);

      final updated = reptile.copyWith(name: '新名称', updatedAt: DateTime.now());
      await repository.updateReptile(updated);

      final found = await repository.getReptile('rep-003');
      expect(found!.name, '新名称');
    });

    test('delete reptile', () async {
      final reptile = Reptile(
        id: 'rep-004',
        name: '待删除',
        species: '巴西龟',
        createdAt: testDate,
        updatedAt: testDate,
      );

      await repository.addReptile(reptile);
      expect(await repository.getAllReptiles(), hasLength(1));

      await repository.deleteReptile('rep-004');
      expect(await repository.getAllReptiles(), isEmpty);
    });

    test('add multiple reptiles', () async {
      for (var i = 0; i < 5; i++) {
        await repository.addReptile(Reptile(
          id: 'rep-$i',
          name: '爬宠$i',
          species: '物种$i',
          createdAt: testDate,
          updatedAt: testDate,
        ));
      }

      final all = await repository.getAllReptiles();
      expect(all, hasLength(5));
    });
  });
}
