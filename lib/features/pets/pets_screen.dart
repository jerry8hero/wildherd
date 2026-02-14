import 'package:flutter/material.dart';
import '../../data/models/reptile.dart';
import '../../data/repositories/repositories.dart';
import '../../app/theme.dart';

// 爬宠分类数据模型
class ReptileCategory {
  final String name;
  final String icon;
  final List<Map<String, String>> species;

  const ReptileCategory({
    required this.name,
    required this.icon,
    required this.species,
  });
}

// 爬宠种类分类（按大类分组）
final List<ReptileCategory> reptileCategories = [
  // 蛇类
  ReptileCategory(
    name: '蛇类',
    icon: '🐍',
    species: [
      {'species': 'corn_snake', 'name': '玉米蛇'},
      {'species': 'ball_python', 'name': '球蟒'},
      {'species': 'black_rat_snake', 'name': '黑王蛇'},
      {'species': 'milk_snake', 'name': '奶蛇'},
      {'species': 'hognose_snake', 'name': '猪鼻蛇'},
      {'species': 'king_snake', 'name': '国王蛇'},
      {'species': 'gopher_snake', 'name': '草原鼠蛇'},
      {'species': 'bull_snack', 'name': '牛蛇'},
      {'species': 'pine_snake', 'name': '松蛇'},
      {'species': 'other_snake', 'name': '其他蛇类'},
    ],
  ),
  // 守宫类
  ReptileCategory(
    name: '守宫类',
    icon: '🦎',
    species: [
      {'species': 'leopard_gecko', 'name': '豹纹守宫'},
      {'species': 'crested_gecko', 'name': '睫角守宫'},
      {'species': 'giant_gecko', 'name': '巨人守宫'},
      {'species': 'leachie_gecko', 'name': '盖勾亚守宫'},
      {'species': 'satanic_leaf_gecko', 'name': '撒旦叶尾守宫'},
      {'species': 'frog_eyed_gecko', 'name': '猫守宫'},
      {'species': 'other_gecko', 'name': '其他守宫'},
    ],
  ),
  // 蜥蜴类
  ReptileCategory(
    name: '蜥蜴类',
    icon: '🦎',
    species: [
      {'species': 'bearded_dragon', 'name': '鬃狮蜥'},
      {'species': 'green_iguana', 'name': '绿鬣蜥'},
      {'species': 'blue_tongue_skink', 'name': '蓝舌石龙子'},
      {'species': 'chameleon', 'name': '变色龙'},
      {'species': 'uromastyx', 'name': '王者蜥'},
      {'species': 'water_dragon', 'name': '水龙'},
      {'species': 'chinese_water_dragon', 'name': '中国水龙'},
      {'species': 'monitor_lizard', 'name': '巨蜥'},
      {'species': 'gila_monster', 'name': '毒蜥'},
      {'species': 'other_lizard', 'name': '其他蜥蜴'},
    ],
  ),
  // 龟类 - 水龟
  ReptileCategory(
    name: '水龟',
    icon: '🐢',
    species: [
      {'species': 'red_eared_slider', 'name': '红耳龟'},
      {'species': 'yellow_bellied_slider', 'name': '巴西龟'},
      {'species': 'musk_turtle', 'name': '麝香龟'},
      {'species': 'map_turtle', 'name': '地图龟'},
      {'species': 'painted_turtle', 'name': '锦龟'},
      {'species': 'chinese_pond_turtle', 'name': '草龟'},
      {'species': 'reeves_turtle', 'name': '巴西斑龟'},
      {'species': 'snake_neck_turtle', 'name': '蛇颈龟'},
      {'species': 'side_neck_turtle', 'name': '侧颈龟'},
      {'species': 'softshell_turtle', 'name': '鳖/软壳龟'},
      {'species': 'other_water_turtle', 'name': '其他水龟'},
    ],
  ),
  // 龟类 - 半水龟
  ReptileCategory(
    name: '半水龟',
    icon: '🐢',
    species: [
      {'species': 'chinese_box_turtle', 'name': '黄缘闭壳龟'},
      {'species': 'keeled_box_turtle', 'name': '锯缘摄龟'},
      {'species': 'three_striped_box_turtle', 'name': '三线闭壳龟'},
      {'species': 'japanese_pond_turtle', 'name': '日本石龟'},
      {'species': 'chinese_softshell_turtle', 'name': '中华鳖'},
      {'species': 'golden_turtle', 'name': '金龟'},
      {'species': 'other_semi_terrestrial', 'name': '其他半水龟'},
    ],
  ),
  // 龟类 - 陆龟
  ReptileCategory(
    name: '陆龟',
    icon: '🐢',
    species: [
      {'species': 'radiated_tortoise', 'name': '辐射陆龟'},
      {'species': 'leopard_tortoise', 'name': '豹纹陆龟'},
      {'species': 'hermann_tortoise', 'name': '赫曼陆龟'},
      {'species': 'indian_star_tortoise', 'name': '印度星龟'},
      {'species': 'red_footed_tortoise', 'name': '红腿陆龟'},
      {'species': 'yellow_footed_tortoise', 'name': '黄腿陆龟'},
      {'species': 'sulcata_tortoise', 'name': '苏卡达陆龟'},
      {'species': 'african_spurred_tortoise', 'name': '非洲盾臂龟'},
      {'species': 'chinese_tortoise', 'name': '中华草龟'},
      {'species': 'greek_tortoise', 'name': '希腊陆龟'},
      {'species': 'other_tortoise', 'name': '其他陆龟'},
    ],
  ),
  // 两栖类
  ReptileCategory(
    name: '两栖类',
    icon: '🐸',
    species: [
      {'species': 'horned_frog', 'name': '角蛙'},
      {'species': 'pacman_frog', 'name': 'pacman蛙'},
      {'species': 'white_tree_frog', 'name': '白树蛙'},
      {'species': 'red_eye_tree_frog', 'name': '红眼树蛙'},
      {'species': 'dart_frog', 'name': '箭毒蛙'},
      {'species': 'axolotl', 'name': '蝾螈'},
      {'species': 'fire_belly_newt', 'name': '火焰蝾螈'},
      {'species': 'chinese_fire_belly', 'name': '中国火龙'},
      {'species': 'other_amphibian', 'name': '其他两栖类'},
    ],
  ),
  // 蜘蛛类
  ReptileCategory(
    name: '蜘蛛类',
    icon: '🕷️',
    species: [
      {'species': 'chilean_rose', 'name': '智利红玫瑰'},
      {'species': 'mexican_red_knee', 'name': '墨西哥红膝'},
      {'species': 'white_knee_tarantula', 'name': '巴西白膝'},
      {'species': 'mexican_blonde', 'name': '墨西哥金毛'},
      {'species': 'brazilian_black', 'name': '巴西黑丝绒'},
      {'species': 'greenbottle_blue', 'name': '蓝瓶'},
      {'species': 'cobalt_blue', 'name': '钴蓝'},
      {'species': 'gooty_sapphire', 'name': '圭亚那蓝宝石'},
      {'species': 'other_tarantula', 'name': '其他捕鸟蛛'},
    ],
  ),
  // 其他
  ReptileCategory(
    name: '其他',
    icon: '🔍',
    species: [
      {'species': 'scorpion', 'name': '蝎子'},
      {'species': 'centipede', 'name': '蜈蚣'},
      {'species': 'mantis', 'name': '螳螂'},
      {'species': 'beetle', 'name': '甲虫'},
      {'species': 'other', 'name': '其他'},
    ],
  ),
];

