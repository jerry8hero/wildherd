import 'package:flutter/material.dart';
import '../../data/models/achievement.dart';
import '../../utils/achievement_manager.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> with SingleTickerProviderStateMixin {
  final AchievementManager _manager = AchievementManager();
  late TabController _tabController;
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    final achievements = _manager.getAllAchievements();
    setState(() {
      _achievements = achievements;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _manager.getTotalCount();
    final unlockedCount = _manager.getUnlockedCount();
    final progress = _manager.getProgress();

    return Scaffold(
      appBar: AppBar(
        title: const Text('成就'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '未解锁'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 成就统计卡片
                _buildStatsCard(totalCount, unlockedCount, progress),
                // 成就列表
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAchievementList(_achievements),
                      _buildAchievementList(_manager.getLockedAchievements()),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsCard(int total, int unlocked, double progress) {
    final points = _manager.getTotalPoints();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[400]!,
            Colors.blue[700]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '成就进度',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '$unlocked / $total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    '总积分',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 4),
                      Text(
                        '$points',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation(Colors.amber),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% 完成',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementList(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '暂无成就',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // 按类型分组
    final grouped = <AchievementType, List<Achievement>>{};
    for (var a in achievements) {
      grouped.putIfAbsent(a.type, () => []).add(a);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return _buildTypeSection(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildTypeSection(AchievementType type, List<Achievement> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _getTypeName(type),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...achievements.map((a) => _buildAchievementCard(a)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showAchievementDetail(achievement),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 图标
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.amber[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 28,
                      color: isUnlocked ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.titleZh,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? null : Colors.grey[600],
                            ),
                          ),
                        ),
                        if (isUnlocked)
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isUnlocked ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                    if (!isUnlocked) ...[
                      const SizedBox(height: 8),
                      // 进度条
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: achievement.progress,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(Colors.blue[400]!),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${achievement.currentValue}/${achievement.targetValue}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: achievement.isUnlocked ? Colors.amber[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 标题
            Text(
              achievement.titleZh,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            // 描述
            Text(
              achievement.description,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // 进度或解锁时间
            if (achievement.isUnlocked) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      achievement.unlockedAt != null
                          ? '解锁于 ${_formatDate(achievement.unlockedAt!)}'
                          : '已解锁',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Column(
                children: [
                  Text(
                    '进度: ${achievement.currentValue} / ${achievement.targetValue}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: achievement.progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(Colors.blue[400]!),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
            // 奖励
            if (achievement.reward != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '奖励: ${_getRewardText(achievement.reward!)}',
                      style: TextStyle(color: Colors.amber[800]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTypeName(AchievementType type) {
    switch (type) {
      case AchievementType.login:
        return '登录成就';
      case AchievementType.reptile:
        return '爬宠成就';
      case AchievementType.community:
        return '社区成就';
      case AchievementType.encyclopedia:
        return '知识成就';
      case AchievementType.qa:
        return '问答成就';
      case AchievementType.article:
        return '阅读成就';
      case AchievementType.habitat:
        return '饲养成就';
      case AchievementType.milestone:
        return '里程碑';
    }
  }

  String _getRewardText(AchievementReward reward) {
    switch (reward.type) {
      case 'points':
        return '${reward.value} 积分';
      case 'badge':
        return '徽章: ${reward.value}';
      default:
        return reward.value;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
