import '../local/database_helper.dart';
import '../models/price_alert.dart';
import '../models/price.dart';

class PriceAlertRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取所有提醒
  Future<List<PriceAlert>> getAllAlerts() async {
    final result = await _dbHelper.query('price_alerts', orderBy: 'created_at DESC');
    return result.map((map) => PriceAlert.fromMap(map)).toList();
  }

  // 获取某个物种的提醒
  Future<PriceAlert?> getAlertBySpecies(String speciesId) async {
    final result = await _dbHelper.queryWhere(
      'price_alerts',
      where: 'species_id = ?',
      whereArgs: [speciesId],
    );
    if (result.isEmpty) return null;
    return PriceAlert.fromMap(result.first);
  }

  // 添加提醒
  Future<void> addAlert(PriceAlert alert) async {
    await _dbHelper.insert('price_alerts', alert.toMap());
  }

  // 更新提醒
  Future<void> updateAlert(PriceAlert alert) async {
    await _dbHelper.update(
      'price_alerts',
      alert.toMap(),
      where: 'id = ?',
      whereArgs: [alert.id],
    );
  }

  // 删除提醒
  Future<void> deleteAlert(String id) async {
    await _dbHelper.delete('price_alerts', where: 'id = ?', whereArgs: [id]);
  }

  // 开启/关闭提醒
  Future<void> toggleAlert(String id, bool isEnabled) async {
    await _dbHelper.update(
      'price_alerts',
      {'is_enabled': isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取已开启的提醒
  Future<List<PriceAlert>> getEnabledAlerts() async {
    final result = await _dbHelper.queryWhere(
      'price_alerts',
      where: 'is_enabled = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => PriceAlert.fromMap(map)).toList();
  }

  // 检查并更新提醒中的当前价格信息
  Future<List<PriceAlert>> getAlertsWithCurrentPrice(List<PetPrice> prices) async {
    final alerts = await getAllAlerts();

    // 构建价格查找表
    final priceMap = {for (var p in prices) p.speciesId: p};

    // 更新每个提醒的当前价格
    return alerts.map((alert) {
      final price = priceMap[alert.speciesId];
      if (price != null) {
        return alert.copyWith(
          currentPrice: price.currentPrice,
          lowestPrice: price.minPrice,
        );
      }
      return alert;
    }).toList();
  }

  // 检查哪些提醒已触发
  Future<List<PriceAlert>> getTriggeredAlerts(List<PetPrice> prices) async {
    final alertsWithPrice = await getAlertsWithCurrentPrice(prices);
    return alertsWithPrice.where((alert) => alert.isTriggered).toList();
  }
}