// 扁平化的种类列表（用于快速查找）
List<Map<String, String>> get allSpecies {
  return reptileCategories.expand((category) => category.species).toList();
}

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
  String? _selectedCategory; // 当前选中的分类
  String? _selectedSpecies; // 当前选中的具体种类

  // 根据分类获取种类列表
  List<Map<String, String>> _getSpeciesForCategory(String categoryName) {
    final category = reptileCategories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => reptileCategories.last,
    );
    return category.species;
  }

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

              // 种类 - 两级选择（先选大类，再选具体种类）
              Row(
                children: [
                  // 第一级：选择分类
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '分类',
                        prefixIcon: Icon(Icons.category),
                      ),
                      value: _selectedCategory,
                      items: reptileCategories.map((category) {
                        return DropdownMenuItem(
                          value: category.name,
                          child: Text('${category.icon} ${category.name}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _selectedSpecies = null;
                          _speciesController.text = '';
                        });
                      },
                      validator: (value) =>
                          value?.isEmpty == true ? '请选择分类' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 第二级：选择具体种类
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '具体种类',
                        prefixIcon: Icon(Icons.pets),
                      ),
                      value: _selectedSpecies,
                      items: _selectedCategory != null
                          ? _getSpeciesForCategory(_selectedCategory!)
                              .map((species) {
                                  return DropdownMenuItem(
                                    value: species['species'],
                                    child: Text(species['name']!),
                                  );
                                })
                                .toList()
                          : [],
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecies = value;
                          _speciesController.text = value ?? '';
                        });
                      },
                      validator: (value) =>
                          value?.isEmpty == true ? '请选择种类' : null,
                    ),
                  ),
                ],
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
      final species = allSpecies.firstWhere(
        (s) => s['species'] == _speciesController.text,
        orElse: () => {'species': 'other', 'name': '其他'},
      );

      final reptile = Reptile(
        id: '${DateTime.now().millisecondsSinceEpoch}_${_nameController.text}',
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
