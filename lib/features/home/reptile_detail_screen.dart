import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reptile.dart';
import '../../data/repositories/repositories.dart';
import '../../app/theme.dart';
import '../../utils/date_utils.dart';
import '../../utils/gender_utils.dart';
import '../../app/providers.dart';
import '../shedding/shedding_screen.dart';
import '../reminders/reminder_list_screen.dart';
import 'growth_chart_screen.dart';

class ReptileDetailScreen extends ConsumerStatefulWidget {
  final Reptile reptile;

  const ReptileDetailScreen({super.key, required this.reptile});

  @override
  ConsumerState<ReptileDetailScreen> createState() => _ReptileDetailScreenState();
}

class _ReptileDetailScreenState extends ConsumerState<ReptileDetailScreen> {
  late Reptile _reptile;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _reptile = widget.reptile;
    _nameController.text = _reptile.name;
    _speciesController.text = _reptile.speciesChinese ?? _reptile.species;
    _selectedGender = _reptile.gender;
    _selectedBirthDate = _reptile.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updatedReptile = _reptile.copyWith(
      name: _nameController.text,
      speciesChinese: _speciesController.text,
      gender: _selectedGender,
      birthDate: _selectedBirthDate,
      updatedAt: DateTime.now(),
    );

    await ref.read(reptileRepositoryProvider).updateReptile(updatedReptile);
    setState(() {
      _reptile = updatedReptile;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑资料' : _reptile.name),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nameController.text = _reptile.name;
                  _speciesController.text = _reptile.speciesChinese ?? _reptile.species;
                  _selectedGender = _reptile.gender;
                  _selectedBirthDate = _reptile.birthDate;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 头像
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.getCategoryColor(_reptile.species),
                backgroundImage: _reptile.imagePath != null && _reptile.imagePath!.isNotEmpty
                    ? (_reptile.imagePath!.startsWith('http')
                        ? NetworkImage(_reptile.imagePath!)
                        : AssetImage(_reptile.imagePath!))
                    : null,
                child: _reptile.imagePath == null || _reptile.imagePath!.isEmpty
                    ? const Icon(Icons.pets, color: Colors.white, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 32),

            // 资料卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '基本资料',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 名称
                    _buildInfoRow(
                      '名称',
                      isEditing: _isEditing,
                      child: _isEditing
                          ? TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            )
                          : Text(_reptile.name),
                    ),

                    // 种类
                    _buildInfoRow(
                      '种类',
                      isEditing: _isEditing,
                      child: _isEditing
                          ? TextField(
                              controller: _speciesController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            )
                          : Text(_reptile.speciesChinese ?? _reptile.species),
                    ),

                    // 性别
                    _buildInfoRow(
                      '性别',
                      isEditing: _isEditing,
                      child: _isEditing
                          ? DropdownButton<String>(
                              value: _selectedGender ?? '未知',
                              items: GenderUtils.getDropdownItems(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            )
                          : Row(
                              children: [
                                Icon(
                                  GenderUtils.getIcon(_reptile.gender),
                                  color: GenderUtils.getColor(_reptile.gender),
                                ),
                                const SizedBox(width: 8),
                                Text(GenderUtils.getText(_reptile.gender)),
                              ],
                            ),
                    ),

                    // 出生日期
                    _buildInfoRow(
                      '出生日期',
                      isEditing: _isEditing,
                      child: _isEditing
                          ? InkWell(
                              onTap: _selectBirthDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedBirthDate != null
                                          ? DateTimeUtils.formatDate(_selectedBirthDate)
                                          : '选择日期',
                                    ),
                                    const Icon(Icons.calendar_today, size: 20),
                                  ],
                                ),
                              ),
                            )
                          : Text(
                              DateTimeUtils.formatDate(_reptile.birthDate),
                              style: TextStyle(
                                color: _reptile.birthDate != null ? null : Colors.grey,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 保存按钮
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('保存修改'),
                ),
              ),

            // 功能入口（非编辑模式显示）
            if (!_isEditing) ...[
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '功能',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.show_chart,
                      label: '成长图表',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GrowthChartScreen(
                              reptileId: _reptile.id,
                              reptileName: _reptile.name,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.auto_awesome,
                      label: '蜕皮记录',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SheddingScreen(
                              reptileId: _reptile.id,
                              reptileName: _reptile.name,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.notifications_active,
                      label: '喂食提醒',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReminderListScreen(
                              reptileId: _reptile.id,
                              reptileName: _reptile.name,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, {required Widget child, bool isEditing = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
