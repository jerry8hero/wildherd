import 'package:flutter/material.dart';
import '../../data/models/price_alert.dart';
import '../../data/repositories/price_alert_repository.dart';
import '../../data/repositories/price_repository.dart';
import '../../app/theme.dart';

class PriceAlertScreen extends StatefulWidget {
  const PriceAlertScreen({super.key});

  @override
  State<PriceAlertScreen> createState() => _PriceAlertScreenState();
}

class _PriceAlertScreenState extends State<PriceAlertScreen> {
  final PriceAlertRepository _alertRepository = PriceAlertRepository();
  final PriceRepository _priceRepository = PriceRepository();
  List<PriceAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      final prices = await _priceRepository.getAllPrices();
      final alerts = await _alertRepository.getAlertsWithCurrentPrice(prices);
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAlert(String id) async {
    await _alertRepository.deleteAlert(id);
    _loadAlerts();
  }

  Future<void> _toggleAlert(String id, bool isEnabled) async {
    await _alertRepository.toggleAlert(id, isEnabled);
    _loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('价格提醒'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
              ? _buildEmptyState()
              : _buildAlertList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '暂无价格提醒',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '在行情页面点击提醒按钮添加',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertList() {
    return RefreshIndicator(
      onRefresh: _loadAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          return _buildAlertCard(_alerts[index]);
        },
      ),
    );
  }

  Widget _buildAlertCard(PriceAlert alert) {
    final isTriggered = alert.isTriggered;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 物种图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isTriggered ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isTriggered ? Icons.notifications_active : Icons.notifications_none,
                    color: isTriggered ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                // 物种名称
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.speciesName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        alert.speciesNameEnglish,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                // 开关
                Switch(
                  value: alert.isEnabled,
                  onChanged: (value) => _toggleAlert(alert.id, value),
                  activeTrackColor: AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 价格信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildPriceInfo(
                      label: '当前价格',
                      value: '¥${alert.currentPrice?.toInt() ?? "-"}',
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: _buildPriceInfo(
                      label: alert.alertType == 'lowest' ? '历史最低' : '目标价格',
                      value: alert.alertType == 'lowest'
                          ? '¥${alert.lowestPrice?.toInt() ?? "-"}'
                          : '¥${alert.targetPrice.toInt()}',
                      color: isTriggered ? Colors.green : Colors.orange,
                    ),
                  ),
                  if (isTriggered)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '已触发!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 提醒类型和删除按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      alert.alertType == 'lowest' ? Icons.trending_down : Icons.edit,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert.alertTypeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _deleteAlert(alert.id),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('删除'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
