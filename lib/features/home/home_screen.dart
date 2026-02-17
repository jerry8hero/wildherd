import 'package:flutter/material.dart';
import '../../data/models/reptile.dart';
import '../../data/models/user.dart';
import '../../data/models/encyclopedia.dart';
import '../../data/repositories/repositories.dart';
import '../../data/local/user_preferences.dart';
import '../../app/theme.dart';
import '../../utils/image_utils.dart';
import '../../widgets/empty_state.dart';
import '../settings/level_select_screen.dart';
import 'reptile_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReptileRepository _repository = ReptileRepository();
  final EncyclopediaRepository _encyclopediaRepository = EncyclopediaRepository();
  List<Reptile> _reptiles = [];
  List<ReptileSpecies> _recommendedSpecies = [];
  bool _isLoading = true;
  UserLevel _userLevel = UserLevel.beginner;

  @override
  void initState() {
    super.initState();
    _userLevel = UserPreferences.getUserLevel();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final reptiles = await _repository.getAllReptiles();
      final allSpecies = await _encyclopediaRepository.getAllSpecies();

      // 根据用户等级筛选推荐物种
      final difficultyRange = _userLevel.difficultyRange;
      final recommended = allSpecies.where((s) =>
        s.difficulty >= difficultyRange[0] && s.difficulty <= difficultyRange[1]
      ).take(5).toList();

      setState(() {
        _reptiles = reptiles;
        _recommendedSpecies = recommended;
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
        title: const Text('WildHerd'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LevelSelectScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 欢迎卡片
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),

                    // 我的宠物
                    _buildSectionTitle('我的宠物'),
                    const SizedBox(height: 12),
                    _buildPetsSection(),

                    const SizedBox(height: 20),

                    // 推荐物种
                    _buildSectionTitle('${_userLevel.displayName}推荐'),
                    const SizedBox(height: 12),
                    _buildRecommendedSpecies(),

                    const SizedBox(height: 20),

                    // 价格动态入口
                    _buildMarketCard(),

                    const SizedBox(height: 20),

                    // 快捷功能
                    _buildSectionTitle('快捷功能'),
                    const SizedBox(height: 12),
                    _buildQuickActions(),

                    const SizedBox(height: 20),

                    // 今日提醒
                    _buildSectionTitle('今日提醒'),
                    const SizedBox(height: 12),
                    _buildReminders(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '你好，WildHerd 爱好者！',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '共有 ${_reptiles.length} 只宠物',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPetsSection() {
    if (_reptiles.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.pets,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                '还没有添加宠物',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '点击下方"+"添加你的第一只宠物',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _reptiles.length,
        itemBuilder: (context, index) {
          final reptile = _reptiles[index];
          return _buildPetCard(reptile);
        },
      ),
    );
  }

  Widget _buildRecommendedSpecies() {
    if (_recommendedSpecies.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendedSpecies.length,
        itemBuilder: (context, index) {
          final species = _recommendedSpecies[index];
          return _buildRecommendedCard(species);
        },
      ),
    );
  }

  Widget _buildRecommendedCard(ReptileSpecies species) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () {
            // 可以跳转到百科详情
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.getCategoryColor(species.category),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
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
                const SizedBox(height: 8),
                Text(
                  species.nameChinese,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '难度${species.difficulty}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${species.lifespan}年',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(Reptile reptile) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReptileDetailScreen(reptile: reptile),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.getCategoryColor(reptile.species),
                  backgroundImage: reptile.imagePath != null && reptile.imagePath!.isNotEmpty
                      ? ImageUtils.getImageProvider(reptile.imagePath)
                      : null,
                  child: reptile.imagePath == null || reptile.imagePath!.isEmpty
                      ? const Icon(Icons.pets, color: Colors.white, size: 30)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  reptile.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  reptile.speciesChinese ?? reptile.species,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketCard() {
    return Card(
      child: InkWell(
        onTap: () {
          // 跳转到行情页面
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '价格动态',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '查看热门宠物价格走势',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.restaurant,
            title: '喂食记录',
            color: Colors.orange,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.medical_services,
            title: '健康记录',
            color: Colors.blue,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.camera_alt,
            title: '成长相册',
            color: Colors.purple,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminders() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReminderItem(
              icon: Icons.water_drop,
              title: '保持饲养箱湿度',
              subtitle: '注意观察宠物状态',
              color: Colors.blue,
            ),
            const Divider(),
            _buildReminderItem(
              icon: Icons.thermostat,
              title: '检查加热设备',
              subtitle: '确保温度适宜',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
