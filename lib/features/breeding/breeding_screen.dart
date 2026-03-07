import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/breeding.dart';
import '../../data/repositories/breeding_repository.dart';
import '../../app/theme.dart';
import 'breeding_batch_list_screen.dart';
import 'breeding_calendar_screen.dart';
import 'brumation_screen.dart';
import 'offspring_list_screen.dart';
import 'breeding_stats_screen.dart';
import 'breeding_log_screen.dart';

class BreedingScreen extends ConsumerStatefulWidget {
  const BreedingScreen({super.key});

  @override
  ConsumerState<BreedingScreen> createState() => _BreedingScreenState();
}

class _BreedingScreenState extends ConsumerState<BreedingScreen> {
  final BreedingRepository _repository = BreedingRepository();
  List<BreedingBatch> _batches = [];
  List<BreedingReminder> _upcomingReminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final batches = await _repository.getAllBatches();
      final reminders = await _repository.getUpcomingReminders(7);

      setState(() {
        _batches = batches;
        _upcomingReminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('繁殖管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BreedingCalendarScreen(),
                ),
              );
            },
            tooltip: '繁殖日历',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 快捷功能入口
                  _buildQuickActions(context),
                  const SizedBox(height: 24),

                  // 即将到来的提醒
                  if (_upcomingReminders.isNotEmpty) ...[
                    _buildUpcomingReminders(),
                    const SizedBox(height: 24),
                  ],

                  // 当前繁殖进度
                  _buildBreedingProgress(),
                  const SizedBox(height: 24),

                  // 繁殖统计概览
                  _buildStatsOverview(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BreedingBatchListScreen(),
            ),
          ).then((_) => _loadData());
        },
        icon: const Icon(Icons.add),
        label: const Text('添加繁殖'),
      ),
    );
  }

  /// 快捷功能入口
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快捷功能',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.egg,
                label: '繁殖批次',
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BreedingBatchListScreen(),
                    ),
                  ).then((_) => _loadData());
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.pets,
                label: '苗子档案',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OffspringListScreen(),
                    ),
                  ).then((_) => _loadData());
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.ac_unit,
                label: '冬化监控',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BrumationScreen(),
                    ),
                  ).then((_) => _loadData());
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.bar_chart,
                label: '繁殖统计',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BreedingStatsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 即将到来的提醒
  Widget _buildUpcomingReminders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '即将到来的提醒',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._upcomingReminders.take(3).map((reminder) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getReminderColor(reminder.type),
              child: Icon(
                _getReminderIcon(reminder.type),
                color: Colors.white,
              ),
            ),
            title: Text(reminder.typeName),
            subtitle: Text(reminder.reptileName ?? ''),
            trailing: Text(
              _formatDate(reminder.scheduledDate),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        )),
      ],
    );
  }

  /// 当前繁殖进度
  Widget _buildBreedingProgress() {
    // 获取进行中的繁殖批次
    final activeBatches = _batches.where((b) =>
      b.status != 'hatched' && b.status != 'failed' && b.status != 'cancelled'
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '当前繁殖进度',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (activeBatches.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.egg_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '暂无进行中的繁殖',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...activeBatches.take(3).map((batch) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.egg, color: Colors.white),
              ),
              title: Text(batch.reptileName),
              subtitle: Text(batch.stage),
              trailing: batch.eggCount != null
                  ? Text('${batch.eggCount}枚蛋')
                  : null,
            ),
          )),
      ],
    );
  }

  /// 繁殖统计概览
  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '繁殖经验',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BreedingLogScreen(),
                  ),
                );
              },
              child: const Text('查看更多'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: '繁殖批次',
                      value: '${_batches.length}',
                      icon: Icons.batch_prediction,
                    ),
                    _StatItem(
                      label: '总产蛋数',
                      value: '${_batches.fold(0, (sum, b) => sum + (b.eggCount ?? 0))}',
                      icon: Icons.egg,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: '总出壳数',
                      value: '${_batches.fold(0, (sum, b) => sum + (b.hatchedCount ?? 0))}',
                      icon: Icons.pets,
                    ),
                    _StatItem(
                      label: '经验日志',
                      value: '点击查看',
                      icon: Icons.article,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BreedingLogScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getReminderColor(String type) {
    switch (type) {
      case 'brumation_start':
      case 'brumation_end':
        return Colors.blue;
      case 'heating':
        return Colors.orange;
      case 'mating':
        return Colors.pink;
      case 'egg_laying':
        return Colors.green;
      case 'candling':
        return Colors.purple;
      case 'hatching':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getReminderIcon(String type) {
    switch (type) {
      case 'brumation_start':
      case 'brumation_end':
        return Icons.ac_unit;
      case 'heating':
        return Icons.whatshot;
      case 'mating':
        return Icons.favorite;
      case 'egg_laying':
        return Icons.egg;
      case 'candling':
        return Icons.flashlight_on;
      case 'hatching':
        return Icons.pets;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == -1) return '昨天';
    return '${date.month}月${date.day}日';
  }
}

/// 快捷功能卡片
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 统计项
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
