// 医疗健康数据模型

// 疾病模型
class Disease {
  final String id;
  final String name;
  final String nameZh;
  final String? scientificName;
  final String category; // respiratory, digestive, skin, parasitic, metabolic, etc.
  final String? speciesId; // 关联的物种ID
  final String? speciesCategory; // 物种分类 (snake, lizard, turtle, gecko, amphibian, arachnid)
  final String description; // 疾病描述
  final List<String> symptoms; // 症状列表
  final String cause; // 病因
  final String treatment; // 治疗方案
  final String prevention; // 预防措施
  final bool isEmergency; // 是否紧急
  final String? relatedSpecies; // 关联物种名称

  Disease({
    required this.id,
    required this.name,
    required this.nameZh,
    this.scientificName,
    required this.category,
    this.speciesId,
    this.speciesCategory,
    required this.description,
    required this.symptoms,
    required this.cause,
    required this.treatment,
    required this.prevention,
    this.isEmergency = false,
    this.relatedSpecies,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_zh': nameZh,
      'scientific_name': scientificName,
      'category': category,
      'species_id': speciesId,
      'species_category': speciesCategory,
      'description': description,
      'symptoms': symptoms.join('|'),
      'cause': cause,
      'treatment': treatment,
      'prevention': prevention,
      'is_emergency': isEmergency ? 1 : 0,
      'related_species': relatedSpecies,
    };
  }

  factory Disease.fromMap(Map<String, dynamic> map) {
    return Disease(
      id: map['id'],
      name: map['name'],
      nameZh: map['name_zh'],
      scientificName: map['scientific_name'],
      category: map['category'],
      speciesId: map['species_id'],
      speciesCategory: map['species_category'],
      description: map['description'],
      symptoms: map['symptoms'] != null && map['symptoms'].toString().isNotEmpty
          ? map['symptoms'].toString().split('|')
          : [],
      cause: map['cause'],
      treatment: map['treatment'],
      prevention: map['prevention'],
      isEmergency: map['is_emergency'] == 1,
      relatedSpecies: map['related_species'],
    );
  }

  String get categoryName {
    switch (category) {
      case 'respiratory':
        return '呼吸道疾病';
      case 'digestive':
        return '消化系统疾病';
      case 'skin':
        return '皮肤疾病';
      case 'parasitic':
        return '寄生虫感染';
      case 'metabolic':
        return '代谢性疾病';
      case 'infectious':
        return '传染性疾病';
      case 'nutritional':
        return '营养性疾病';
      case 'injury':
        return '外伤';
      case 'other':
        return '其他';
      default:
        return category;
    }
  }
}

// 症状模型（用于症状检查器）
class Symptom {
  final String id;
  final String name;
  final String nameZh;
  final String category; // behavioral, physical, respiratory, digestive, skin, etc.
  final String? description;
  final List<String> relatedDiseaseIds;

  Symptom({
    required this.id,
    required this.name,
    required this.nameZh,
    required this.category,
    this.description,
    this.relatedDiseaseIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_zh': nameZh,
      'category': category,
      'description': description,
      'related_disease_ids': relatedDiseaseIds.join(','),
    };
  }

  factory Symptom.fromMap(Map<String, dynamic> map) {
    return Symptom(
      id: map['id'],
      name: map['name'],
      nameZh: map['name_zh'],
      category: map['category'],
      description: map['description'],
      relatedDiseaseIds: map['related_disease_ids'] != null &&
              map['related_disease_ids'].toString().isNotEmpty
          ? map['related_disease_ids'].toString().split(',')
          : [],
    );
  }
}

// 紧急情况处理指南
class EmergencyGuide {
  final String id;
  final String title;
  final String titleZh;
  final String content;
  final String category; // bleeding, poisoning, seizure, trauma, heat_stroke, etc.
  final int priority;

  EmergencyGuide({
    required this.id,
    required this.title,
    required this.titleZh,
    required this.content,
    required this.category,
    this.priority = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'title_zh': titleZh,
      'content': content,
      'category': category,
      'priority': priority,
    };
  }

  factory EmergencyGuide.fromMap(Map<String, dynamic> map) {
    return EmergencyGuide(
      id: map['id'],
      title: map['title'],
      titleZh: map['title_zh'],
      content: map['content'],
      category: map['category'],
      priority: map['priority'] ?? 0,
    );
  }
}

// 常见用药指南
class Medication {
  final String id;
  final String name;
  final String nameZh;
  final String? indications; // 适应症
  final String? dosage; // 剂量
  final String? sideEffects; // 副作用
  final String? notes; // 注意事项
  final String category;

  Medication({
    required this.id,
    required this.name,
    required this.nameZh,
    this.indications,
    this.dosage,
    this.sideEffects,
    this.notes,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_zh': nameZh,
      'indications': indications,
      'dosage': dosage,
      'side_effects': sideEffects,
      'notes': notes,
      'category': category,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      name: map['name'],
      nameZh: map['name_zh'],
      indications: map['indications'],
      dosage: map['dosage'],
      sideEffects: map['side_effects'],
      notes: map['notes'],
      category: map['category'],
    );
  }
}
