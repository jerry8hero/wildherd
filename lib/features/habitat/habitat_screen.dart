import 'package:flutter/material.dart';
import '../../data/models/habitat.dart';
import '../../data/repositories/habitat_repository.dart';
import '../../app/theme.dart';
import '../../widgets/habitat_gauge.dart';
import 'habitat_edit_screen.dart';
import 'habitat_compare_screen.dart';

class HabitatScreen extends StatefulWidget {
  const HabitatScreen({super.key});

  @override
  State<HabitatScreen> createState() => _HabitatScreenState();
}

class _HabitatScreenState extends State<HabitatScreen> {
  final HabitatRepository _repository = HabitatRepository();
  List<HabitatEnvironment> _environments = [];
  Map<String, HabitatStandard> _standards = {};
  Map<String, HabitatScore> _scores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final environments = await _repository.getAllEnvironments();

      // 加载每个环境的标准和评分
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
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('饲养环境'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HabitatCompareScreen(),
                ),
              );
            },
            tooltip: '环境对比',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _environments.isEmpty
              ? _buildEmptyState()
              : _buildEnvironmentList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEnvironment,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('添加环境'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '暂无饲养环境数据',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮为您的宠物创建环境设置',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _environments.length,
        itemBuilder: (context, index) {
          return _buildEnvironmentCard(_environments[index]);
        },
      ),
    );
  }

  Widget _buildEnvironmentCard(HabitatEnvironment environment) {
    final standard = _standards[environment.reptileId];
    final score = _scores[environment.reptileId];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _editEnvironment(environment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：宠物名和评分
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          environment.reptileName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (standard != null)
                          Text(
                            '建议温度: ${standard.minTemp.toInt()}-${standard.maxTemp.toInt()}°C',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (score != null)
                    OverallScoreCircle(score: score.overallScore),
                ],
              ),
              const SizedBox(height: 16),
              // 温度和湿度仪表盘
              if (standard != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    HabitatGauge(
                      label: '温度',
                      value: environment.temperature,
                      minValue: standard.minTemp - 10,
                      maxValue: standard.maxTemp + 10,
                      idealMin: standard.minTemp,
                      idealMax: standard.maxTemp,
                      unit: '°C',
                      size: 100,
                    ),
                    HabitatGauge(
                      label: '湿度',
                      value: environment.humidity,
                      minValue: 0,
                      maxValue: 100,
                      idealMin: standard.minHumidity,
                      idealMax: standard.maxHumidity,
                      unit: '%',
                      size: 100,
                    ),
                  ],
                ),
              // 评分详情
              if (score != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                ScoreProgressBar(label: '温度', score: score.temperatureScore),
                const SizedBox(height: 8),
                ScoreProgressBar(label: '湿度', score: score.humidityScore),
                if (score.uvScore < 100) ...[
                  const SizedBox(height: 8),
                  ScoreProgressBar(label: 'UVB', score: score.uvScore),
                ],
                if (score.spaceScore < 100) ...[
                  const SizedBox(height: 8),
                  ScoreProgressBar(label: '空间', score: score.spaceScore),
                ],
              ],
              // 建议数量
              if (score != null && score.suggestions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${score.suggestions.length} 条改进建议',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addEnvironment() async {
    final reptiles = await _repository.getUserReptiles();
    if (reptiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先添加宠物')),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HabitatEditScreen(),
        ),
      ).then((_) => _loadData());
    }
  }

  void _editEnvironment(HabitatEnvironment environment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitatEditScreen(environment: environment),
      ),
    ).then((_) => _loadData());
  }
}
