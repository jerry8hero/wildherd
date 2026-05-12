import 'package:flutter_test/flutter_test.dart';
import 'package:wildherd/data/models/medical.dart';

void main() {
  group('Disease', () {
    test('creates with required fields', () {
      final disease = Disease(
        id: 'd-001',
        name: 'Respiratory Infection',
        nameZh: '呼吸道感染',
        category: 'respiratory',
        description: '常见呼吸道疾病',
        symptoms: ['张嘴呼吸', '流鼻涕', '嗜睡'],
        cause: '温度过低或湿度不当',
        treatment: '提高环境温度至30°C',
        prevention: '保持适宜温度和湿度',
      );

      expect(disease.id, 'd-001');
      expect(disease.nameZh, '呼吸道感染');
      expect(disease.symptoms, hasLength(3));
      expect(disease.isEmergency, isFalse);
    });

    test('fromMap / toMap round-trip', () {
      final original = Disease(
        id: 'd-010',
        name: 'Mouth Rot',
        nameZh: '口腔炎',
        category: 'oral',
        description: '口腔感染',
        symptoms: ['口腔溃疡', '流口水'],
        cause: '细菌感染',
        treatment: '抗生素治疗',
        prevention: '保持清洁',
        scientificName: 'Infectious stomatitis',
        isEmergency: true,
      );

      final map = original.toMap();
      expect(map['is_emergency'], 1);
      expect(map['symptoms'], contains('|'));

      final restored = Disease.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.nameZh, original.nameZh);
      expect(restored.symptoms, original.symptoms);
      expect(restored.isEmergency, isTrue);
      expect(restored.scientificName, original.scientificName);
    });

    test('categoryName maps correctly', () {
      final d = Disease(
        id: '', name: '', nameZh: '', category: 'respiratory',
        description: '', symptoms: [], cause: '', treatment: '', prevention: '',
      );
      expect(d.categoryName, '呼吸道疾病');
    });
  });

  group('Symptom', () {
    test('fromMap / toMap round-trip', () {
      final original = Symptom(
        id: 's-001',
        name: 'Lethargy',
        nameZh: '嗜睡',
        category: 'behavior',
        description: '活动减少',
        relatedDiseaseIds: ['d-001', 'd-002'],
      );

      final restored = Symptom.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.nameZh, original.nameZh);
      expect(restored.relatedDiseaseIds, original.relatedDiseaseIds);
    });
  });

  group('EmergencyGuide', () {
    test('fromMap / toMap round-trip', () {
      final original = EmergencyGuide(
        id: 'eg-001',
        title: 'Bleeding',
        titleZh: '出血急救',
        content: '用干净纱布按压止血',
        category: 'injury',
        priority: 1,
      );

      final restored = EmergencyGuide.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.titleZh, original.titleZh);
      expect(restored.priority, original.priority);
    });
  });

  group('Medication', () {
    test('fromMap / toMap round-trip', () {
      final original = Medication(
        id: 'm-001',
        name: 'Baytril',
        nameZh: '拜有利',
        category: 'antibiotic',
        indications: '细菌感染',
        dosage: '5-10mg/kg',
        sideEffects: '食欲下降',
        notes: '需遵医嘱',
      );

      final restored = Medication.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.nameZh, original.nameZh);
      expect(restored.indications, original.indications);
      expect(restored.dosage, original.dosage);
    });
  });
}
