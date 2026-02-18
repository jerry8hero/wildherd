import 'package:flutter/material.dart';
import '../../data/models/habitat.dart';
import '../../data/models/reptile.dart';
import '../../data/repositories/habitat_repository.dart';
import '../../app/theme.dart';
import '../../widgets/habitat_gauge.dart';
import '../../widgets/habitat_advice_card.dart';

class HabitatEditScreen extends StatefulWidget {
  final HabitatEnvironment? environment;

  const HabitatEditScreen({super.key, this.environment});

  @override
  State<HabitatEditScreen> createState() => _HabitatEditScreenState();
}

class _HabitatEditScreenState extends State<HabitatEditScreen> {
  final HabitatRepository _repository = HabitatRepository();
  List<Reptile> _reptiles = [];
  Reptile? _selectedReptile;
  HabitatStandard? _standard;
  HabitatScore? _score;

  // 环境参数
  double _temperature = 25;
  double _humidity = 50;
  double? _uvIndex;
  String? _substrate;
  String? _lighting;
  double? _tankSize;
  String? _heating;
  String? _ventilation;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final reptiles = await _repository.getUserReptiles();

      if (widget.environment != null) {
        // 编辑模式
        final env = widget.environment!;
        _temperature = env.temperature;
        _humidity = env.humidity;
        _uvIndex = env.uvIndex;
        _substrate = env.substrate;
        _lighting = env.lighting;
        _tankSize = env.tankSize;
        _heating = env.heating;
        _ventilation = env.ventilation;

        // 找到对应的宠物
        final reptile = reptiles.firstWhere(
          (r) => r.id == env.reptileId,
          orElse: () => reptiles.first,
        );
        _selectedReptile = reptile;

        // 加载标准
        _standard = await _repository.getStandard(env.speciesId);
      } else {
        // 新增模式
        if (reptiles.isNotEmpty) {
          _selectedReptile = reptiles.first;
          _standard = await _repository.getStandard(_selectedReptile!.species);
          if (_standard != null) {
            _temperature = _standard!.idealTemp;
            _humidity = _standard!.idealHumidity ?? 50;
            _tankSize = _standard!.minTankSize.toDouble();
          }
        }
      }

      setState(() {
        _reptiles = reptiles;
        _isLoading = false;
      });

      _updateScore();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _updateScore() {
    if (_standard == null || _selectedReptile == null) return;

    final env = HabitatEnvironment(
      id: widget.environment?.id ?? '',
      reptileId: _selectedReptile!.id,
      reptileName: _selectedReptile!.name,
      speciesId: _selectedReptile!.species,
      temperature: _temperature,
      humidity: _humidity,
      uvIndex: _uvIndex,
      substrate: _substrate,
      lighting: _lighting,
      tankSize: _tankSize,
      heating: _heating,
      ventilation: _ventilation,
    );

    setState(() {
      _score = _repository.calculateScore(env, _standard!);
    });
  }

  Future<void> _onReptileChanged(Reptile? reptile) async {
    if (reptile == null) return;

    setState(() {
      _selectedReptile = reptile;
    });

    final standard = await _repository.getStandard(reptile.species);
    if (standard != null) {
      setState(() {
        _standard = standard;
        _temperature = standard.idealTemp;
        _humidity = standard.idealHumidity ?? 50;
        _tankSize = standard.minTankSize.toDouble();
      });
      _updateScore();
    }
  }

