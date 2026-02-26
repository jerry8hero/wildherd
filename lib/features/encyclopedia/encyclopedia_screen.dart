import 'package:flutter/material.dart';
import '../../data/models/encyclopedia.dart';
import '../../data/models/user.dart';
import '../../data/repositories/repositories.dart';
import '../../data/local/user_preferences.dart';
import '../../app/theme.dart';
import '../../utils/image_utils.dart';
import '../../l10n/generated/app_localizations.dart';

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
  List<ReptileSpecies> _allSpecies = [];
  bool _isLoading = true;
  UserLevel _userLevel = UserLevel.beginner;
  String _searchKeyword = '';
  bool _isSearching = false;

  // Categories will be populated from l10n

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    _userLevel = UserPreferences.getUserLevel();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getCategories(AppLocalizations l10n) {
    return [
      {'id': 'snake', 'name': l10n.snakes, 'icon': Icons.pest_control},
      {'id': 'lizard', 'name': l10n.lizards, 'icon': Icons.pets},
      {'id': 'turtle', 'name': l10n.turtles, 'icon': Icons.emoji_nature},
      {'id': 'gecko', 'name': l10n.geckos, 'icon': Icons.bug_report},
      {'id': 'amphibian', 'name': l10n.amphibians, 'icon': Icons.water},
      {'id': 'arachnid', 'name': l10n.spiders, 'icon': Icons.pest_control_rodent},
      {'id': 'insect', 'name': l10n.insects, 'icon': Icons.bug_report},
      {'id': 'mammal', 'name': l10n.mammals, 'icon': Icons.pets},
      {'id': 'bird', 'name': l10n.birds, 'icon': Icons.flutter_dash},
      {'id': 'fish', 'name': l10n.fish, 'icon': Icons.water},
    ];
  }

  Future<void> _loadData() async {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(l10n);
    setState(() => _isLoading = true);
    try {
      final species = await _repository.getAllSpecies();
      final grouped = <String, List<ReptileSpecies>>{};

      for (var cat in categories) {
        grouped[cat['id']!] = species
            .where((s) => s.category == cat['id'])
            .toList();
      }

      setState(() {
        _categorySpecies = grouped;
        _allSpecies = species;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.loadFailed}: $e')),
        );
      }
    }
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchKeyword = '';
    });
  }

  void _onSearchChanged(String value) {
    setState(() => _searchKeyword = value);
  }

  List<ReptileSpecies> _getFilteredSpecies() {
    if (_searchKeyword.isEmpty) return [];
    final kw = _searchKeyword.toLowerCase();
    return _allSpecies.where((s) {
      return s.nameChinese.toLowerCase().contains(kw) ||
          s.nameEnglish.toLowerCase().contains(kw) ||
          s.scientificName.toLowerCase().contains(kw);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(l10n);

    if (_isSearching) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _stopSearch,
          ),
          title: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: '搜索物种...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            style: const TextStyle(fontSize: 18),
            onChanged: _onSearchChanged,
          ),
          actions: [
            if (_searchKeyword.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _onSearchChanged(''),
              ),
          ],
        ),
        body: _buildSearchResults(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.encyclopedia),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showAdvancedFilter(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: categories.map((cat) => Tab(text: cat['name'] as String)).toList(),
        ),
      ),
      body: _isLoading
          ? Center(child: Text(l10n.loading))
          : TabBarView(
              controller: _tabController,
              children: categories.map((cat) {
                return _buildSpeciesList(cat['id'] as String);
              }).toList(),
            ),
    );
  }

  Widget _buildSearchResults() {
    final results = _getFilteredSpecies();
    if (_searchKeyword.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '输入关键词搜索物种',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '未找到相关物种',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildSpeciesCard(results[index]);
      },
    );
  }

  void _showAdvancedFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AdvancedFilterSheet(
        species: _allSpecies,
        onApply: (filters) {
          // 应用筛选
          setState(() {});
        },
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            species.nameChinese,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_isRecommended(species.difficulty))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '推荐',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
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

  // 判断物种是否适合当前用户等级
  bool _isRecommended(int difficulty) {
    final range = _userLevel.difficultyRange;
    return difficulty >= range[0] && difficulty <= range[1];
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

              // 食物推荐
              const Text(
                '食物推荐',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _getRecommendedFoods(species.diet).map((food) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.getCategoryColor(species.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.getCategoryColor(species.category).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getFoodIcon(food['icon']),
                          size: 16,
                          color: AppTheme.getCategoryColor(species.category),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          food['name'],
                          style: TextStyle(
                            color: AppTheme.getCategoryColor(species.category),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 喂食频率
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '喂食频率',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getFeedingFrequency(species.category),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 宠物挑选技巧
              const Text(
                '挑选技巧',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._getSelectionTips(species.category, species.diet).map((tip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // 开始挑选按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('请在"我的爬宠"中添加您的爬宠'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.checklist),
                  label: const Text('开始挑选'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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

  // 根据食性获取推荐食物
  List<Map<String, dynamic>> _getRecommendedFoods(String diet) {
    switch (diet) {
      case 'carnivore':
        return [
          {'name': '小白鼠', 'icon': 'pets'},
          {'name': '小鱼', 'icon': 'water'},
          {'name': '蟋蟀', 'icon': 'bug_report'},
          {'name': '面包虫', 'icon': 'bug_report'},
          {'name': '大麦虫', 'icon': 'bug_report'},
        ];
      case 'herbivore':
        return [
          {'name': '生菜', 'icon': 'eco'},
          {'name': '胡萝卜', 'icon': 'eco'},
          {'name': '油麦菜', 'icon': 'eco'},
          {'name': '水果', 'icon': 'apple'},
          {'name': '专用饲料', 'icon': 'restaurant'},
        ];
      case 'omnivore':
        return [
          {'name': '杂食饲料', 'icon': 'restaurant'},
          {'name': '蔬菜', 'icon': 'eco'},
          {'name': '水果', 'icon': 'apple'},
          {'name': '昆虫', 'icon': 'bug_report'},
          {'name': '专用饲料', 'icon': 'restaurant'},
        ];
      default:
        return [];
    }
  }

  // 获取喂食频率
  String _getFeedingFrequency(String category) {
    switch (category) {
      case 'snake':
        return '幼体每周2-3次，成体每周1次';
      case 'lizard':
        return '幼体每天1次，成体每2-3天1次';
      case 'turtle':
        return '幼体每天1次，成体每2-3天1次';
      case 'gecko':
        return '幼体每天1次，成体每2天1次';
      case 'amphibian':
        return '每2-3天1次';
      case 'arachnid':
        return '每周1-2次';
      case 'insect':
        return '每天供给果冻或水果';
      case 'mammal':
        return '每天1-2次';
      case 'bird':
        return '每天1-2次';
      case 'fish':
        return '每天1-2次，少量投喂';
      default:
        return '根据个体情况调整';
    }
  }

  // 获取食物图标
  IconData _getFoodIcon(String iconName) {
    switch (iconName) {
      case 'pets':
        return Icons.pets;
      case 'water':
        return Icons.water;
      case 'bug_report':
        return Icons.bug_report;
      case 'eco':
        return Icons.eco;
      case 'apple':
        return Icons.apple;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.restaurant;
    }
  }

  // 获取挑选技巧
  List<String> _getSelectionTips(String category, String diet) {
    // 通用技巧
    final commonTips = [
      '选择精神状态良好、反应灵敏的个体',
      '检查身体是否有明显外伤或异常',
      '优先选择人工繁殖的个体，更易饲养',
    ];

    switch (category) {
      case 'snake':
        return [
          ...commonTips,
          '选择体表光滑、无蜕皮不全的个体',
          '检查口腔是否有黏液或红肿',
          '选择进食后排便正常的个体',
          '幼蛇建议选择已经开食的',
        ];
      case 'lizard':
        return [
          ...commonTips,
          '检查四肢是否健全有力',
          '观察眼睛是否明亮、无分泌物',
          '选择皮肤完整、无外伤的个体',
          '鬃狮蜥建议选择体型饱满、互动性好的',
        ];
      case 'turtle':
        return [
          ...commonTips,
          '检查龟甲是否完整、无软甲现象',
          '选择四肢有力、挣扎活跃的个体',
          '观察鼻孔是否通畅、无分泌物',
          '选择眼睛明亮、反应灵敏的',
        ];
      case 'gecko':
        return [
          ...commonTips,
          '检查脚趾是否完整，无脱落',
          '观察尾巴是否完整（断尾影响品相）',
          '选择体型饱满、肌肉结实的',
          '守宫需检查趾垫是否完好',
        ];
      case 'amphibian':
        return [
          ...commonTips,
          '检查皮肤是否完整、无溃烂',
          '选择四肢健全、跳跃有力的',
          '观察眼睛是否凸起、明亮',
          '角蛙建议选择体型圆润、嘴巴大的',
        ];
      case 'arachnid':
        return [
          ...commonTips,
          '检查腹部是否饱满、无干瘪',
          '选择活力足、反应灵敏的',
          '检查螯肢和步足是否完整',
          '毒蜘蛛需确认品种和来源合法',
        ];
      case 'insect':
        return [
          ...commonTips,
          '选择鞘翅完整、肢体健全的',
          '检查体表无寄生虫',
          '成虫选择活力好的',
          '幼虫检查是否健康、无霉变',
        ];
      case 'mammal':
        return [
          ...commonTips,
          '检查毛发是否光滑、无秃斑',
          '选择眼睛明亮、无分泌物',
          '检查牙齿是否整齐、无咬合问题',
          '选择性格温顺、愿意互动的',
        ];
      case 'bird':
        return [
          ...commonTips,
          '检查羽毛是否完整、有光泽',
          '选择鸣叫清脆、反应灵敏的',
          '检查喙部是否正常、无变形',
          '选择脚爪健全、有力的',
        ];
      case 'fish':
        return [
          ...commonTips,
          '选择体色鲜艳、无褪色的',
          '检查鳞片是否完整、无脱落',
          '观察游姿是否正常、无侧翻',
          '选择活泼好动、抢食积极的',
        ];
      default:
        return commonTips;
    }
  }
}

// 高级筛选对话框
class _AdvancedFilterSheet extends StatefulWidget {
  final List<ReptileSpecies> species;
  final Function(Map<String, dynamic>) onApply;

  const _AdvancedFilterSheet({
    required this.species,
    required this.onApply,
  });

  @override
  State<_AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<_AdvancedFilterSheet> {
  int? _selectedDifficulty;
  String? _selectedDiet;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '高级筛选',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDifficulty = null;
                    _selectedDiet = null;
                    _selectedCategory = null;
                  });
                },
                child: const Text('重置'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 饲养难度筛选
          const Text(
            '饲养难度',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildChip(null, '全部', _selectedDifficulty),
              _buildChip(1, '简单', _selectedDifficulty),
              _buildChip(2, '中等', _selectedDifficulty),
              _buildChip(3, '较难', _selectedDifficulty),
              _buildChip(4, '困难', _selectedDifficulty),
            ],
          ),
          const SizedBox(height: 16),

          // 食性筛选
          const Text(
            '食性',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildDietChip(null, '全部', _selectedDiet),
              _buildDietChip('carnivore', '肉食性', _selectedDiet),
              _buildDietChip('herbivore', '草食性', _selectedDiet),
              _buildDietChip('omnivore', '杂食性', _selectedDiet),
            ],
          ),
          const SizedBox(height: 16),

          // 分类筛选
          const Text(
            '物种分类',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip(null, '全部', _selectedCategory),
              _buildCategoryChip('snake', '蛇类', _selectedCategory),
              _buildCategoryChip('gecko', '守宫', _selectedCategory),
              _buildCategoryChip('lizard', '蜥蜴', _selectedCategory),
              _buildCategoryChip('turtle', '龟类', _selectedCategory),
              _buildCategoryChip('amphibian', '两栖', _selectedCategory),
              _buildCategoryChip('arachnid', '蜘蛛', _selectedCategory),
            ],
          ),
          const SizedBox(height: 24),

          // 应用按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply({
                  'difficulty': _selectedDifficulty,
                  'diet': _selectedDiet,
                  'category': _selectedCategory,
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('应用筛选'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(int? value, String label, int? selected) {
    final isSelected = value == selected;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDifficulty = selected ? value : null;
        });
      },
    );
  }

  Widget _buildDietChip(String? value, String label, String? selected) {
    final isSelected = value == selected;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDiet = selected ? value : null;
        });
      },
    );
  }

  Widget _buildCategoryChip(String? value, String label, String? selected) {
    final isSelected = value == selected;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? value : null;
        });
      },
    );
  }
}
