import 'package:flutter/material.dart';
import '../../data/models/price.dart';
import '../../data/repositories/price_repository.dart';
import '../../app/theme.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PriceRepository _repository = PriceRepository();
  List<PetPrice> _prices = [];
  bool _isLoading = true;
  String _searchKeyword = '';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': '全部', 'icon': Icons.apps},
    {'id': 'snake', 'name': '蛇类', 'icon': Icons.pest_control},
    {'id': 'lizard', 'name': '蜥蜴', 'icon': Icons.pets},
    {'id': 'turtle', 'name': '龟类', 'icon': Icons.emoji_nature},
    {'id': 'gecko', 'name': '守宫', 'icon': Icons.bug_report},
    {'id': 'mammal', 'name': '哺乳', 'icon': Icons.pets},
    {'id': 'bird', 'name': '鸟类', 'icon': Icons.flutter_dash},
    {'id': 'fish', 'name': '鱼类', 'icon': Icons.water},
    {'id': 'insect', 'name': '昆虫', 'icon': Icons.bug_report},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
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
      final category = _categories[_tabController.index]['id'];
      List<PetPrice> result;
      if (_searchKeyword.isNotEmpty) {
        result = await _repository.searchPrices(_searchKeyword);
      } else {
        result = await _repository.getPricesByCategory(category);
      }
      setState(() {
        _prices = result;
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
        title: const Text('宠物行情'),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((cat) => Tab(text: cat['name'] as String)).toList(),
        ),
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索宠物品种...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _searchKeyword = value;
                _loadData();
              },
            ),
          ),
          // 价格列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _prices.isEmpty
                    ? _buildEmptyState()
                    : _buildPriceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _prices.length,
      itemBuilder: (context, index) {
        return _buildPriceCard(_prices[index]);
      },
    );
  }

  Widget _buildPriceCard(PetPrice price) {
    final trendColor = Color(price.trendColorValue);
    final trendIcon = price.trend == 'up'
        ? Icons.arrow_upward
        : price.trend == 'down'
            ? Icons.arrow_downward
            : Icons.remove;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 类别图标
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.getCategoryColor(price.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(price.category),
                color: AppTheme.getCategoryColor(price.category),
              ),
            ),
            const SizedBox(width: 12),
            // 名称和类别
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price.nameChinese,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price.nameEnglish,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '区间: ¥${price.minPrice.toInt()}-${price.maxPrice.toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // 价格和趋势
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥${price.currentPrice.toInt()}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, size: 14, color: trendColor),
                      const SizedBox(width: 2),
                      Text(
                        '${price.priceChange >= 0 ? '+' : ''}${price.priceChange.toInt()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