  Future<void> _saveEnvironment() async {
    if (_selectedReptile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择宠物')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final env = HabitatEnvironment(
        id: widget.environment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        reptileId: _selectedReptile!.id,
        reptileName: _selectedReptile!.name,
        speciesId: _selectedReptile!.species,
        temperature: _temperature,
        humidity: _humidity,
        uvIndex: _uvIndex,
        substrate: _substrate,
        lighting: _lighting,
        tankSize: _tankSize,
        heating: _heating,
        ventilation: _ventilation,
        createdAt: widget.environment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.saveEnvironment(env);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存成功'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.environment != null ? '编辑环境' : '添加环境'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          if (widget.environment != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteEnvironment,
              tooltip: '删除',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reptiles.isEmpty
              ? _buildNoReptiles()
              : _buildForm(),
      bottomNavigationBar: _reptiles.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveEnvironment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('保存', style: TextStyle(fontSize: 16)),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildNoReptiles() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text('请先添加宠物'),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 宠物选择
          const Text('选择宠物', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<Reptile>(
            value: _selectedReptile,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _reptiles.map((reptile) {
              return DropdownMenuItem(
                value: reptile,
                child: Text('${reptile.name} (${reptile.speciesChinese ?? reptile.species})'),
              );
            }).toList(),
            onChanged: _onReptileChanged,
          ),

          const SizedBox(height: 24),

          // 实时评分
          if (_score != null) ...[
            const Text('环境评分', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    OverallScoreCircle(score: _score!.overallScore, size: 70),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          ScoreProgressBar(label: '温度', score: _score!.temperatureScore),
                          const SizedBox(height: 4),
                          ScoreProgressBar(label: '湿度', score: _score!.humidityScore),
                          const SizedBox(height: 4),
                          ScoreProgressBar(label: 'UVB', score: _score!.uvScore),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 标准范围提示
          if (_standard != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '适宜温度: ${_standard!.minTemp.toInt()}-${_standard!.maxTemp.toInt()}°C, 湿度: ${_standard!.minHumidity.toInt()}-${_standard!.maxHumidity.toInt()}%',
                      style: const TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 温度设置
          _buildSliderSection(
            title: '温度 (°C)',
            value: _temperature,
            min: _standard?.minTemp != null ? _standard!.minTemp - 10 : 10,
            max: _standard?.maxTemp != null ? _standard!.maxTemp + 15 : 50,
            onChanged: (value) {
              setState(() => _temperature = value);
              _updateScore();
            },
            icon: Icons.thermostat,
          ),

          // 湿度设置
          _buildSliderSection(
            title: '湿度 (%)',
            value: _humidity,
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() => _humidity = value);
              _updateScore();
            },
            icon: Icons.water_drop,
          ),

          const SizedBox(height: 16),

          // UV指数
          const Text('UVB指数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _uvIndex?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '输入UV指数（可选）',
              suffixText: 'UV',
            ),
            onChanged: (value) {
              setState(() {
                _uvIndex = double.tryParse(value);
              });
              _updateScore();
            },
          ),

          const SizedBox(height: 24),

          // 垫材选择
          const Text('垫材类型', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SubstrateOptions.all.map((option) {
              final isSelected = _substrate == option.id;
              return ChoiceChip(
                label: Text(option.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _substrate = selected ? option.id : null;
                  });
                  _updateScore();
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 照明选择
          const Text('照明类型', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LightingOptions.all.map((option) {
              final isSelected = _lighting == option.id;
              return ChoiceChip(
                label: Text(option.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _lighting = selected ? option.id : null;
                    if (selected && option.uvValue != null) {
                      _uvIndex = option.uvValue;
                    }
                  });
                  _updateScore();
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 饲养箱尺寸
          const Text('饲养箱尺寸 (升)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _tankSize?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '输入饲养箱容量',
              suffixText: 'L',
            ),
            onChanged: (value) {
              setState(() {
                _tankSize = double.tryParse(value);
              });
              _updateScore();
            },
          ),

          const SizedBox(height: 32),

          // 改进建议
          if (_score != null && _score!.suggestions.isNotEmpty)
            HabitatAdviceList(suggestions: _score!.suggestions),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 2).toInt(),
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
        // 标准范围指示
        if (_standard != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${min.toInt()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '适宜: ${_standard!.minTemp.toInt()}-${_standard!.maxTemp.toInt()}',
                    style: const TextStyle(fontSize: 11, color: Colors.green),
                  ),
                ),
                Text(
                  '${max.toInt()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _deleteEnvironment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个环境设置吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && _selectedReptile != null) {
      await _repository.deleteEnvironment(_selectedReptile!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
