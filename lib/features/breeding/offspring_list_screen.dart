import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/breeding.dart';
import '../../data/repositories/breeding_repository.dart';
import '../../app/theme.dart';

class OffspringListScreen extends ConsumerStatefulWidget {
  const OffspringListScreen({super.key});

  @override
  ConsumerState<OffspringListScreen> createState() => _OffspringListScreenState();
}

class _OffspringListScreenState extends ConsumerState<OffspringListScreen> {
  final BreedingRepository _repository = BreedingRepository();
  List<Offspring> _offspring = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repository.getAllOffspring();
      setState(() {
        _offspring = data;
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
        title: const Text('苗子档案'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offspring.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _offspring.length,
                  itemBuilder: (context, index) {
                    return _buildOffspringCard(_offspring[index]);
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
          Icon(Icons.pets_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无苗子记录',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '繁殖出壳的苗子会自动添加到这里',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOffspringCard(Offspring offspring) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetailDialog(offspring),
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
                      offspring.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(offspring.status ?? 'alive'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                offspring.species,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (offspring.gender != null) ...[
                    Icon(Icons.wc, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(offspring.gender!, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 12),
                  ],
                  if (offspring.currentWeight != null) ...[
                    Icon(Icons.monitor_weight, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${offspring.currentWeight}g', style: TextStyle(color: Colors.grey[600])),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String label;

    switch (status) {
      case 'alive':
        color = Colors.green;
        label = '存活';
        break;
      case 'sold':
        color = Colors.blue;
        label = '已出售';
        break;
      case 'gifted':
        color = Colors.purple;
        label = '已赠送';
        break;
      case 'deceased':
        color = Colors.red;
        label = '死亡';
        break;
      default:
        color = Colors.grey;
        label = status ?? '未知';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加苗子'),
        content: const Text('苗子通常会在繁殖批次出壳时自动添加。\n\n请前往繁殖批次详情中添加出壳记录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Offspring offspring) {
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
                  offspring.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _repository.deleteOffspring(offspring.id);
                    _loadData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('物种', offspring.species),
            if (offspring.morph != null) _buildDetailRow('变异', offspring.morph!),
            if (offspring.gender != null) _buildDetailRow('性别', offspring.gender!),
            if (offspring.birthDate != null)
              _buildDetailRow('出生日期', _formatDate(offspring.birthDate!)),
            if (offspring.birthWeight != null)
              _buildDetailRow('出生体重', '${offspring.birthWeight}g'),
            if (offspring.currentWeight != null)
              _buildDetailRow('当前体重', '${offspring.currentWeight}g'),
            if (offspring.currentLength != null)
              _buildDetailRow('当前体长', '${offspring.currentLength}cm'),
            if (offspring.notes != null) _buildDetailRow('备注', offspring.notes!),
            const SizedBox(height: 16),
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateStatus(offspring);
                    },
                    child: const Text('更新状态'),
                  ),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _updateStatus(Offspring offspring) async {
    final status = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('更新状态'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'alive'),
            child: const Text('存活'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'sold'),
            child: const Text('已出售'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'gifted'),
            child: const Text('已赠送'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'deceased'),
            child: const Text('死亡'),
          ),
        ],
      ),
    );

    if (status != null) {
      final updated = offspring.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await _repository.saveOffspring(updated);
      _loadData();
    }
  }
}
