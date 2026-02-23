import 'package:flutter/material.dart';
import '../../data/models/habitat.dart';
import '../../data/repositories/habitat_repository.dart';
import '../../app/theme.dart';
import '../../widgets/habitat_gauge.dart';

class HabitatCompareScreen extends StatefulWidget {
  const HabitatCompareScreen({super.key});

  @override
  State<HabitatCompareScreen> createState() => _HabitatCompareScreenState();
}

class _HabitatCompareScreenState extends State<HabitatCompareScreen> {
  final HabitatRepository _repository = HabitatRepository();
  List<HabitatEnvironment> _environments = [];
  Map<String, HabitatStandard> _standards = {};
  Map<String, HabitatScore> _scores = {};
  final Set<String> _selectedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final environments = await _repository.getAllEnvironments();

      final standards = <String, HabitatStandard>{};
      final scores = <String, HabitatScore>{};

      for (var env in environments) {
        final standard = await _repository.getStandard(env.speciesId);
        if (standard != null) {
          standards[env.reptileId] = standard;
          scores[env.reptileId] = _repository.calculateScore(env, standard);
        }
      }

      setState(() {
        _environments = environments;
        _standards = standards;
        _scores = scores;
        _isLoading = false;

        // 默认选择前两个
        if (environments.length >= 2) {
          _selectedIds.add(environments[0].reptileId);
          _selectedIds.add(environments[1].reptileId);
        } else if (environments.isNotEmpty) {
          _selectedIds.add(environments[0].reptileId);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<HabitatEnvironment> get _selectedEnvironments {
    return _environments.where((e) => _selectedIds.contains(e.reptileId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('环境对比'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _environments.isEmpty
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text('暂无环境数据'),
          Text('请先添加环境设置'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // 选择宠物
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择要对比的宠物',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _environments.map((env) {
                  final isSelected = _selectedIds.contains(env.reptileId);
                  return FilterChip(
                    label: Text(env.reptileName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedIds.add(env.reptileId);
                        } else if (_selectedIds.length > 1) {
                          _selectedIds.remove(env.reptileId);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // 对比内容
        Expanded(
          child: _selectedEnvironments.length < 2
              ? const Center(child: Text('请至少选择2个宠物进行对比'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildScoreComparison(),
                      const SizedBox(height: 24),
                      _buildParameterComparison(),
                      const SizedBox(height: 24),
                      _buildEnvironmentDetails(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildScoreComparison() {
    final selected = _selectedEnvironments;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, size: 20),
                SizedBox(width: 8),
                Text('综合评分对比', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: selected.map((env) {
                final score = _scores[env.reptileId];
                return Column(
                  children: [
                    if (score != null)
                      OverallScoreCircle(score: score.overallScore, size: 70),
                    const SizedBox(height: 8),
                    Text(env.reptileName, style: const TextStyle(fontWeight: FontWeight.w500)),
                    if (score != null)
                      Text(
                        _getScoreLevel(score.overallScore),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getScoreColor(score.overallScore),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterComparison() {
    final selected = _selectedEnvironments;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.speed, size: 20),
                SizedBox(width: 8),
                Text('参数对比', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            // 温度对比
            _buildComparisonRow(
              '温度 (°C)',
              Icons.thermostat,
              selected.map((env) {
                final std = _standards[env.reptileId];
                return _ComparisonItem(
                  value: env.temperature.toStringAsFixed(1),
                  isInRange: std != null &&
                      env.temperature >= std.minTemp &&
                      env.temperature <= std.maxTemp,
                );
              }).toList(),
            ),
            const Divider(),
            // 湿度对比
            _buildComparisonRow(
              '湿度 (%)',
              Icons.water_drop,
              selected.map((env) {
                final std = _standards[env.reptileId];
                return _ComparisonItem(
                  value: env.humidity.toStringAsFixed(0),
                  isInRange: std != null &&
                      env.humidity >= std.minHumidity &&
                      env.humidity <= std.maxHumidity,
                );
              }).toList(),
            ),
            const Divider(),
            // UV对比
            _buildComparisonRow(
              'UV指数',
              Icons.wb_sunny,
              selected.map((env) {
                return _ComparisonItem(
                  value: env.uvIndex?.toStringAsFixed(1) ?? '-',
                  isInRange: true,
                );
              }).toList(),
            ),
            const Divider(),
            // 空间对比
            _buildComparisonRow(
              '饲养箱 (L)',
              Icons.square_foot,
              selected.map((env) {
                final std = _standards[env.reptileId];
                return _ComparisonItem(
                  value: env.tankSize?.toStringAsFixed(0) ?? '-',
                  isInRange: std != null && (env.tankSize ?? 0) >= std.minTankSize,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, IconData icon, List<_ComparisonItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: items.map((item) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: item.isInRange
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: item.isInRange ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentDetails() {
    final selected = _selectedEnvironments;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.list, size: 20),
                SizedBox(width: 8),
                Text('详细信息', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            ...selected.map((env) => _buildDetailCard(env)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(HabitatEnvironment env) {
    final standard = _standards[env.reptileId];
    final score = _scores[env.reptileId];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                env.reptileName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              if (score != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score.overallScore).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '评分: ${score.overallScore.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getScoreColor(score.overallScore),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDetailRow('温度', '${env.temperature}°C', standard != null && env.temperature >= standard.minTemp && env.temperature <= standard.maxTemp),
          _buildDetailRow('湿度', '${env.humidity.toInt()}%', standard != null && env.humidity >= standard.minHumidity && env.humidity <= standard.maxHumidity),
          _buildDetailRow('UV', env.uvIndex?.toStringAsFixed(1) ?? '未设置', true),
          _buildDetailRow('垫材', _getSubstrateName(env.substrate), true),
          _buildDetailRow('照明', _getLightingName(env.lighting), true),
          _buildDetailRow('箱体', env.tankSize != null ? '${env.tankSize!.toInt()}L' : '未设置', standard != null && (env.tankSize ?? 0) >= standard.minTankSize),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isGood) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
          Text(value, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Icon(
            isGood ? Icons.check_circle : Icons.warning,
            size: 14,
            color: isGood ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  String _getScoreLevel(double score) {
    if (score >= 80) return '优秀';
    if (score >= 60) return '良好';
    return '需改进';
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getSubstrateName(String? id) {
    if (id == null) return '未设置';
    final option = SubstrateOptions.all.firstWhere(
      (o) => o.id == id,
      orElse: () => SubstrateOptions.all.first,
    );
    return option.name;
  }

  String _getLightingName(String? id) {
    if (id == null) return '未设置';
    final option = LightingOptions.all.firstWhere(
      (o) => o.id == id,
      orElse: () => LightingOptions.all.first,
    );
    return option.name;
  }
}

class _ComparisonItem {
  final String value;
  final bool isInRange;

  _ComparisonItem({required this.value, required this.isInRange});
}
