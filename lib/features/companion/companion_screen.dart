import 'package:flutter/material.dart';
import '../../data/models/companion.dart';
import '../../app/theme.dart';

class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = [
    'snake',
    'lizard',
    'turtle',
    'gecko',
    'amphibian',
    'arachnid',
    'insect',
    'mammal',
    'bird',
    'fish',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('混养指南'),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '兼容性矩阵'),
            Tab(text: '注意事项'),
            Tab(text: '推荐方案'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompatibilityMatrix(),
          _buildCautions(),
          _buildRecommendations(),
        ],
      ),
    );
  }

  // 兼容性矩阵
  Widget _buildCompatibilityMatrix() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '宠物混养兼容性参考表',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '选择两种宠物类别查看兼容性',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          // 图例
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('可以混养', Colors.green),
              _buildLegendItem('需谨慎', Colors.orange),
              _buildLegendItem('不能混养', Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          // 矩阵表格
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildMatrixTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMatrixTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: {
        0: const FixedColumnWidth(60),
        ...List.generate(_categories.length, (i) => i + 1)
            .toList()
            .asMap()
            .map((k, v) => MapEntry(v, const FixedColumnWidth(50))),
      },
      children: [
        // 表头
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: [
            const SizedBox(height: 40),
            ..._categories.map((cat) => Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    categoryNames[cat] ?? cat,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )),
          ],
        ),
        // 数据行
        ..._categories.map((rowCat) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  categoryNames[rowCat] ?? rowCat,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._categories.map((colCat) {
                final compat = getCompatibility(rowCat, colCat);
                return Container(
                  width: 50,
                  height: 40,
                  color: Color(getCompatibilityColor(compat)).withOpacity(0.3),
                  child: Center(
                    child: Text(
                      _getCompatSymbol(compat),
                      style: TextStyle(
                        color: Color(getCompatibilityColor(compat)),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  String _getCompatSymbol(CompatibilityLevel level) {
    switch (level) {
      case CompatibilityLevel.compatible:
        return '✓';
      case CompatibilityLevel.incompatible:
        return '✗';
      case CompatibilityLevel.cautious:
        return '!';
    }
  }

  // 注意事项
  Widget _buildCautions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '各类别混养注意事项',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._categories.map((cat) {
          final catCautions = getCautions(cat);
          if (catCautions.isEmpty) return const SizedBox.shrink();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Icon(
                _getCategoryIcon(cat),
                color: AppTheme.getCategoryColor(cat),
              ),
              title: Text(
                categoryNames[cat] ?? cat,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: catCautions.map((caution) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(caution),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  // 推荐方案
  Widget _buildRecommendations() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '推荐的混养方案',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '以下方案需要在主人监督下进行',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        ...recommendedCombinations.map((combo) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    combo['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    combo['description']!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: (combo['categories']!.split(',')).map((cat) {
                      return Chip(
                        avatar: Icon(
                          _getCategoryIcon(cat.trim()),
                          size: 16,
                          color: AppTheme.getCategoryColor(cat.trim()),
                        ),
                        label: Text(
                          categoryNames[cat.trim()] ?? cat,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppTheme.getCategoryColor(cat.trim())
                            .withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        // 不推荐方案
        const Text(
          '不建议的混养',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildNotRecommended(),
      ],
    );
  }

  Widget _buildNotRecommended() {
    final notRecommended = [
      {'from': '蛇类', 'to': '任何小动物', 'reason': '蛇类是捕食者'},
      {'from': '蜘蛛', 'to': '昆虫', 'reason': '蜘蛛会捕食昆虫'},
      {'from': '鸟类', 'to': '昆虫', 'reason': '可能误食'},
      {'from': '哺乳', 'to': '爬宠', 'reason': '可能传播病原体'},
    ];

    return Column(
      children: notRecommended.map((item) {
        return Card(
          color: Colors.red[50],
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.cancel, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${item['from']} + ${item['to']}: ${item['reason']}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'snake':
        return Icons.pest_control;
      case 'lizard':
        return Icons.pets;
      case 'turtle':
        return Icons.emoji_nature;
      case 'gecko':
        return Icons.bug_report;
      case 'amphibian':
        return Icons.water;
      case 'arachnid':
        return Icons.pest_control_rodent;
      case 'insect':
        return Icons.bug_report;
      case 'mammal':
        return Icons.pets;
      case 'bird':
        return Icons.flutter_dash;
      case 'fish':
        return Icons.water;
      default:
        return Icons.pets;
    }
  }
}
