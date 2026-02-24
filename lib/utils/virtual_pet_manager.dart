import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/virtual_pet.dart';

/// 虚拟宠物管理器
class VirtualPetManager {
  static final VirtualPetManager _instance = VirtualPetManager._internal();
  factory VirtualPetManager() => _instance;
  VirtualPetManager._internal();

  // Storage keys
  static const String _keyPets = 'virtual_pets';
  // ignore: unused_field
  static const String _keyActivities = 'pet_activities';
  // ignore: unused_field
  static const String _keyDiaries = 'pet_diaries';

  List<VirtualPet> _pets = [];
  bool _isInitialized = false;

  /// 初始化
  Future<void> init() async {
    if (_isInitialized) return;
    await _loadPets();
    _isInitialized = true;
  }

  /// 加载宠物数据
  Future<void> _loadPets() async {
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString(_keyPets);
    if (petsJson != null) {
      // 解析宠物数据
      // 这里简化处理，实际项目可能需要更复杂的解析
      _pets = [];
    }
  }

  /// 保存宠物数据
  Future<void> _savePets() async {
    // 保存到 SharedPreferences
    // TODO: 实现完整的保存逻辑
  }

  /// 获取所有虚拟宠物
  List<VirtualPet> getAllPets() {
    return List.unmodifiable(_pets);
  }

  /// 获取宠物数量
  int getPetCount() => _pets.length;

  /// 添加虚拟宠物
  Future<void> addPet(VirtualPet pet) async {
    _pets.add(pet);
    await _savePets();
  }

  /// 更新虚拟宠物
  Future<void> updatePet(VirtualPet pet) async {
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      _pets[index] = pet;
      await _savePets();
    }
  }

  /// 删除虚拟宠物
  Future<void> deletePet(String petId) async {
    _pets.removeWhere((p) => p.id == petId);
    await _savePets();
  }

  /// 获取单个宠物
  VirtualPet? getPet(String petId) {
    try {
      return _pets.firstWhere((p) => p.id == petId);
    } catch (e) {
      return null;
    }
  }

  /// 喂食
  Future<void> feedPet(String petId) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      final pet = _pets[index];
      _pets[index] = pet.copyWith(
        hunger: 0,
        lastFed: DateTime.now(),
        happiness: (pet.happiness + 5).clamp(0, 100),
        healthScore: (pet.healthScore + 2).clamp(0, 100),
        updatedAt: DateTime.now(),
      );
      await _savePets();
    }
  }

  /// 清洁
  Future<void> cleanPet(String petId) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      final pet = _pets[index];
      _pets[index] = pet.copyWith(
        lastCleaned: DateTime.now(),
        healthScore: (pet.healthScore + 3).clamp(0, 100),
        updatedAt: DateTime.now(),
      );
      await _savePets();
    }
  }

  /// 互动/玩耍
  Future<void> playWithPet(String petId) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      final pet = _pets[index];
      _pets[index] = pet.copyWith(
        happiness: (pet.happiness + 10).clamp(0, 100),
        lastPlayed: DateTime.now(),
        healthScore: (pet.healthScore + 1).clamp(0, 100),
        updatedAt: DateTime.now(),
      );
      await _savePets();
    }
  }

  /// 更新宠物状态（随时间变化）
  Future<void> updatePetStatus() async {
    final now = DateTime.now();
    for (var i = 0; i < _pets.length; i++) {
      final pet = _pets[i];
      var hunger = pet.hunger;
      var happiness = pet.happiness;
      var healthScore = pet.healthScore;

      // 计算时间差（小时）
      final hoursSinceLastFed = now.difference(pet.lastFed).inHours;
      final hoursSinceLastPlayed = now.difference(pet.lastPlayed).inHours;
      final hoursSinceLastCleaned = now.difference(pet.lastCleaned).inHours;

      // 饥饿度增加
      if (hoursSinceLastFed > 0) {
        hunger = (hunger + hoursSinceLastFed * 2).clamp(0, 100);
      }

      // 快乐度变化
      if (hoursSinceLastPlayed > 24) {
        happiness = (happiness - 5).clamp(0, 100);
      }

      // 健康度变化（基于饥饿和不清洁）
      if (hunger > 80) {
        healthScore = (healthScore - 3).clamp(0, 100);
      }
      if (hoursSinceLastCleaned > 48) {
        healthScore = (healthScore - 2).clamp(0, 100);
      }

      _pets[i] = pet.copyWith(
        hunger: hunger,
        happiness: happiness,
        healthScore: healthScore,
        updatedAt: now,
      );
    }
    await _savePets();
  }

  /// 记录活动
  // TODO: 实现活动记录功能
  Future<void> recordActivity(String petId, String activityType, {String? notes}) async {
    // 保存活动记录
  }

  /// 获取活动历史
  Future<List<PetActivity>> getActivities(String petId, {int limit = 10}) async {
    // TODO: 从存储中获取活动记录
    return [];
  }

  /// 写日记
  // TODO: 实现日记功能
  Future<void> writeDiary(String petId, String title, String content) async {
    // 保存日记
  }

  /// 获取日记
  Future<List<PetDiary>> getDiaries(String petId) async {
    // 从存储中获取日记
    return [];
  }

  /// 获取所有需要照顾的宠物（状态不佳）
  List<VirtualPet> getNeedyPets() {
    return _pets.where((p) =>
      p.hunger > 50 || p.happiness < 50 || p.healthScore < 80
    ).toList();
  }

  /// 获取平均健康度
  double getAverageHealth() {
    if (_pets.isEmpty) return 0;
    final total = _pets.fold(0, (sum, p) => sum + p.healthScore);
    return total / _pets.length;
  }
}
