import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/brumation_constants.dart';
import '../../data/models/breeding.dart';
import '../../data/models/reptile.dart';
import '../../data/repositories/repositories.dart';

class BrumationScreen extends ConsumerStatefulWidget {
  const BrumationScreen({super.key});

  @override
  ConsumerState<BrumationScreen> createState() => _BrumationScreenState();
}

class _BrumationScreenState extends ConsumerState<BrumationScreen> {
  final BreedingRepository _breedingRepo = BreedingRepository();
  final ReptileRepository _reptileRepo = ReptileRepository();
  List<Reptile> _reptiles = [];
  Reptile? _selectedReptile;
  List<BrumationTemp> _temps = [];
  Map<String, double> _stats = {'avg': 0, 'min': 0, 'max': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReptiles();
  }

  Future<void> _loadReptiles() async {
    final reptiles = await _reptileRepo.getAllReptiles();
    setState(() {
      _reptiles = reptiles;
      _isLoading = false;
    });
  }

  Future<void> _loadTemps() async {
    if (_selectedReptile == null) return;

    final temps = await _breedingRepo.getBrumationTemps(_selectedReptile!.id);
    final stats = await _breedingRepo.getTemperatureStats(_selectedReptile!.id);

    setState(() {
      _temps = temps;
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('冬化温度监控'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 选择爬宠
                _buildReptileSelector(),
                if (_selectedReptile != null) ...[
                  // 温度统计
                  _buildTempStats(),
                  // 温度记录列表
                  Expanded(child: _buildTempList()),
                ],
              ],
            ),
      floatingActionButton: _selectedReptile != null
          ? FloatingActionButton(
              onPressed: () => _showAddTempDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildReptileSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<Reptile>(
        decoration: const InputDecoration(
          labelText: '选择爬宠',
          border: OutlineInputBorder(),
        ),
        initialValue: _selectedReptile,
        items: _reptiles.map((reptile) {
          return DropdownMenuItem(
            value: reptile,
            child: Text('${reptile.name} (${reptile.speciesChinese ?? reptile.species})'),
          );
        }).toList(),
        onChanged: (reptile) {
          setState(() {
            _selectedReptile = reptile;
            _temps = [];
          });
          if (reptile != null) {
            _loadTemps();
          }
        },
      ),
    );
  }

  Widget _buildTempStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(
                label: '平均温度',
                value: '${_stats['avg']?.toStringAsFixed(1) ?? '0'}°C',
              ),
              _StatColumn(
                label: '最低温度',
                value: '${_stats['min']?.toStringAsFixed(1) ?? '0'}°C',
              ),
              _StatColumn(
                label: '最高温度',
                value: '${_stats['max']?.toStringAsFixed(1) ?? '0'}°C',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTempList() {
    if (_temps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.thermostat_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '暂无温度记录',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角添加记录',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _temps.length,
      itemBuilder: (context, index) {
        final temp = _temps[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTempColor(temp.temperature),
              child: Text(
                '${temp.temperature.toInt()}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(_formatDate(temp.recordDate)),
            subtitle: temp.humidity != null
                ? Text('湿度: ${temp.humidity!.toInt()}%')
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await _breedingRepo.deleteBrumationTemp(temp.id);
                _loadTemps();
              },
            ),
          ),
        );
      },
    );
  }

  Color _getTempColor(double temp) {
    return BrumationConstants.getTempColor(temp);
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日 ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAddTempDialog() async {
    final temp = await showDialog<double>(
      context: context,
      builder: (context) {
        double temperature = BrumationConstants.defaultTemp;
        return AlertDialog(
          title: const Text('添加温度记录'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '温度 (°C)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  temperature = double.tryParse(value) ?? 10;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '湿度 (%) - 可选',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, temperature),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (temp != null && _selectedReptile != null) {
      final brumationTemp = BrumationTemp(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reptileId: _selectedReptile!.id,
        recordDate: DateTime.now(),
        temperature: temp,
        createdAt: DateTime.now(),
      );
      await _breedingRepo.addBrumationTemp(brumationTemp);
      _loadTemps();
    }
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
