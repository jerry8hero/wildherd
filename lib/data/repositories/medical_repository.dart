import '../local/database_helper.dart';
import '../models/medical.dart';

class MedicalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 初始化医疗数据
  Future<void> initData() async {
    await _dbHelper.initMedicalData();
  }

  // 获取所有疾病
  Future<List<Disease>> getAllDiseases() async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.query('diseases', orderBy: 'name_zh ASC');
    return result.map((map) => Disease.fromMap(map)).toList();
  }

  // 按物种分类获取疾病
  Future<List<Disease>> getDiseasesBySpecies(String speciesCategory) async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.query('diseases');
    final filtered = result.where((map) {
      final category = (map['species_category'] ?? '').toString();
      return category == speciesCategory || speciesCategory == 'all';
    }).toList();
    return filtered.map((map) => Disease.fromMap(map)).toList();
  }

  // 按类别获取疾病
  Future<List<Disease>> getDiseasesByCategory(String category) async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.queryWhere(
      'diseases',
      where: 'category = ?',
      whereArgs: [category],
    );
    return result.map((map) => Disease.fromMap(map)).toList();
  }

  // 获取疾病详情
  Future<Disease?> getDiseaseDetail(String id) async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.queryWhere(
      'diseases',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Disease.fromMap(result.first);
  }

  // 搜索疾病
  Future<List<Disease>> searchDiseases(String keyword) async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.query('diseases');
    final kw = keyword.toLowerCase();
    final filtered = result.where((map) {
      final name = (map['name_zh'] ?? '').toString().toLowerCase();
      final nameEn = (map['name'] ?? '').toString().toLowerCase();
      final description = (map['description'] ?? '').toString().toLowerCase();
      return name.contains(kw) || nameEn.contains(kw) || description.contains(kw);
    }).toList();
    return filtered.map((map) => Disease.fromMap(map)).toList();
  }

  // 获取所有症状
  Future<List<Symptom>> getAllSymptoms() async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.query('symptoms', orderBy: 'name_zh ASC');
    return result.map((map) => Symptom.fromMap(map)).toList();
  }

  // 按症状查找可能疾病
  Future<List<Disease>> findDiseasesBySymptoms(List<String> symptomIds) async {
    await _dbHelper.initMedicalData();
    final allDiseases = await getAllDiseases();
    final matchedDiseases = <Disease>[];

    for (var disease in allDiseases) {
      final diseaseSymptomIds = disease.symptoms
          .map((s) => s.toLowerCase())
          .toList();

      int matchCount = 0;
      for (var symptomId in symptomIds) {
        if (diseaseSymptomIds.any((ds) => ds.contains(symptomId.toLowerCase()))) {
          matchCount++;
        }
      }
      if (matchCount > 0) {
        matchedDiseases.add(disease);
      }
    }

    return matchedDiseases;
  }

  // 获取紧急情况指南
  Future<List<EmergencyGuide>> getEmergencyGuides() async {
    await _dbHelper.initMedicalData();
    final result = await _dbHelper.query('emergency_guides', orderBy: 'priority ASC');
    return result.map((map) => EmergencyGuide.fromMap(map)).toList();
  }
}
