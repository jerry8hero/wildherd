import 'package:flutter/material.dart';
import '../../data/models/virtual_pet.dart';
import '../../utils/virtual_pet_manager.dart';
import '../../app/theme.dart';

class VirtualPetScreen extends StatefulWidget {
  const VirtualPetScreen({super.key});

  @override
  State<VirtualPetScreen> createState() => _VirtualPetScreenState();
}

class _VirtualPetScreenState extends State<VirtualPetScreen> {
  final VirtualPetManager _manager = VirtualPetManager();
  List<VirtualPet> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    await _manager.init();
    // 添加一些示例宠物
    if (_manager.getPetCount() == 0) {
      await _addSamplePets();
    }
    setState(() {
      _pets = _manager.getAllPets();
      _isLoading = false;
    });
  }

  Future<void> _addSamplePets() async {
    final samplePets = [
      VirtualPet(
        id: 'v1',
        speciesId: '1',
        name: '玉米蛇',
        nickname: '小玉米',
        birthDate: DateTime.now().subtract(const Duration(days: 180)),
        gender: 'male',
        acquiredDate: DateTime.now().subtract(const Duration(days: 90)),
        lastFed: DateTime.now().subtract(const Duration(hours: 6)),
        lastCleaned: DateTime.now().subtract(const Duration(days: 1)),
        lastPlayed: DateTime.now().subtract(const Duration(hours: 12)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      VirtualPet(
        id: 'v2',
        speciesId: '3',
        name: '豹纹守宫',
        nickname: '小布',
        birthDate: DateTime.now().subtract(const Duration(days: 365)),
        gender: 'female',
        acquiredDate: DateTime.now().subtract(const Duration(days: 60)),
        lastFed: DateTime.now().subtract(const Duration(hours: 18)),
        lastCleaned: DateTime.now().subtract(const Duration(days: 2)),
        lastPlayed: DateTime.now().subtract(const Duration(hours: 36)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var pet in samplePets) {
      await _manager.addPet(pet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('虚拟养宠'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPetDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pets.isEmpty
              ? _buildEmptyState()
              : _buildPetList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '还没有虚拟宠物',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '添加一只虚拟宠物开始养成',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddPetDialog(),
            icon: const Icon(Icons.add),
            label: const Text('添加宠物'),
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

  Widget _buildPetCard(VirtualPet pet) {
    final healthColor = _getHealthColor(pet.healthScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPetDetail(pet),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部信息
              Row(
                children: [
                  // 宠物头像
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.getCategoryColor('snake'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.pets, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  // 宠物信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.nickname ?? pet.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${pet.name} · ${pet.getAge()} · ${pet.gender == 'male' ? '公' : pet.gender == 'female' ? '母' : '未知'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 状态指示
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, size: 14, color: healthColor),
                        const SizedBox(width: 4),
                        Text(
                          '${pet.healthScore}%',
                          style: TextStyle(
                            color: healthColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 状态条
              Row(
                children: [
                  Expanded(
                    child: _buildStatusBar(
                      '饱食度',
                      100 - pet.hunger,
                      pet.getHungerStatus() == '饥饿' ? Colors.orange : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusBar(
                      '快乐度',
                      pet.happiness,
                      pet.happiness >= 80 ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusBar(
                      '健康度',
                      pet.healthScore,
                      healthColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 快捷操作
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    Icons.restaurant,
                    '喂食',
                    () => _feedPet(pet),
                  ),
                  _buildActionButton(
                    Icons.cleaning_services,
                    '清洁',
                    () => _cleanPet(pet),
                  ),
                  _buildActionButton(
                    Icons.sports_esports,
                    '互动',
                    () => _playWithPet(pet),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
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

  Color _getHealthColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  void _feedPet(VirtualPet pet) async {
    await _manager.feedPet(pet.id);
    _loadPets();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pet.nickname ?? pet.name} 喂食完成！')),
      );
    }
  }

  void _cleanPet(VirtualPet pet) async {
    await _manager.cleanPet(pet.id);
    _loadPets();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pet.nickname ?? pet.name} 清洁完成！')),
      );
    }
  }

  void _playWithPet(VirtualPet pet) async {
    await _manager.playWithPet(pet.id);
    _loadPets();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pet.nickname ?? pet.name} 互动完成，好开心！')),
      );
    }
  }

  void _showPetDetail(VirtualPet pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PetDetailSheet(pet: pet),
    );
  }

  void _showAddPetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加虚拟宠物'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('玉米蛇'),
              onTap: () {
                Navigator.pop(context);
                _addVirtualPet('玉米蛇', 'snake');
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('豹纹守宫'),
              onTap: () {
                Navigator.pop(context);
                _addVirtualPet('豹纹守宫', 'gecko');
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('鬃狮蜥'),
              onTap: () {
                Navigator.pop(context);
                _addVirtualPet('鬃狮蜥', 'lizard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('绿鬣蜥'),
              onTap: () {
                Navigator.pop(context);
                _addVirtualPet('绿鬣蜥', 'lizard');
              },
            ),
          ],
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

  void _addVirtualPet(String name, String category) async {
    final pet = VirtualPet(
      id: 'v${DateTime.now().millisecondsSinceEpoch}',
      speciesId: '0',
      name: name,
      nickname: '小${name[0]}',
      birthDate: DateTime.now().subtract(const Duration(days: 30)),
      gender: 'unknown',
      acquiredDate: DateTime.now(),
      lastFed: DateTime.now(),
      lastCleaned: DateTime.now(),
      lastPlayed: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _manager.addPet(pet);
    _loadPets();
  }
}

// 宠物详情弹窗
class _PetDetailSheet extends StatelessWidget {
  final VirtualPet pet;

  const _PetDetailSheet({required this.pet});

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
            // 头部
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
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.getCategoryColor('snake'),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.pets, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.nickname ?? pet.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pet.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 基本信息
            _buildInfoRow('年龄', pet.getAge()),
            _buildInfoRow('性别', pet.gender == 'male' ? '公' : pet.gender == 'female' ? '母' : '未知'),
            _buildInfoRow('获得日期', '${pet.acquiredDate.year}-${pet.acquiredDate.month}-${pet.acquiredDate.day}'),
            if (pet.morph != null) _buildInfoRow('品系', pet.morph!),
            const SizedBox(height: 24),
            // 状态
            const Text(
              '状态',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusRow('饱食度', 100 - pet.hunger),
            _buildStatusRow('快乐度', pet.happiness),
            _buildStatusRow('健康度', pet.healthScore),
            const SizedBox(height: 24),
            // 最后活动时间
            const Text(
              '最近活动',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildActivityRow(Icons.restaurant, '上次喂食', _formatTime(pet.lastFed)),
            _buildActivityRow(Icons.cleaning_services, '上次清洁', _formatTime(pet.lastCleaned)),
            _buildActivityRow(Icons.sports_esports, '上次互动', _formatTime(pet.lastPlayed)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int value) {
    Color color;
    if (value >= 80) {
      color = Colors.green;
    } else if (value >= 50) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

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

  Widget _buildActivityRow(IconData icon, String label, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const Spacer(),
          Text(time, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else {
      return '${diff.inDays}天前';
    }
  }
}
