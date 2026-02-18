import 'dart:async';
import '../models/price_alert.dart';
import '../repositories/price_alert_repository.dart';
import '../repositories/price_repository.dart';

/// 通知服务
/// 负责管理降价提醒的检查和通知发送
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final PriceAlertRepository _alertRepository = PriceAlertRepository();
  final PriceRepository _priceRepository = PriceRepository();

  // 监听器列表
  final List<VoidCallback> _listeners = [];

  // 触发的提醒缓存
  List<PriceAlert> _triggeredAlerts = [];

  /// 添加监听器
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// 移除监听器
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// 通知监听器
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// 获取触发的提醒
  List<PriceAlert> get triggeredAlerts => _triggeredAlerts;

  /// 检查所有提醒是否有触发的
  Future<void> checkAlerts() async {
    try {
      // 获取最新价格
      final prices = await _priceRepository.getAllPrices();

      // 获取触发的提醒
      final triggered = await _alertRepository.getTriggeredAlerts(prices);

      // 更新缓存
      _triggeredAlerts = triggered;

      // 通知监听器
      _notifyListeners();
    } catch (e) {
      // 静默处理错误
    }
  }

  /// 初始化服务
  Future<void> init() async {
    // 启动时检查一次
    await checkAlerts();
  }
}
