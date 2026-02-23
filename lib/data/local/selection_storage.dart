import 'dart:convert';
import '../models/selection.dart';

class SelectionStorage {
  static List<CandidatePet> _cached = [];

  // 获取所有候选宠物
  static List<CandidatePet> getAll() {
    return List.from(_cached);
  }

  // 获取某个物种的候选宠物
  static List<CandidatePet> getBySpecies(String speciesId) {
    return _cached.where((p) => p.speciesId == speciesId).toList();
  }

  // 添加候选宠物
  static void add(CandidatePet pet) {
    _cached.add(pet);
    _save();
  }

  // 更新候选宠物
  static void update(CandidatePet pet) {
    final index = _cached.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      _cached[index] = pet;
      _save();
    }
  }

  // 删除候选宠物
  static void delete(String id) {
    _cached.removeWhere((p) => p.id == id);
    _save();
  }

  // 清空某个物种的所有候选
  static void clearBySpecies(String speciesId) {
    _cached.removeWhere((p) => p.speciesId == speciesId);
    _save();
  }

  // 清空所有
  static void clearAll() {
    _cached.clear();
    _save();
  }

  // 保存到本地存储（使用SharedPreferences）
  static Future<void> _save() async {
    // 由于当前应用使用简单的内存存储，这里简化处理
    // 实际项目中应该使用SharedPreferences或数据库持久化
  }

  // 从JSON加载
  static void loadFromJson(String json) {
    if (json.isEmpty) return;
    try {
      final List<dynamic> list = jsonDecode(json);
      _cached = list.map((item) => CandidatePet.fromMap(item)).toList();
    } catch (e) {
      _cached = [];
    }
  }

  // 转换为JSON
  static String toJson() {
    return jsonEncode(_cached.map((p) => p.toMap()).toList());
  }
}
