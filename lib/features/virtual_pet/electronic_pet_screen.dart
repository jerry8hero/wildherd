// 电子宠物主界面 - Tamagotchi 风格

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/electronic_pet.dart';
import '../../data/models/pet_item.dart';
import '../../data/models/pet_evolution.dart';
import '../../data/services/pet_game_service.dart';
import '../../app/theme.dart';

class ElectronicPetScreen extends StatefulWidget {
  const ElectronicPetScreen({super.key});

  @override
  State<ElectronicPetScreen> createState() => _ElectronicPetScreenState();
}

class _ElectronicPetScreenState extends State<ElectronicPetScreen> {
  final PetGameManager _manager = PetGameManager();
  List<ElectronicPet> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    await _manager.init();
    setState(() {
      _pets = _manager.getAllPets();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('电子宠物'),
        actions: [
          // 金币显示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${_manager.coins}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () => _showShop(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pets.isEmpty
              ? _buildEmptyState()
              : _buildPetList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPetDialog(),
        icon: const Icon(Icons.add),
        label: const Text('领养宠物'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.egg,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '还没有电子宠物',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '领养一只电子宠物开始养成之旅',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddPetDialog(),
            icon: const Icon(Icons.add),
            label: const Text('领养宠物'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pets.length,
      itemBuilder: (context, index) {
        return _buildPetCard(_pets[index]);
      },
    );
  }

  Widget _buildPetCard(ElectronicPet pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPetDetail(pet),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 宠物头部区域（Tamagotchi 风格）
              _buildPetAvatar(pet),
              const SizedBox(height: 12),

              // 宠物名称和等级
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pet.nickname ?? pet.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getLevelColor(pet.level).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Lv.${pet.level}',
                      style: TextStyle(
                        color: _getLevelColor(pet.level),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '${pet.name} ${pet.getEvolutionStageText()}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // 心情显示
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pet.getMoodEmoji(),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pet.getMoodText(),
                    style: TextStyle(
                      color: _getMoodColor(pet.mood),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 状态条
              _buildStatusBars(pet),
              const SizedBox(height: 16),

              // 快捷操作
              _buildActionButtons(pet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetAvatar(ElectronicPet pet) {
    // 根据外观状态显示不同的图标
    IconData icon;
    Color bgColor = AppTheme.categoryColors[pet.speciesId] ?? AppTheme.primaryColor;

    switch (pet.appearance) {
      case PetAppearance.happy:
        icon = Icons.sentiment_very_satisfied;
        break;
      case PetAppearance.sad:
        icon = Icons.sentiment_dissatisfied;
        break;
      case PetAppearance.sick:
        icon = Icons.sick;
        break;
      case PetAppearance.sleeping:
        icon = Icons.bedtime;
        break;
      case PetAppearance.eating:
        icon = Icons.restaurant;
        break;
      case PetAppearance.playing:
        icon = Icons.sports_esports;
        break;
      default:
        icon = Icons.pets;
    }

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: bgColor,
              width: 3,
            ),
          ),
          child: Icon(
            icon,
            size: 50,
            color: bgColor,
          ),
        ),
        // 进化阶段标识
        if (pet.evolutionStage.index > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBars(ElectronicPet pet) {
    return Column(
      children: [
        _buildStatusBar(
          '❤️ 健康',
          pet.healthScore,
          _getHealthColor(pet.healthScore),
        ),
        const SizedBox(height: 8),
        _buildStatusBar(
          '😊 快乐',
          pet.happiness,
          _getHappinessColor(pet.happiness),
        ),
        const SizedBox(height: 8),
        _buildStatusBar(
          '🍔 饱食',
          100 - pet.hunger,
          _getHungerColor(100 - pet.hunger),
        ),
        const SizedBox(height: 8),
        _buildStatusBar(
          '✨ 清洁',
          pet.cleanliness,
          _getCleanlinessColor(pet.cleanliness),
        ),
        const SizedBox(height: 8),
        // 经验条
        _buildExpBar(pet),
      ],
    );
  }

  Widget _buildStatusBar(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '$value%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildExpBar(ElectronicPet pet) {
    final expProgress = pet.getLevelProgress();
    final expNeeded = pet.getExperienceToNextLevel();

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '⭐ 经验',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: expProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.amber[100],
              valueColor: AlwaysStoppedAnimation(Colors.amber),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            '${pet.experience}/$expNeeded',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.amber[700],
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ElectronicPet pet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          Icons.restaurant,
          '喂食',
          () => _feedPet(pet),
          Colors.orange,
        ),
        _buildActionButton(
          Icons.cleaning_services,
          '清洁',
          () => _cleanPet(pet),
          Colors.blue,
        ),
        _buildActionButton(
          Icons.sports_esports,
          '互动',
          () => _playWithPet(pet),
          Colors.purple,
        ),
        _buildActionButton(
          Icons.auto_awesome,
          '进化',
          () => _tryEvolve(pet),
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(int value) {
    if (value >= 80) return Colors.green;
    if (value >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getHappinessColor(int value) {
    if (value >= 80) return Colors.green;
    if (value >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getHungerColor(int value) {
    if (value >= 70) return Colors.green;
    if (value >= 40) return Colors.orange;
    return Colors.red;
  }

  Color _getCleanlinessColor(int value) {
    if (value >= 80) return Colors.green;
    if (value >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getMoodColor(PetMood mood) {
    switch (mood) {
      case PetMood.happy:
        return Colors.green;
      case PetMood.normal:
        return Colors.blue;
      case PetMood.sad:
        return Colors.orange;
      case PetMood.restless:
        return Colors.red;
      case PetMood.sick:
        return Colors.red;
    }
  }

  Color _getLevelColor(int level) {
    if (level >= 40) return Colors.purple;
    if (level >= 30) return Colors.amber;
    if (level >= 20) return Colors.orange;
    if (level >= 10) return Colors.green;
    return Colors.blue;
  }

  void _feedPet(ElectronicPet pet) async {
    final result = await _manager.feedPet(pet.id);
    if (result != null) {
      _loadPets();
      _showActionResult('喂食成功！', Icons.restaurant, Colors.orange);
    }
  }

  void _cleanPet(ElectronicPet pet) async {
    final result = await _manager.cleanPet(pet.id);
    if (result != null) {
      _loadPets();
      _showActionResult('清洁完成！', Icons.cleaning_services, Colors.blue);
    }
  }

  void _playWithPet(ElectronicPet pet) async {
    final result = await _manager.playWithPet(pet.id);
    if (result != null) {
      _loadPets();
      _showActionResult('互动开心！', Icons.sports_esports, Colors.purple);
    }
  }

  void _tryEvolve(ElectronicPet pet) async {
    final evolutionLine = PetEvolutionData.getEvolutionLine(pet.speciesId);
    if (evolutionLine == null) {
      _showMessage('该宠物没有进化路线');
      return;
    }

    if (!PetEvolutionData.canEvolve(pet, evolutionLine)) {
      final nextStage = PetEvolutionData.getNextStage(evolutionLine, pet.evolutionStage);
      if (nextStage != null) {
        _showMessage('进化条件：等级 ${nextStage.requiredLevel}，年龄 ${nextStage.requiredDays} 天');
      } else {
        _showMessage('宠物已达到最终形态');
      }
      return;
    }

    final result = await _manager.tryEvolve(pet.id);
    if (result != null) {
      _loadPets();
      _showActionResult('🎉 进化成功！', Icons.auto_awesome, Colors.amber);
    }
  }

  void _showActionResult(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPetDetail(ElectronicPet pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PetDetailSheet(
        pet: pet,
        onUpdate: _loadPets,
      ),
    );
  }

  void _showAddPetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('领养电子宠物'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: ListView(
            shrinkWrap: true,
            children: [
              // 蛇类
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('🐍 蛇类', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildPetOption('玉米蛇', 'corn_snake', Icons.pets, Colors.purple),
              _buildPetOption('球蟒', 'ball_python', Icons.pets, Colors.purple),
              _buildPetOption('黑王蛇', 'black_kingsnake', Icons.pets, Colors.grey),
              _buildPetOption('奶蛇', 'milk_snake', Icons.pets, Colors.red),
              _buildPetOption('猪鼻蛇', 'hognose_snake', Icons.pets, Colors.brown),

              // 守宫
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('🦎 守宫', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildPetOption('豹纹守宫', 'leopard_gecko', Icons.pets, Colors.orange),
              _buildPetOption('睫角守宫', 'crested_gecko', Icons.pets, Colors.orange),

              // 蜥蜴
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('🦎 蜥蜴', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildPetOption('鬃狮蜥', 'bearded_dragon', Icons.pets, Colors.green),
              _buildPetOption('绿鬣蜥', 'green_iguana', Icons.pets, Colors.green),
              _buildPetOption('蓝舌石龙子', 'blue_tongue_skink', Icons.pets, Colors.blueGrey),
              _buildPetOption('高冠变色龙', 'veiled_chameleon', Icons.pets, Colors.teal),

              // 龟类
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('🐢 龟类', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildPetOption('草龟', 'chinese_turtle', Icons.pets, Colors.blue),
              _buildPetOption('红耳龟', 'red_eared_slider', Icons.pets, Colors.blue),
              _buildPetOption('黄缘闭壳龟', 'yellow_marginated_box_turtle', Icons.pets, Colors.amber),
              _buildPetOption('锯缘摄龟', 'keeled_box_turtle', Icons.pets, Colors.brown),
              _buildPetOption('辐射陆龟', 'radiated_tortoise', Icons.pets, Colors.green),
              _buildPetOption('赫曼陆龟', 'hermanns_tortoise', Icons.pets, Colors.yellow),

              // 两栖
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('🐸 两栖', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildPetOption('角蛙', 'pacman_frog', Icons.pets, Colors.green),
              _buildPetOption('蝾螈', 'axolotl', Icons.pets, Colors.pink),

              // 蜘蛛
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('🕷️ 蜘蛛', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildPetOption('智利红玫瑰', 'chilean_rose_tarantula', Icons.pets, Colors.red),
              _buildPetOption('墨西哥红膝', 'mexican_red_knee', Icons.pets, Colors.deepOrange),
              _buildPetOption('巴西白膝头', 'brazilian_white_knee', Icons.pets, Colors.white),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Widget _buildPetOption(String name, String speciesId, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        _addPet(name, speciesId);
      },
    );
  }

  void _addPet(String name, String speciesId) async {
    await _manager.addPet(
      speciesId: speciesId,
      name: name,
      nickname: '小$name',
    );
    _loadPets();
    _showMessage('恭喜领养 ${name}！');
  }

  void _showShop() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ShopSheet(
        manager: _manager,
        onPurchase: _loadPets,
      ),
    );
  }
}

// 宠物详情弹窗
class _PetDetailSheet extends StatelessWidget {
  final ElectronicPet pet;
  final VoidCallback onUpdate;

  const _PetDetailSheet({required this.pet, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖动手柄
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

            // 宠物信息
            Center(
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 12),
                  Text(
                    pet.nickname ?? pet.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${pet.name} ${pet.getEvolutionStageText()} · ${pet.getGrowthStageText()}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 基本信息
            _buildInfoSection(),
            const SizedBox(height: 24),

            // 状态
            _buildStatusSection(),
            const SizedBox(height: 24),

            // 统计
            _buildStatsSection(),
            const SizedBox(height: 24),

            // 成就
            _buildAchievementsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    IconData icon;
    Color bgColor = AppTheme.categoryColors[pet.speciesId] ?? AppTheme.primaryColor;

    switch (pet.appearance) {
      case PetAppearance.happy:
        icon = Icons.sentiment_very_satisfied;
        break;
      case PetAppearance.sad:
        icon = Icons.sentiment_dissatisfied;
        break;
      case PetAppearance.sick:
        icon = Icons.sick;
        break;
      case PetAppearance.sleeping:
        icon = Icons.bedtime;
        break;
      default:
        icon = Icons.pets;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: bgColor, width: 3),
      ),
      child: Icon(icon, size: 50, color: bgColor),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 基本信息',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('等级', 'Lv.${pet.level}'),
        _buildInfoRow('年龄', pet.getAge()),
        _buildInfoRow('性别', pet.gender == 'male' ? '公' : pet.gender == 'female' ? '母' : '未知'),
        _buildInfoRow('成长阶段', pet.getGrowthStageText()),
        _buildInfoRow('进化阶段', pet.getEvolutionStageText()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💪 状态',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildStatusRow('健康度', pet.healthScore, _getHealthColor(pet.healthScore)),
        _buildStatusRow('快乐度', pet.happiness, _getHappinessColor(pet.happiness)),
        _buildStatusRow('饱食度', 100 - pet.hunger, _getHungerColor(100 - pet.hunger)),
        _buildStatusRow('清洁度', pet.cleanliness, _getCleanlinessColor(pet.cleanliness)),
      ],
    );
  }

  Widget _buildStatusRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$value%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 统计',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('总喂食次数', '${pet.totalFed}'),
        _buildInfoRow('总互动次数', '${pet.totalPlayed}'),
        _buildInfoRow('总清洁次数', '${pet.totalCleaned}'),
        _buildInfoRow('累计经验', '${pet.totalExperience}'),
        _buildInfoRow('存活天数', '${pet.daysAlive}'),
        _buildInfoRow('连续健康天数', '${pet.consecutiveHealthyDays}'),
      ],
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🏆 成就',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${pet.unlockedAchievements.length} 个',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pet.unlockedAchievements.take(10).map((id) {
            return Chip(
              avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
              label: Text(id, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.amber.withValues(alpha: 0.1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getHealthColor(int value) {
    if (value >= 80) return Colors.green;
    if (value >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getHappinessColor(int value) {
    if (value >= 80) return Colors.green;
    if (value >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getHungerColor(int value) {
    if (value >= 70) return Colors.green;
    if (value >= 40) return Colors.orange;
    return Colors.red;
  }

  Color _getCleanlinessColor(int value) {
    if (value >= 80) return Colors.green;
    if (value >= 50) return Colors.orange;
    return Colors.red;
  }
}

// 商店弹窗
class _ShopSheet extends StatefulWidget {
  final PetGameManager manager;
  final VoidCallback onPurchase;

  const _ShopSheet({required this.manager, required this.onPurchase});

  @override
  State<_ShopSheet> createState() => _ShopSheetState();
}

class _ShopSheetState extends State<_ShopSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // 头部
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.store, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '宠物商店',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.manager.coins}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 标签页
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: '食物'),
              Tab(text: '药品'),
              Tab(text: '进化'),
              Tab(text: '增益'),
            ],
          ),

          // 内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItemList(ItemData.getFoodItems()),
                _buildItemList(ItemData.getMedicineItems()),
                _buildItemList(ItemData.getEvolutionItems()),
                _buildItemList(ItemData.getByType(ItemType.buff)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(List<PetItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getItemIcon(item.iconName),
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(item.name),
            subtitle: Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${item.price}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.manager.coins >= item.price
                      ? () => _purchaseItem(item)
                      : null,
                  child: const Text('购买'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getItemIcon(String? iconName) {
    switch (iconName) {
      case 'pest_control':
        return Icons.pest_control;
      case 'bug_report':
        return Icons.bug_report;
      case 'eco':
        return Icons.eco;
      case 'nutrition':
        return Icons.nutrition;
      case 'diamond':
        return Icons.diamond;
      case 'local_drink':
        return Icons.local_drink;
      case 'science':
        return Icons.science;
      case 'healing':
        return Icons.healing;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'biotech':
        return Icons.biotech;
      case 'dark_mode':
        return Icons.dark_mode;
      case 'texture':
        return Icons.texture;
      case 'sentiment_satisfied':
        return Icons.sentiment_satisfied;
      case 'water_drop':
        return Icons.water_drop;
      case 'bolt':
        return Icons.bolt;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.category;
    }
  }

  void _purchaseItem(PetItem item) async {
    final success = await widget.manager.purchaseItem(item.id);
    if (success) {
      widget.onPurchase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('购买 ${item.name} 成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('金币不足！'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
