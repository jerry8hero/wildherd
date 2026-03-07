import 'package:flutter/material.dart';
import '../../data/models/breeding.dart';
import '../../data/models/reptile.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/breeding_repository.dart';
import 'breeding_egg_screen.dart';

class BreedingBatchListScreen extends StatefulWidget {
  const BreedingBatchListScreen({super.key});

  @override
  State<BreedingBatchListScreen> createState() => _BreedingBatchListScreenState();
}

class _BreedingBatchListScreenState extends State<BreedingBatchListScreen> {
  final BreedingRepository _breedingRepo = BreedingRepository();
  final ReptileRepository _reptileRepo = ReptileRepository();
  List<BreedingBatch> _batches = [];
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
      final batches = await _breedingRepo.getAllBatches();
      final reptiles = await _reptileRepo.getAllReptiles();
      setState(() {
        _batches = batches;
        _reptiles = reptiles;
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
        title: const Text('繁殖批次'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _batches.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _batches.length,
                  itemBuilder: (context, index) {
                    return _buildBatchCard(_batches[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.egg_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无繁殖记录',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角添加繁殖记录',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(BreedingBatch batch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showBatchDetail(batch),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      batch.reptileName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(batch.status ?? 'mating'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                batch.species,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.favorite, '交配: ${_formatDate(batch.matingDate)}'),
                  if (batch.eggCount != null) ...[
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.egg, '${batch.eggCount}枚'),
                  ],
                  if (batch.hatchedCount != null) ...[
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.pets, '${batch.hatchedCount}只'),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'mating':
        color = Colors.pink;
        label = '交配中';
        break;
      case 'laid':
        color = Colors.orange;
        label = '已产蛋';
        break;
      case 'incubating':
        color = Colors.blue;
        label = '孵化中';
        break;
      case 'hatched':
        color = Colors.green;
        label = '已出壳';
        break;
      case 'failed':
        color = Colors.red;
        label = '失败';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 添加繁殖记录 - 选择母龟
  void _showAddDialog() {
    if (_reptiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先添加爬宠')),
      );
      return;
    }

    // 按性别分组
    final females = _reptiles.where((r) => r.gender == '雌性' || r.gender == 'female' || r.gender == '母').toList();
    final males = _reptiles.where((r) => r.gender == '雄性' || r.gender == 'male' || r.gender == '公').toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '添加繁殖记录',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 选择母龟
              const Text('选择母龟 (母体)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: females.length,
                  itemBuilder: (context, index) {
                    final female = females[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.pink,
                          child: Icon(Icons.female, color: Colors.white),
                        ),
                        title: Text(female.name),
                        subtitle: Text(female.speciesChinese ?? female.species),
                        onTap: () {
                          Navigator.pop(context);
                          _showSelectMaleDialog(female, males);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 选择公龟
  void _showSelectMaleDialog(Reptile female, List<Reptile> males) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择公龟 (父体)'),
        content: SizedBox(
          width: double.maxFinite,
          child: males.isEmpty
              ? const Text('暂无公龟记录，请先添加公龟')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: males.length,
                  itemBuilder: (context, index) {
                    final male = males[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.male, color: Colors.white),
                      ),
                      title: Text(male.name),
                      subtitle: Text(male.speciesChinese ?? male.species),
                      onTap: () {
                        Navigator.pop(context);
                        _addBatch(female, male);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addBatch(female, null); // 不选择公龟
            },
            child: const Text('不确定/跳过'),
          ),
          if (males.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
        ],
      ),
    );
  }

  void _addBatch(Reptile female, Reptile? male) async {
    final now = DateTime.now();
    final batch = BreedingBatch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reptileId: female.id,      // 母体ID
      fatherId: male?.id,       // 父体ID
      reptileName: female.name,
      species: female.species,
      matingDate: now,
      createdAt: now,
      updatedAt: now,
    );

    await _breedingRepo.saveBatch(batch);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('繁殖记录已添加: ${female.name}${male != null ? ' x ${male.name}' : ''}'),
        ),
      );
    }
  }

  void _showBatchDetail(BreedingBatch batch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  batch.reptileName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _breedingRepo.deleteBatch(batch.id);
                    _loadData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('母体', batch.reptileName),
            _buildDetailRow('父体', batch.fatherId ?? '未设置'),
            _buildDetailRow('交配日期', _formatDate(batch.matingDate)),
            if (batch.eggLayingDate != null)
              _buildDetailRow('产蛋日期', _formatDate(batch.eggLayingDate!)),
            if (batch.eggCount != null)
              _buildDetailRow('产蛋数量', '${batch.eggCount}枚'),
            if (batch.incubationStartDate != null)
              _buildDetailRow('孵化开始', _formatDate(batch.incubationStartDate!)),
            if (batch.expectedHatchDate != null)
              _buildDetailRow('预计出壳', _formatDate(batch.expectedHatchDate!)),
            if (batch.hatchedCount != null)
              _buildDetailRow('出壳数量', '${batch.hatchedCount}只'),
            const SizedBox(height: 16),

            // 操作按钮
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 查看蛋按钮
                if (batch.eggLayingDate != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openEggScreen(batch);
                    },
                    icon: const Icon(Icons.egg),
                    label: Text('蛋 (${batch.eggCount ?? 0})'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                if (batch.status == 'mating' || batch.status == null)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateEggLaying(batch);
                    },
                    child: const Text('记录产蛋'),
                  ),
                if (batch.eggLayingDate != null && batch.status != 'incubating' && batch.status != 'hatched')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateIncubation(batch);
                    },
                    child: const Text('开始孵化'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value),
        ],
      ),
    );
  }

  void _updateEggLaying(BreedingBatch batch) async {
    // 显示对话框输入产蛋数量
    final eggCount = await showDialog<int>(
      context: context,
      builder: (context) {
        int count = 1;
        return AlertDialog(
          title: const Text('记录产蛋'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('请输入产蛋数量'),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '产蛋数量',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  count = int.tryParse(value) ?? 1;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, count),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (eggCount != null) {
      final updated = batch.copyWith(
        eggLayingDate: DateTime.now(),
        eggCount: eggCount,
        status: 'laid',
        updatedAt: DateTime.now(),
      );
      await _breedingRepo.saveBatch(updated);
      _loadData();
    }
  }

  void _updateIncubation(BreedingBatch batch) async {
    // 计算预计出壳日期（草龟约60天）
    final expectedHatch = DateTime.now().add(const Duration(days: 60));

    final updated = batch.copyWith(
      incubationStartDate: DateTime.now(),
      expectedHatchDate: expectedHatch,
      status: 'incubating',
      updatedAt: DateTime.now(),
    );
    await _breedingRepo.saveBatch(updated);
    _loadData();
  }

  /// 打开蛋管理页面
  void _openEggScreen(BreedingBatch batch) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BreedingEggScreen(batch: batch),
      ),
    ).then((_) => _loadData());
  }
}
