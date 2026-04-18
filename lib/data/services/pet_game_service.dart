// 电子宠物游戏逻辑服务
// 包含实时状态衰减、经验值计算、进化检测、心情计算、成就检测等

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/electronic_pet.dart';
import '../models/pet_evolution.dart';
import '../models/pet_achievement.dart';
import '../models/pet_item.dart';

/// 电子宠物游戏管理器
class PetGameManager {
  static final PetGameManager _instance = PetGameManager._internal();
  factory PetGameManager() => _instance;
  PetGameManager._internal();

  // Storage keys
  static const String _keyPets = 'electronic_pets';
  static const String _keyCoins = 'pet_coins';  // 游戏金币

  List<ElectronicPet> _pets = [];
  int _coins = 1000;  // 初始金币
  bool _isInitialized = false;
  Timer? _decayTimer;

  List<ElectronicPet> get pets => _pets;
  int get coins => _coins;
  bool get isInitialized => _isInitialized;

  /// 初始化
  Future<void> init() async {
    if (_isInitialized) return;
    await _loadPets();
    await _loadCoins();
    _startDecayTimer();
    _isInitialized = true;
  }

  /// 启动状态衰减定时器（每分钟检查一次）
  void _startDecayTimer() {
    _decayTimer?.cancel();
    _decayTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _applyTimeDecay();
    });
  }

  /// 停止定时器
  void dispose() {
    _decayTimer?.cancel();
  }

  /// 加载宠物数据
  Future<void> _loadPets() async {
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString(_keyPets);
    if (petsJson != null && petsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(petsJson);
        _pets = decoded.map((json) => ElectronicPet.fromMap(json)).toList();
      } catch (e) {
        _pets = [];
      }
    }
  }

  /// 保存宠物数据
  Future<void> _savePets() async {
    final prefs = await SharedPreferences.getInstance();
    final petsJson = jsonEncode(_pets.map((pet) => pet.toMap()).toList());
    await prefs.setString(_keyPets, petsJson);
  }

  /// 加载金币
  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt(_keyCoins) ?? 1000;
  }

  /// 保存金币
  Future<void> _saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoins, _coins);
  }

  /// 添加金币
  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _saveCoins();
  }

  /// 消费金币
  Future<bool> spendCoins(int amount) async {
    if (_coins < amount) return false;
    _coins -= amount;
    await _saveCoins();
    return true;
  }

  /// 获取所有宠物
  List<ElectronicPet> getAllPets() => List.unmodifiable(_pets);

  /// 获取宠物数量
  int getPetCount() => _pets.length;

  /// 获取单个宠物
  ElectronicPet? getPet(String petId) {
    try {
      return _pets.firstWhere((p) => p.id == petId);
    } catch (e) {
      return null;
    }
  }

  /// 添加新宠物
  Future<ElectronicPet> addPet({
    required String speciesId,
    required String name,
    String? nickname,
    String gender = 'unknown',
  }) async {
    final pet = ElectronicPet.create(
      id: 'pet_${DateTime.now().millisecondsSinceEpoch}',
      speciesId: speciesId,
      name: name,
      nickname: nickname ?? '小$name',
      gender: gender,
    );
    _pets.add(pet);
    await _savePets();

    // 检查成就
    _checkAchievements(pet);

    return pet;
  }

  /// 删除宠物
  Future<void> deletePet(String petId) async {
    _pets.removeWhere((p) => p.id == petId);
    await _savePets();
  }

  /// 喂食
  Future<ElectronicPet?> feedPet(String petId, {String? foodItemId}) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index == -1) return null;

    var pet = _pets[index];
    final now = DateTime.now();

    // 计算经验加成
    int expGain = 5;  // 基础经验
    if (foodItemId != null) {
      final food = ItemData.getById(foodItemId);
      if (food != null) {
        expGain += food.effects[ItemEffectType.exp] ?? 0;
      }
    }

    // 更新宠物状态
    pet = pet.copyWith(
      hunger: 0,
      lastFed: now,
      happiness: (pet.happiness + 10).clamp(0, 100),
      healthScore: (pet.healthScore + 5).clamp(0, 100),
      totalFed: pet.totalFed + 1,
      experience: pet.experience + expGain,
      totalExperience: pet.totalExperience + expGain,
      appearance: PetAppearance.eating,
      updatedAt: now,
    );

    // 检查升级
    pet = _checkLevelUp(pet);

    // 检查心情
    pet = _updateMood(pet);

    _pets[index] = pet;
    await _savePets();

    // 检查成就
    _checkAchievements(pet);

    return pet;
  }

  /// 清洁
  Future<ElectronicPet?> cleanPet(String petId) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index == -1) return null;

    var pet = _pets[index];
    final now = DateTime.now();

    pet = pet.copyWith(
      cleanliness: 100,
      lastCleaned: now,
      healthScore: (pet.healthScore + 5).clamp(0, 100),
      totalCleaned: pet.totalCleaned + 1,
      experience: pet.experience + 3,
      totalExperience: pet.totalExperience + 3,
      updatedAt: now,
    );

    // 检查升级
    pet = _checkLevelUp(pet);

    // 检查心情
    pet = _updateMood(pet);

    _pets[index] = pet;
    await _savePets();

    // 检查成就
    _checkAchievements(pet);

    return pet;
  }

  /// 互动/玩耍
  Future<ElectronicPet?> playWithPet(String petId) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index == -1) return null;

    var pet = _pets[index];
    final now = DateTime.now();

    pet = pet.copyWith(
      happiness: (pet.happiness + 15).clamp(0, 100),
      lastPlayed: now,
      healthScore: (pet.healthScore + 2).clamp(0, 100),
      totalPlayed: pet.totalPlayed + 1,
      experience: pet.experience + 10,
      totalExperience: pet.totalExperience + 10,
      appearance: PetAppearance.playing,
      updatedAt: now,
    );

    // 检查升级
    pet = _checkLevelUp(pet);

    // 检查心情
    pet = _updateMood(pet);

    // 恢复外观状态
    Future.delayed(const Duration(seconds: 2), () {
      final idx = _pets.indexWhere((p) => p.id == petId);
      if (idx != -1) {
        _pets[idx] = _pets[idx].copyWith(appearance: PetAppearance.normal);
        _savePets();
      }
    });

    _pets[index] = pet;
    await _savePets();

    // 检查成就
    _checkAchievements(pet);

    return pet;
  }

  /// 使用道具
  Future<ElectronicPet?> useItem(String petId, String itemId) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index == -1) return null;

    var pet = _pets[index];
    final item = ItemData.getById(itemId);
    if (item == null) return null;

    // 检查是否有该道具
    if (!pet.inventoryItemIds.contains(itemId)) return null;

    final now = DateTime.now();
    int expGain = 0;

    // 应用道具效果
    int newHealth = pet.healthScore;
    int newHappiness = pet.happiness;
    int newHunger = pet.hunger;
    int newCleanliness = pet.cleanliness;
    PetMood newMood = pet.mood;

    for (final effect in item.effects.entries) {
      switch (effect.key) {
        case ItemEffectType.health:
          newHealth = (newHealth + effect.value).clamp(0, 100);
          break;
        case ItemEffectType.happiness:
          newHappiness = (newHappiness + effect.value).clamp(0, 100);
          break;
        case ItemEffectType.hunger:
          newHunger = (newHunger - effect.value).clamp(0, 100);
          break;
        case ItemEffectType.cleanliness:
          newCleanliness = (newCleanliness + effect.value).clamp(0, 100);
          break;
        case ItemEffectType.exp:
          expGain += effect.value;
          break;
        case ItemEffectType.mood:
          if (effect.value > 0) {
            newMood = PetMood.happy;
          }
          break;
      }
    }

    // 移除道具（数量-1，这里简化为直接移除ID）
    final newInventory = List<String>.from(pet.inventoryItemIds);
    newInventory.remove(itemId);

    pet = pet.copyWith(
      healthScore: newHealth,
      happiness: newHappiness,
      hunger: newHunger,
      cleanliness: newCleanliness,
      mood: newMood,
      inventoryItemIds: newInventory,
      experience: pet.experience + expGain,
      totalExperience: pet.totalExperience + expGain,
      updatedAt: now,
    );

    // 检查升级
    pet = _checkLevelUp(pet);

    // 检查心情
    pet = _updateMood(pet);

    _pets[index] = pet;
    await _savePets();

    // 检查成就
    _checkAchievements(pet);

    return pet;
  }

  /// 添加道具到背包
  Future<void> addItemToInventory(String petId, String itemId) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index == -1) return;

    var pet = _pets[index];
    final newInventory = List<String>.from(pet.inventoryItemIds);

    // 检查是否已有该道具
    if (!newInventory.contains(itemId)) {
      newInventory.add(itemId);
      pet = pet.copyWith(inventoryItemIds: newInventory);
      _pets[index] = pet;
      await _savePets();
    }
  }

  /// 检查升级
  ElectronicPet _checkLevelUp(ElectronicPet pet) {
    if (pet.level >= 50) return pet;  // 满级

    int expNeeded = pet.getExperienceToNextLevel();
    if (pet.experience >= expNeeded) {
      int newLevel = pet.level + 1;
      int remainingExp = pet.experience - expNeeded;

      return pet.copyWith(
        level: newLevel,
        experience: remainingExp,
      );
    }

    return pet;
  }

  /// 更新心情
  ElectronicPet _updateMood(ElectronicPet pet) {
    final now = DateTime.now();
    final hoursSinceFed = now.difference(pet.lastFed).inHours;
    final hoursSincePlayed = now.difference(pet.lastPlayed).inHours;
    final hoursSinceCleaned = now.difference(pet.lastCleaned).inHours;

    PetMood newMood;
    PetAppearance newAppearance;

    // 基于状态计算心情
    if (pet.healthScore < 30) {
      newMood = PetMood.sick;
      newAppearance = PetAppearance.sick;
    } else if (pet.hunger > 70) {
      newMood = PetMood.restless;
      newAppearance = PetAppearance.sad;
    } else if (hoursSincePlayed > 48) {
      newMood = PetMood.sad;
      newAppearance = PetAppearance.sad;
    } else if (pet.happiness > 80 && pet.hunger < 30 && pet.healthScore > 70) {
      newMood = PetMood.happy;
      newAppearance = PetAppearance.happy;
    } else if (pet.happiness > 50) {
      newMood = PetMood.normal;
      newAppearance = PetAppearance.normal;
    } else {
      newMood = PetMood.sad;
      newAppearance = PetAppearance.sad;
    }

    return pet.copyWith(
      mood: newMood,
      appearance: newAppearance,
      lastMoodUpdate: now,
    );
  }

  /// 应用时间衰减
  Future<void> _applyTimeDecay() async {
    final now = DateTime.now();
    bool hasChanges = false;

    for (int i = 0; i < _pets.length; i++) {
      var pet = _pets[i];

      final hoursSinceFed = now.difference(pet.lastFed).inHours;
      final hoursSincePlayed = now.difference(pet.lastPlayed).inHours;
      final hoursSinceCleaned = now.difference(pet.lastCleaned).inHours;

      // 计算衰减
      int hungerDecay = hoursSinceFed > 0 ? (hoursSinceFed * 2).clamp(0, 100) : 0;
      int happinessDecay = hoursSincePlayed > 24 ? ((hoursSincePlayed - 24) * 3).clamp(0, 100) : 0;
      int cleanlinessDecay = hoursSinceCleaned > 24 ? ((hoursSinceCleaned - 24) * 2).clamp(0, 100) : 0;

      int newHunger = (pet.hunger + hungerDecay).clamp(0, 100);
      int newHappiness = (pet.happiness - happinessDecay).clamp(0, 100);
      int newCleanliness = (pet.cleanliness - cleanlinessDecay).clamp(0, 100);

      // 健康度衰减
      int healthDecay = 0;
      if (newHunger > 80) healthDecay += 3;
      if (newCleanliness < 30) healthDecay += 2;
      if (pet.healthScore < 50) healthDecay += 1;

      int newHealth = (pet.healthScore - healthDecay).clamp(0, 100);

      // 计算存活天数
      final daysAlive = now.difference(pet.birthDate).inDays;

      // 计算连续健康天数
      int consecutiveHealthyDays = pet.consecutiveHealthyDays;
      if (newHealth >= 80) {
        consecutiveHealthyDays += 1;
      } else {
        consecutiveHealthyDays = 0;
      }

      // 状态良好时获得少量经验
      int expGain = 0;
      if (newHealth >= 80 && newHunger < 50 && newHappiness >= 50) {
        expGain = 1;
      }

      pet = pet.copyWith(
        hunger: newHunger,
        happiness: newHappiness,
        cleanliness: newCleanliness,
        healthScore: newHealth,
        daysAlive: daysAlive,
        consecutiveHealthyDays: consecutiveHealthyDays,
        experience: pet.experience + expGain,
        totalExperience: pet.totalExperience + expGain,
        updatedAt: now,
      );

      // 检查升级
      pet = _checkLevelUp(pet);

      // 更新心情
      pet = _updateMood(pet);

      _pets[i] = pet;
      hasChanges = true;
    }

    if (hasChanges) {
      await _savePets();
    }
  }

  /// 检查成就解锁
  Future<List<String>> _checkAchievements(ElectronicPet pet) async {
    final newlyUnlocked = AchievementData.checkAchievements(
      totalFed: pet.totalFed,
      totalPlayed: pet.totalPlayed,
      totalCleaned: pet.totalCleaned,
      level: pet.level,
      evolutionStage: pet.evolutionStage.index,
      daysAlive: pet.daysAlive,
      consecutiveHealthyDays: pet.consecutiveHealthyDays,
      healthScore: pet.healthScore,
      happiness: pet.happiness,
      unlockedAchievements: pet.unlockedAchievements,
    );

    if (newlyUnlocked.isNotEmpty) {
      // 添加已解锁成就
      final allUnlocked = List<String>.from(pet.unlockedAchievements)..addAll(newlyUnlocked);

      // 计算奖励经验
      int expReward = 0;
      for (final achievementId in newlyUnlocked) {
        final achievement = AchievementData.getById(achievementId);
        if (achievement != null) {
          expReward += achievement.expReward;
        }
      }

      final index = _pets.indexWhere((p) => p.id == pet.id);
      if (index != -1) {
        var updatedPet = pet.copyWith(
          unlockedAchievements: allUnlocked,
          experience: pet.experience + expReward,
          totalExperience: pet.totalExperience + expReward,
        );
        updatedPet = _checkLevelUp(updatedPet);
        _pets[index] = updatedPet;
        await _savePets();
      }
    }

    return newlyUnlocked;
  }

  /// 尝试进化
  Future<ElectronicPet?> tryEvolve(String petId) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index == -1) return null;

    var pet = _pets[index];
    final evolutionLine = PetEvolutionData.getEvolutionLine(pet.speciesId);

    if (evolutionLine == null) return null;
    if (!PetEvolutionData.canEvolve(pet, evolutionLine)) return null;

    final nextStage = PetEvolutionData.getNextStage(evolutionLine, pet.evolutionStage);
    if (nextStage == null) return null;

    // 消耗进化道具（如果有）
    var newInventory = List<String>.from(pet.inventoryItemIds);
    if (nextStage.requiredItemId != null) {
      newInventory.remove(nextStage.requiredItemId);
    }

    // 计算新的进化阶段
    EvolutionStage newEvolutionStage;
    switch (pet.evolutionStage) {
      case EvolutionStage.none:
        newEvolutionStage = EvolutionStage.first;
        break;
      case EvolutionStage.first:
        newEvolutionStage = EvolutionStage.second;
        break;
      case EvolutionStage.second:
        newEvolutionStage = EvolutionStage.ultimate;
        break;
      default:
        return null;
    }

    // 更新成长阶段
    GrowthStage newGrowthStage;
    if (newEvolutionStage == EvolutionStage.ultimate) {
      newGrowthStage = GrowthStage.adult;
    } else if (newEvolutionStage.index > pet.evolutionStage.index) {
      newGrowthStage = GrowthStage.subAdult;
    } else {
      newGrowthStage = pet.growthStage;
    }

    // 更新宠物
    final newName = nextStage.nextName ?? pet.name;
    pet = pet.copyWith(
      name: newName,
      evolutionStage: newEvolutionStage,
      growthStage: newGrowthStage,
      inventoryItemIds: newInventory,
      happiness: 100,
      experience: 0,  // 重置经验条
      updatedAt: DateTime.now(),
    );

    _pets[index] = pet;
    await _savePets();

    // 检查进化成就
    _checkAchievements(pet);

    return pet;
  }

  /// 购买道具
  Future<bool> purchaseItem(String itemId, {int quantity = 1}) async {
    final item = ItemData.getById(itemId);
    if (item == null || item.price <= 0) return false;

    final totalCost = item.price * quantity;
    if (_coins < totalCost) return false;

    // 简化处理：添加到第一只宠物的背包
    if (_pets.isEmpty) return false;

    for (int i = 0; i < quantity; i++) {
      await addItemToInventory(_pets.first.id, itemId);
    }

    await spendCoins(totalCost);
    return true;
  }

  /// 获取需要照顾的宠物（状态不佳）
  List<ElectronicPet> getNeedyPets() {
    return _pets.where((p) =>
      p.hunger > 50 ||
      p.happiness < 50 ||
      p.healthScore < 80 ||
      p.cleanliness < 50
    ).toList();
  }

  /// 获取所有成就（包括已解锁和未解锁）
  Map<Achievement, bool> getAllAchievementsWithStatus() {
    final result = <Achievement, bool>{};

    for (final achievement in AchievementData.getAllAchievements()) {
      bool unlocked = false;
      for (final pet in _pets) {
        if (pet.unlockedAchievements.contains(achievement.id)) {
          unlocked = true;
          break;
        }
      }
      result[achievement] = unlocked;
    }

    return result;
  }

  /// 获取宠物总数成就状态
  int getPetCountForAchievement() => _pets.length;

  /// 刷新宠物状态（手动触发）
  Future<void> refreshPetStatus() async {
    await _applyTimeDecay();
  }
}
