import 'package:flutter/material.dart';
import '../../data/models/price.dart';
import '../../data/models/price_alert.dart';
import '../../data/repositories/price_repository.dart';
import '../../data/repositories/price_alert_repository.dart';
import '../../app/theme.dart';
import '../../l10n/generated/app_localizations.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PriceRepository _repository = PriceRepository();
  final PriceAlertRepository _alertRepository = PriceAlertRepository();
  List<PetPrice> _prices = [];
  bool _isLoading = true;
  String _searchKeyword = '';
  Map<String, bool> _alertStatus = {}; // 记录哪些物种已设置提醒

  // 默认 categories（用于 initState，build 中会从 l10n 重新获取）
  final List<Map<String, dynamic>> _defaultCategories = [
    {'id': 'all', 'name': '全部', 'icon': Icons.apps},
    {'id': 'snake', 'name': '蛇类', 'icon': Icons.pest_control},
    {'id': 'lizard', 'name': '蜥蜴', 'icon': Icons.pets},
    {'id': 'turtle', 'name': '龟类', 'icon': Icons.emoji_nature},
    {'id': 'gecko', 'name': '守宫', 'icon': Icons.bug_report},
    {'id': 'mammal', 'name': '哺乳类', 'icon': Icons.pets},
    {'id': 'bird', 'name': '鸟类', 'icon': Icons.flutter_dash},
    {'id': 'fish', 'name': '鱼类', 'icon': Icons.water},
    {'id': 'insect', 'name': '昆虫', 'icon': Icons.bug_report},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _defaultCategories.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
    _loadAlertStatus();
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

  List<Map<String, dynamic>> _getCategories(AppLocalizations l10n) {
    return [
      {'id': 'all', 'name': l10n.category, 'icon': Icons.apps},
      {'id': 'snake', 'name': l10n.snakes, 'icon': Icons.pest_control},
      {'id': 'lizard', 'name': l10n.lizards, 'icon': Icons.pets},
      {'id': 'turtle', 'name': l10n.turtles, 'icon': Icons.emoji_nature},
      {'id': 'gecko', 'name': l10n.geckos, 'icon': Icons.bug_report},
      {'id': 'mammal', 'name': l10n.mammals, 'icon': Icons.pets},
      {'id': 'bird', 'name': l10n.birds, 'icon': Icons.flutter_dash},
      {'id': 'fish', 'name': l10n.fish, 'icon': Icons.water},
      {'id': 'insect', 'name': l10n.insects, 'icon': Icons.bug_report},
    ];
  }

  Future<void> _loadData() async {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(l10n);
    setState(() => _isLoading = true);
    try {
      final category = categories[_tabController.index]['id'];
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
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.market),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: categories.map((cat) => Tab(text: cat['name'] as String)).toList(),
        ),
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchPet,
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
                ? Center(child: Text(l10n.loading))
                : _prices.isEmpty
                    ? _buildEmptyState(l10n)
                    : _buildPriceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            l10n.noData,
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
    final hasAlert = _alertStatus[price.speciesId] ?? false;

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
                color: AppTheme.getCategoryColor(price.category).withValues(alpha: 0.1),
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
                    color: trendColor.withValues(alpha: 0.1),
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
            const SizedBox(width: 8),
            // 提醒按钮
            IconButton(
              icon: Icon(
                hasAlert ? Icons.notifications_active : Icons.notifications_none,
                color: hasAlert ? Colors.orange : Colors.grey,
              ),
              onPressed: () => _showAlertDialog(price),
              tooltip: '设置降价提醒',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAlertStatus() async {
    final alerts = await _alertRepository.getAllAlerts();
    setState(() {
      _alertStatus = {for (var a in alerts) a.speciesId: true};
    });
  }

  void _showAlertDialog(PetPrice price) {
    final controller = TextEditingController(
      text: (price.currentPrice * 0.9).toInt().toString(),
    );
    String alertType = 'custom';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('设置 ${price.nameChinese} 降价提醒'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当前价格: ¥${price.currentPrice.toInt()}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '历史最低价: ¥${price.minPrice.toInt()}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                '提醒类型:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              RadioListTile<String>(
                title: const Text('自定义目标价'),
                value: 'custom',
                groupValue: alertType,
                onChanged: (value) {
                  setDialogState(() => alertType = value!);
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                title: const Text('低于历史最低价'),
                subtitle: Text('¥${price.minPrice.toInt()}', style: const TextStyle(fontSize: 12)),
                value: 'lowest',
                groupValue: alertType,
                onChanged: (value) {
                  setDialogState(() => alertType = value!);
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              if (alertType == 'custom') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '目标价格 (¥)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                double targetPrice;
                if (alertType == 'lowest') {
                  targetPrice = price.minPrice;
                } else {
                  targetPrice = double.tryParse(controller.text) ?? price.currentPrice;
                }

                final alert = PriceAlert(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  speciesId: price.speciesId,
                  speciesName: price.nameChinese,
                  speciesNameEnglish: price.nameEnglish,
                  targetPrice: targetPrice,
                  alertType: alertType,
                  isEnabled: true,
                  createdAt: DateTime.now(),
                  currentPrice: price.currentPrice,
                  lowestPrice: price.minPrice,
                );

                // 检查是否已存在提醒
                final existingAlert = await _alertRepository.getAlertBySpecies(price.speciesId);
                if (existingAlert != null) {
                  // 更新已有提醒
                  await _alertRepository.updateAlert(alert.copyWith(id: existingAlert.id));
                } else {
                  // 添加新提醒
                  await _alertRepository.addAlert(alert);
                }

                if (!mounted) return;
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                _loadAlertStatus();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('已设置 ${price.nameChinese} 的降价提醒'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('保存'),
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
