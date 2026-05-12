import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/habitat.dart';

void main() {
  final testDate = DateTime(2024, 6, 15);

  group('HabitatEnvironment', () {
    test('creates with required fields', () {
      final env = HabitatEnvironment(
        id: 'env-001',
        reptileId: 'rep-001',
        reptileName: '小龟龟',
        speciesId: 'sp-001',
        temperature: 28.0,
        humidity: 65.0,
        createdAt: testDate,
      );

      expect(env.temperature, 28.0);
      expect(env.humidity, 65.0);
      expect(env.uvIndex, isNull);
      expect(env.substrate, isNull);
    });

    test('fromMap / toMap round-trip', () {
      final original = HabitatEnvironment(
        id: 'env-010',
        reptileId: 'rep-010',
        reptileName: '蜥蜴',
        speciesId: 'sp-010',
        temperature: 30.0,
        humidity: 70.0,
        uvIndex: 3.0,
        substrate: '椰土',
        lighting: 'UVB 5.0',
        tankSize: 60.0,
        heating: '加热灯',
        ventilation: '良好',
        createdAt: testDate,
        updatedAt: testDate,
      );

      final restored = HabitatEnvironment.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.reptileId, original.reptileId);
      expect(restored.temperature, original.temperature);
      expect(restored.uvIndex, original.uvIndex);
      expect(restored.substrate, original.substrate);
      expect(restored.tankSize, original.tankSize);
    });
  });

  group('HabitatStandard', () {
    test('fromMap / toMap round-trip', () {
      final original = HabitatStandard(
        speciesId: 'sp-001',
        minTemp: 25.0,
        maxTemp: 32.0,
        idealTemp: 28.0,
        minHumidity: 50.0,
        maxHumidity: 70.0,
        suitableSubstrates: ['椰土', '树皮'],
        lightingNeed: 'UVB 5.0',
        minTankSize: 40,
        idealHumidity: 60.0,
        idealUV: 3.0,
      );

      final restored = HabitatStandard.fromMap(original.toMap());

      expect(restored.speciesId, original.speciesId);
      expect(restored.minTemp, original.minTemp);
      expect(restored.suitableSubstrates, original.suitableSubstrates);
      expect(restored.minTankSize, original.minTankSize);
      expect(restored.idealHumidity, original.idealHumidity);
    });
  });

  group('HabitatScore', () {
    test('creates with required fields', () {
      final score = HabitatScore(
        temperatureScore: 90,
        humidityScore: 80,
        uvScore: 70,
        spaceScore: 85,
        overallScore: 81.25,
        suggestions: [],
      );

      expect(score.overallScore, 81.25);
      expect(score.suggestions, isEmpty);
    });
  });

  group('SubstrateOption', () {
    test('SubstrateOptions.all is not empty', () {
      expect(SubstrateOptions.all, isNotEmpty);
    });
  });

  group('LightingOption', () {
    test('LightingOptions.all is not empty', () {
      expect(LightingOptions.all, isNotEmpty);
    });
  });
}
