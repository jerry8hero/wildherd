import '../local/database_helper.dart';
import '../models/breeding.dart';

class BreedingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== 繁殖批次 ====================

  /// 获取所有繁殖批次
  Future<List<BreedingBatch>> getAllBatches() async {
    final result = await _dbHelper.query(
      'breeding_batches',
      orderBy: 'mating_date DESC',
    );
    return result.map((map) => BreedingBatch.fromMap(map)).toList();
  }

  /// 获取某个爬宠的繁殖批次
  Future<List<BreedingBatch>> getBatchesByReptile(String reptileId) async {
    final result = await _dbHelper.queryWhere(
      'breeding_batches',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
      orderBy: 'mating_date DESC',
    );
    return result.map((map) => BreedingBatch.fromMap(map)).toList();
  }

  /// 获取单个繁殖批次
  Future<BreedingBatch?> getBatch(String id) async {
    final result = await _dbHelper.queryWhere(
      'breeding_batches',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return BreedingBatch.fromMap(result.first);
  }

  /// 保存繁殖批次（新增或更新）
  Future<void> saveBatch(BreedingBatch batch) async {
    // 检查是否已存在
    final existing = await getBatch(batch.id);
    if (existing != null) {
      await _dbHelper.update(
        'breeding_batches',
        batch.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [batch.id],
      );
    } else {
      await _dbHelper.insert('breeding_batches', batch.toMap());
    }
  }

  /// 删除繁殖批次
  Future<void> deleteBatch(String id) async {
    // 先删除相关的蛋记录
    await _dbHelper.delete(
      'breeding_eggs',
      where: 'batch_id = ?',
      whereArgs: [id],
    );
    // 再删除批次
    await _dbHelper.delete(
      'breeding_batches',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 蛋记录 ====================

  /// 获取某批次的蛋列表
  Future<List<BreedingEgg>> getEggsByBatch(String batchId) async {
    final result = await _dbHelper.queryWhere(
      'breeding_eggs',
      where: 'batch_id = ?',
      whereArgs: [batchId],
      orderBy: 'egg_number ASC',
    );
    return result.map((map) => BreedingEgg.fromMap(map)).toList();
  }

  /// 保存蛋记录
  Future<void> saveEgg(BreedingEgg egg) async {
    final existing = await _dbHelper.queryWhere(
      'breeding_eggs',
      where: 'id = ?',
      whereArgs: [egg.id],
    );
    if (existing.isNotEmpty) {
      await _dbHelper.update(
        'breeding_eggs',
        egg.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [egg.id],
      );
    } else {
      await _dbHelper.insert('breeding_eggs', egg.toMap());
    }
  }

  /// 删除蛋记录
  Future<void> deleteEgg(String id) async {
    await _dbHelper.delete(
      'breeding_eggs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 苗子档案 ====================

  /// 获取所有苗子
  Future<List<Offspring>> getAllOffspring() async {
    final result = await _dbHelper.query(
      'offspring',
      orderBy: 'birth_date DESC',
    );
    return result.map((map) => Offspring.fromMap(map)).toList();
  }

  /// 获取某批次的苗子
  Future<List<Offspring>> getOffspringByBatch(String batchId) async {
    final result = await _dbHelper.queryWhere(
      'offspring',
      where: 'parent_batch_id = ?',
      whereArgs: [batchId],
      orderBy: 'birth_date DESC',
    );
    return result.map((map) => Offspring.fromMap(map)).toList();
  }

  /// 获取某爬宠的后代
  Future<List<Offspring>> getOffspringByParent(String parentId) async {
    final result = await _dbHelper.queryWhere(
      'offspring',
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'birth_date DESC',
    );
    return result.map((map) => Offspring.fromMap(map)).toList();
  }

  /// 获取单个苗子
  Future<Offspring?> getOffspring(String id) async {
    final result = await _dbHelper.queryWhere(
      'offspring',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Offspring.fromMap(result.first);
  }

  /// 保存苗子
  Future<void> saveOffspring(Offspring offspring) async {
    final existing = await getOffspring(offspring.id);
    if (existing != null) {
      await _dbHelper.update(
        'offspring',
        offspring.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [offspring.id],
      );
    } else {
      await _dbHelper.insert('offspring', offspring.toMap());
    }
  }

  /// 删除苗子
  Future<void> deleteOffspring(String id) async {
    // 先删除成长记录
    await _dbHelper.delete(
      'offspring_growth',
      where: 'offspring_id = ?',
      whereArgs: [id],
    );
    // 再删除苗子
    await _dbHelper.delete(
      'offspring',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 苗子成长记录 ====================

  /// 获取苗子的成长记录
  Future<List<OffspringGrowth>> getGrowthRecords(String offspringId) async {
    final result = await _dbHelper.queryWhere(
      'offspring_growth',
      where: 'offspring_id = ?',
      whereArgs: [offspringId],
      orderBy: 'record_date DESC',
    );
    return result.map((map) => OffspringGrowth.fromMap(map)).toList();
  }

  /// 添加成长记录
  Future<void> addGrowthRecord(OffspringGrowth record) async {
    await _dbHelper.insert('offspring_growth', record.toMap());
  }

  /// 删除成长记录
  Future<void> deleteGrowthRecord(String id) async {
    await _dbHelper.delete(
      'offspring_growth',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 冬化温度记录 ====================

  /// 获取某爬宠的冬化温度记录
  Future<List<BrumationTemp>> getBrumationTemps(String reptileId) async {
    final result = await _dbHelper.queryWhere(
      'brumation_temps',
      where: 'reptile_id = ?',
      whereArgs: [reptileId],
      orderBy: 'record_date DESC',
    );
    return result.map((map) => BrumationTemp.fromMap(map)).toList();
  }

  /// 添加冬化温度记录
  Future<void> addBrumationTemp(BrumationTemp temp) async {
    // 检查当天是否已有记录
    final existing = await _dbHelper.queryWhere(
      'brumation_temps',
      where: 'reptile_id = ? AND date(record_date) = date(?)',
      whereArgs: [temp.reptileId, temp.recordDate.toIso8601String()],
    );
    if (existing.isNotEmpty) {
      // 更新当天记录
      await _dbHelper.update(
        'brumation_temps',
        temp.copyWith(createdAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      await _dbHelper.insert('brumation_temps', temp.toMap());
    }
  }

  /// 删除冬化温度记录
  Future<void> deleteBrumationTemp(String id) async {
    await _dbHelper.delete(
      'brumation_temps',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取温度统计
  Future<Map<String, double>> getTemperatureStats(String reptileId) async {
    final temps = await getBrumationTemps(reptileId);
    if (temps.isEmpty) {
      return {'avg': 0, 'min': 0, 'max': 0};
    }

    double sum = 0;
    double min = temps.first.temperature;
    double max = temps.first.temperature;

    for (var temp in temps) {
      sum += temp.temperature;
      if (temp.temperature < min) min = temp.temperature;
      if (temp.temperature > max) max = temp.temperature;
    }

    return {
      'avg': sum / temps.length,
      'min': min,
      'max': max,
    };
  }

  // ==================== 繁殖提醒 ====================

  /// 获取所有提醒
  Future<List<BreedingReminder>> getReminders() async {
    final result = await _dbHelper.query(
      'breeding_reminders',
      orderBy: 'scheduled_date ASC',
    );
    return result.map((map) => BreedingReminder.fromMap(map)).toList();
  }

  /// 获取即将到来的提醒
  Future<List<BreedingReminder>> getUpcomingReminders(int days) async {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));

    final result = await _dbHelper.queryWhere(
      'breeding_reminders',
      where: 'scheduled_date >= ? AND scheduled_date <= ? AND is_triggered = ?',
      whereArgs: [now.toIso8601String(), future.toIso8601String(), '0'],
      orderBy: 'scheduled_date ASC',
    );
    return result.map((map) => BreedingReminder.fromMap(map)).toList();
  }

  /// 添加提醒
  Future<void> addReminder(BreedingReminder reminder) async {
    await _dbHelper.insert('breeding_reminders', reminder.toMap());
  }

  /// 标记提醒为已触发
  Future<void> triggerReminder(String id) async {
    await _dbHelper.update(
      'breeding_reminders',
      {'is_triggered': '1'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除提醒
  Future<void> deleteReminder(String id) async {
    await _dbHelper.delete(
      'breeding_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 繁殖经验日志 ====================

  /// 获取繁殖日志
  Future<List<BreedingLog>> getLogs({String? reptileId, String? batchId}) async {
    List<Map<String, dynamic>> result;

    if (reptileId != null) {
      result = await _dbHelper.queryWhere(
        'breeding_logs',
        where: 'reptile_id = ?',
        whereArgs: [reptileId],
        orderBy: 'log_date DESC',
      );
    } else if (batchId != null) {
      result = await _dbHelper.queryWhere(
        'breeding_logs',
        where: 'batch_id = ?',
        whereArgs: [batchId],
        orderBy: 'log_date DESC',
      );
    } else {
      result = await _dbHelper.query(
        'breeding_logs',
        orderBy: 'log_date DESC',
      );
    }

    return result.map((map) => BreedingLog.fromMap(map)).toList();
  }

  /// 添加日志
  Future<void> addLog(BreedingLog log) async {
    await _dbHelper.insert('breeding_logs', log.toMap());
  }

  /// 删除日志
  Future<void> deleteLog(String id) async {
    await _dbHelper.delete(
      'breeding_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 繁殖统计 ====================

  /// 获取繁殖统计数据
  Future<BreedingStats> getBreedingStats({String? reptileId}) async {
    List<BreedingBatch> batches;

    if (reptileId != null) {
      batches = await getBatchesByReptile(reptileId);
    } else {
      batches = await getAllBatches();
    }

    int totalEggs = 0;
    int hatchedCount = 0;
    int survivedCount = 0;
    Map<String, int> speciesStats = {};

    for (var batch in batches) {
      // 统计物种
      speciesStats[batch.species] = (speciesStats[batch.species] ?? 0) + 1;

      // 获取蛋记录
      final eggs = await getEggsByBatch(batch.id);
      totalEggs += eggs.length;

      for (var egg in eggs) {
        if (egg.hatchStatus == 'hatched') {
          hatchedCount++;
          // 检查苗子状态
          if (egg.offspringId != null) {
            final offspring = await getOffspring(egg.offspringId!);
            if (offspring != null && offspring.status == 'alive') {
              survivedCount++;
            }
          }
        }
      }
    }

    double hatchRate = totalEggs > 0 ? (hatchedCount / totalEggs) * 100 : 0;
    double survivalRate = hatchedCount > 0 ? (survivedCount / hatchedCount) * 100 : 0;

    return BreedingStats(
      totalBatches: batches.length,
      totalEggs: totalEggs,
      hatchedCount: hatchedCount,
      survivedCount: survivedCount,
      hatchRate: hatchRate,
      survivalRate: survivalRate,
      speciesStats: speciesStats,
    );
  }
}
