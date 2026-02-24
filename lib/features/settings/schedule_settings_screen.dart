import 'package:flutter/material.dart';
import '../../utils/schedule_manager.dart';

class ScheduleSettingsScreen extends StatefulWidget {
  const ScheduleSettingsScreen({super.key});

  @override
  State<ScheduleSettingsScreen> createState() => _ScheduleSettingsScreenState();
}

class _ScheduleSettingsScreenState extends State<ScheduleSettingsScreen> {
  final ScheduleManager _scheduleManager = ScheduleManager();
  int _updateInterval = ScheduleManager.defaultUpdateInterval;
  DateTime? _lastUpdateTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final interval = await _scheduleManager.getUpdateInterval();
    final lastUpdate = await _scheduleManager.getLastUpdateTime(
      ScheduleManager.keyLastUpdateExhibition,
    );
    setState(() {
      _updateInterval = interval;
      _lastUpdateTime = lastUpdate;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('定时更新设置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // 标题
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '资讯自动更新',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 更新间隔设置
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('自动更新间隔'),
                  subtitle: Text('每 $_updateInterval 小时检查更新'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showIntervalPicker(),
                ),
                const Divider(),
                // 最后更新时间
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('最后更新时间'),
                  subtitle: Text(
                    _lastUpdateTime != null
                        ? _formatDateTime(_lastUpdateTime!)
                        : '从未更新',
                  ),
                ),
                const Divider(),
                // 立即更新按钮
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('立即更新'),
                  subtitle: const Text('手动触发资讯更新'),
                  onTap: () => _triggerImmediateUpdate(),
                ),
                const Divider(),
                // 提示信息
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '开启自动更新后，应用会在后台定期检查并更新展览资讯和文章内容。',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 更新间隔选项说明
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '建议设置',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildRecommendationCard(
                  '推荐：每 6 小时',
                  '兼顾省电和资讯时效性，适合大多数用户',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildRecommendationCard(
                  '每小时',
                  '获取最新资讯，但会增加电量消耗',
                  Icons.flash_on,
                  Colors.orange,
                ),
                _buildRecommendationCard(
                  '每天',
                  '最省电，但资讯更新可能不及时',
                  Icons.battery_saver,
                  Colors.grey,
                ),
              ],
            ),
    );
  }

  Widget _buildRecommendationCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: _updateInterval == _getIntervalFromTitle(title)
            ? const Icon(Icons.check, color: Colors.green)
            : null,
        onTap: () async {
          final interval = _getIntervalFromTitle(title);
          await _scheduleManager.setUpdateInterval(interval);
          await _loadSettings();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('设置已更新')),
            );
          }
        },
      ),
    );
  }

  int _getIntervalFromTitle(String title) {
    if (title.contains('每小时')) return 1;
    if (title.contains('6 小时')) return 6;
    if (title.contains('每天')) return 24;
    return 6;
  }

  void _showIntervalPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择更新间隔',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildIntervalOption(1, '每小时'),
            _buildIntervalOption(3, '每 3 小时'),
            _buildIntervalOption(6, '每 6 小时'),
            _buildIntervalOption(12, '每 12 小时'),
            _buildIntervalOption(24, '每天'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalOption(int hours, String label) {
    final isSelected = _updateInterval == hours;
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () async {
        await _scheduleManager.setUpdateInterval(hours);
        await _loadSettings();
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _triggerImmediateUpdate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await _scheduleManager.triggerImmediateUpdate();
    await _loadSettings();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已开始更新资讯')),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} 分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} 小时前';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
