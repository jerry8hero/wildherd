import 'package:flutter/material.dart';
import '../../data/models/encyclopedia.dart';
import '../../data/repositories/repositories.dart';
import '../../app/theme.dart';
import '../../utils/image_utils.dart';

class EncyclopediaScreen extends StatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EncyclopediaRepository _repository = EncyclopediaRepository();
  Map<String, List<ReptileSpecies>> _categorySpecies = {};
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'snake', 'name': '蛇类', 'icon': Icons.pest_control},
    {'id': 'lizard', 'name': '蜥蜴', 'icon': Icons.pets},
    {'id': 'turtle', 'name': '龟类', 'icon': Icons.emoji_nature},
    {'id': 'gecko', 'name': '守宫', 'icon': Icons.bug_report},
    {'id': 'amphibian', 'name': '两栖', 'icon': Icons.water},
    {'id': 'arachnid', 'name': '蜘蛛', 'icon': Icons.pest_control_rodent},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final species = await _repository.getAllSpecies();
      final grouped = <String, List<ReptileSpecies>>{};

      for (var cat in _categories) {
        grouped[cat['id']!] = species
            .where((s) => s.category == cat['id'])
            .toList();
      }

      setState(() {
        _categorySpecies = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('爬宠百科'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((cat) => Tab(text: cat['name'] as String)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _categories.map((cat) {
                return _buildSpeciesList(cat['id'] as String);
              }).toList(),
            ),
    );
  }

  Widget _buildSpeciesList(String category) {
    final species = _categorySpecies[category] ?? [];

    if (species.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '暂无数据',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: species.length,
      itemBuilder: (context, index) {
        return _buildSpeciesCard(species[index]);
      },
    );
  }

  Widget _buildSpeciesCard(ReptileSpecies species) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSpeciesDetail(species),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.getCategoryColor(species.category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: species.imageUrl != null && species.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image(
                          image: ImageUtils.getImageProvider(species.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      species.nameChinese,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      species.nameEnglish,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildDifficultyIndicator(species.difficulty),
                        const SizedBox(width: 8),
                        Text(
                          '寿命: ${species.lifespan}年',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyIndicator(int difficulty) {
    return Row(
      children: [
        Text(
          '难度: ',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        ...List.generate(5, (index) {
          return Icon(
            Icons.circle,
            size: 8,
            color: index < difficulty ? Colors.orange : Colors.grey[300],
          );
        }),
      ],
    );
  }

  void _showSpeciesDetail(ReptileSpecies species) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 物种信息
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.getCategoryColor(species.category),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: species.imageUrl != null && species.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image(
                              image: ImageUtils.getImageProvider(species.imageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.pets,
                                  color: Colors.white,
                                  size: 40,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.pets,
                            color: Colors.white,
                            size: 40,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          species.nameChinese,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          species.nameEnglish,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          species.scientificName,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 描述
              const Text(
                '简介',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                species.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // 基本信息
              const Text(
                '基本信息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('饲养难度', _buildDifficultyIndicator(species.difficulty)),
              _buildInfoRow('预期寿命', '${species.lifespan} 年'),
              if (species.maxLength != null)
                _buildInfoRow('最大长度', '${species.maxLength} cm'),
              _buildInfoRow('食性', _getDietText(species.diet)),
              if (species.subCategory != null)
                _buildInfoRow('类型', _getSubCategoryText(species.subCategory!)),
              const SizedBox(height: 24),

              // 环境要求
              const Text(
                '环境要求',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (species.minTemp != null && species.maxTemp != null)
                _buildInfoRow(
                  '温度',
                  '${species.minTemp}°C - ${species.maxTemp}°C',
                ),
              if (species.minHumidity != null && species.maxHumidity != null)
                _buildInfoRow(
                  '湿度',
                  '${species.minHumidity!.toInt()}% - ${species.maxHumidity!.toInt()}%',
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(child: value is Widget ? value : Text('$value')),
        ],
      ),
    );
  }

  String _getDietText(String diet) {
    switch (diet) {
      case 'carnivore':
        return '肉食性';
      case 'herbivore':
        return '草食性';
      case 'omnivore':
        return '杂食性';
      default:
        return diet;
    }
  }

  String _getSubCategoryText(String subCategory) {
    switch (subCategory) {
      case 'aquatic':
        return '水龟';
      case 'semi_aquatic':
        return '半水龟';
      case 'terrestrial':
        return '陆龟';
      default:
        return subCategory;
    }
  }
}
