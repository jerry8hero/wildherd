import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/reptile.dart';
import '../../data/repositories/repositories.dart';
import '../../app/theme.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final ReptileRepository _repository = ReptileRepository();
  List<Reptile> _reptiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final reptiles = await _repository.getAllReptiles();
      setState(() {
        _reptiles = reptiles;
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

  Future<void> _addReptile() async {
    final result = await showModalBottomSheet<Reptile>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddReptileSheet(),
    );

    if (result != null) {
      await _repository.addReptile(result);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的爬宠'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reptiles.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reptiles.length,
                    itemBuilder: (context, index) {
                      return _buildReptileCard(_reptiles[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReptile,
        child: const Icon(Icons.add),
      ),
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
            '还没有爬宠',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角添加你的爬宠',
            style: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReptileCard(Reptile reptile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.getCategoryColor(reptile.species),
                backgroundImage: reptile.imagePath != null
                    ? AssetImage(reptile.imagePath!)
                    : null,
                child: reptile.imagePath == null
                    ? const Icon(Icons.pets, color: Colors.white, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reptile.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reptile.speciesChinese ?? reptile.species} • ${reptile.gender ?? "未知性别"}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (reptile.birthDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatAge(reptile.birthDate!),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除 ${reptile.name} 吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('删除'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _repository.deleteReptile(reptile.id);
                      _loadData();
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'delete', child: Text('删除')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.difference(birthDate);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;

    if (years > 0) {
      return '$years 岁 ${months > 0 ? "$months 个月" : ""}';
    } else if (months > 0) {
      return '$months 个月';
    } else {
      return '${age.inDays} 天';
    }
  }
}

// 添加爬宠底部表单
class AddReptileSheet extends StatefulWidget {
  const AddReptileSheet({super.key});

  @override
  State<AddReptileSheet> createState() => _AddReptileSheetState();
}

class _AddReptileSheetState extends State<AddReptileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;
  final _weightController = TextEditingController();

  // 常见爬宠种类
  final List<Map<String, String>> _commonSpecies = [
    {'species': 'corn_snake', 'name': '玉米蛇'},
    {'species': 'ball_python', 'name': '球蟒'},
    {'species': 'leopard_gecko', 'name': '豹纹守宫'},
    {'species': 'bearded_dragon', 'name': '鬃狮蜥'},
    {'species': 'green_iguana', 'name': '绿鬣蜥'},
    {'species': 'red_eared_slider', 'name': '红耳龟'},
    {'species': 'crested_gecko', 'name': '睫角守宫'},
    {'species': 'blue_tongue_skink', 'name': '蓝舌石龙子'},
    {'species': 'other', 'name': '其他'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '添加爬宠',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // 名字
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名字',
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? '请输入名字' : null,
              ),
              const SizedBox(height: 16),

              // 种类
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '种类',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _commonSpecies.map((species) {
                  return DropdownMenuItem(
                    value: species['species'],
                    child: Text(species['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  _speciesController.text = value ?? '';
                },
                validator: (value) =>
                    value?.isEmpty == true ? '请选择种类' : null,
              ),
              const SizedBox(height: 16),

              // 性别
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: '性别',
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(value: '雄性', child: Text('雄性')),
                  DropdownMenuItem(value: '雌性', child: Text('雌性')),
                  DropdownMenuItem(value: '未知', child: Text('未知')),
                ],
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                },
              ),
              const SizedBox(height: 16),

              // 出生日期
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '出生日期',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}'
                        : '选择日期',
                    style: TextStyle(
                      color: _selectedDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 体重
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '体重 (g)',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
              ),
              const SizedBox(height: 24),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('添加'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      final species = _commonSpecies.firstWhere(
        (s) => s['species'] == _speciesController.text,
        orElse: () => _commonSpecies.last,
      );

      final reptile = Reptile(
        id: const Uuid().v4(),
        name: _nameController.text,
        species: _speciesController.text,
        speciesChinese: species['name'],
        gender: _selectedGender,
        birthDate: _selectedDate,
        weight: double.tryParse(_weightController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      Navigator.pop(context, reptile);
    }
  }
}
