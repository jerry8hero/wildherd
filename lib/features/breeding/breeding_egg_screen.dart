import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/breeding.dart';
import '../../data/repositories/breeding_repository.dart';

class BreedingEggScreen extends StatefulWidget {
  final BreedingBatch batch;

  const BreedingEggScreen({super.key, required this.batch});

  @override
  State<BreedingEggScreen> createState() => _BreedingEggScreenState();
}

class _BreedingEggScreenState extends State<BreedingEggScreen> {
  final BreedingRepository _repository = BreedingRepository();
  List<BreedingEgg> _eggs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEggs();
  }

  Future<void> _loadEggs() async {
    final eggs = await _repository.getEggsByBatch(widget.batch.id);
    setState(() {
      _eggs = eggs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.batch.reptileName} - 蛋管理'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _eggs.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _eggs.length,
                  itemBuilder: (context, index) {
                    return _buildEggCard(_eggs[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEggDialog(),
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
            '暂无蛋记录',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角添加蛋',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEggCard(BreedingEgg egg) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEggDetailDialog(egg),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getEggIcon(egg.fertility, egg.hatchStatus),
                        color: _getEggColor(egg.fertility, egg.hatchStatus),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '第 ${egg.eggNumber} 号蛋',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusChip(egg.fertility, egg.hatchStatus),
                ],
              ),
              const SizedBox(height: 12),
              // 发育进度
              _buildProgressBar(egg),
              const SizedBox(height: 8),
              // 关键日期
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (egg.candlingDate != null)
                    _buildDateChip(Icons.flashlight_on, '照蛋: ${_formatDate(egg.candlingDate!)}'),
                  if (egg.hatchDate != null)
                    _buildDateChip(Icons.pets, '出壳: ${_formatDate(egg.hatchDate!)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BreedingEgg egg) {
    double progress = 0;
    String stage = '待照蛋';

    if (egg.hatchStatus == 'hatched') {
      progress = 1.0;
      stage = '已出壳';
    } else if (egg.candlingDate != null) {
      if (egg.fertility == 'infertile') {
        progress = 0.3;
        stage = '无精蛋';
      } else if (egg.fertility == 'fertile') {
        progress = 0.7;
        stage = '孵化中';
      } else {
        progress = 0.2;
        stage = '待确认';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(stage, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text('${(progress * 100).toInt()}%', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getEggColor(egg.fertility, egg.hatchStatus),
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  IconData _getEggIcon(String? fertility, String? hatchStatus) {
    if (hatchStatus == 'hatched') return Icons.pets;
    if (hatchStatus == 'died') return Icons.warning;
    if (hatchStatus == 'culled') return Icons.remove_circle;
    if (fertility == 'infertile') return Icons.cancel;
    if (fertility == 'fertile') return Icons.egg;
    return Icons.egg_outlined;
  }

  Color _getEggColor(String? fertility, String? hatchStatus) {
    if (hatchStatus == 'hatched') return Colors.green;
    if (hatchStatus == 'died') return Colors.red;
    if (hatchStatus == 'culled') return Colors.grey;
    if (fertility == 'infertile') return Colors.orange;
    if (fertility == 'fertile') return Colors.blue;
    return Colors.grey;
  }

  Widget _buildStatusChip(String? fertility, String? hatchStatus) {
    String label;
    Color color;

    if (hatchStatus == 'hatched') {
      label = '已出壳';
      color = Colors.green;
    } else if (hatchStatus == 'died') {
      label = '死亡';
      color = Colors.red;
    } else if (hatchStatus == 'culled') {
      label = '淘汰';
      color = Colors.grey;
    } else if (fertility == 'infertile') {
      label = '无精蛋';
      color = Colors.orange;
    } else if (fertility == 'fertile') {
      label = '受精蛋';
      color = Colors.blue;
    } else {
      label = '待照蛋';
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  /// 添加蛋
  void _showAddEggDialog() async {
    final eggNumber = _eggs.isEmpty ? 1 : _eggs.last.eggNumber + 1;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('添加第 $eggNumber 号蛋'),
        content: const Text('是否确认添加一枚新蛋？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('添加'),
          ),
        ],
      ),
    );

    if (result == true) {
      final egg = BreedingEgg(
        id: const Uuid().v7(),
        batchId: widget.batch.id,
        eggNumber: eggNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.saveEgg(egg);
      _loadEggs();
    }
  }

  /// 蛋详情/操作
  void _showEggDetailDialog(BreedingEgg egg) {
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
                  '第 ${egg.eggNumber} 号蛋',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _repository.deleteEgg(egg.id);
                    _loadEggs();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('编号', '第 ${egg.eggNumber} 号'),
            _buildDetailRow('状态', _getStatusText(egg)),
            if (egg.candlingDate != null)
              _buildDetailRow('照蛋日期', _formatFullDate(egg.candlingDate!)),
            if (egg.candlingResult != null)
              _buildDetailRow('照蛋结果', egg.candlingResult!),
            if (egg.hatchDate != null)
              _buildDetailRow('出壳日期', _formatFullDate(egg.hatchDate!)),
            if (egg.hatchStatus != null)
              _buildDetailRow('出壳状态', _getHatchStatusText(egg.hatchStatus!)),
            if (egg.notes != null) _buildDetailRow('备注', egg.notes!),
            const SizedBox(height: 16),

            // 操作按钮
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 照蛋按钮
                if (egg.fertility == null)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCandlingDialog(egg);
                    },
                    icon: const Icon(Icons.flashlight_on),
                    label: const Text('照蛋'),
                  ),
                // 出壳按钮（仅受精蛋可操作）
                if (egg.fertility == 'fertile' && egg.hatchStatus == null)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showHatchDialog(egg);
                    },
                    icon: const Icon(Icons.pets),
                    label: const Text('记录出壳'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                // 标记为无精蛋
                if (egg.fertility == null)
                  OutlinedButton(
                    onPressed: () async {
                      final updated = egg.copyWith(
                        fertility: 'infertile',
                        candlingDate: DateTime.now(),
                        candlingResult: '无精蛋',
                        updatedAt: DateTime.now(),
                      );
                      await _repository.saveEgg(updated);
                      _loadEggs();
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('无精蛋'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(BreedingEgg egg) {
    if (egg.hatchStatus == 'hatched') return '已出壳';
    if (egg.hatchStatus == 'died') return '死亡';
    if (egg.hatchStatus == 'culled') return '淘汰';
    if (egg.fertility == 'infertile') return '无精蛋';
    if (egg.fertility == 'fertile') return '孵化中';
    return '待照蛋';
  }

  String _getHatchStatusText(String status) {
    switch (status) {
      case 'hatched': return '成功出壳';
      case 'died': return '死亡';
      case 'culled': return '淘汰';
      default: return status;
    }
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

  String _formatFullDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 照蛋对话框
  void _showCandlingDialog(BreedingEgg egg) async {
    String? result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('照蛋结果'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, '受精'),
            child: const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('受精'),
              subtitle: Text('胚胎发育正常'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, '无精蛋'),
            child: const ListTile(
              leading: Icon(Icons.cancel, color: Colors.orange),
              title: Text('无精蛋'),
              subtitle: Text('未受精'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, '发育停止'),
            child: const ListTile(
              leading: Icon(Icons.warning, color: Colors.red),
              title: Text('发育停止'),
              subtitle: Text('胚胎停止发育'),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      String fertility;
      if (result == '受精') {
        fertility = 'fertile';
      } else if (result == '无精蛋') {
        fertility = 'infertile';
      } else {
        fertility = 'infertile';
      }

      final updated = egg.copyWith(
        fertility: fertility,
        candlingDate: DateTime.now(),
        candlingResult: result,
        updatedAt: DateTime.now(),
      );
      await _repository.saveEgg(updated);
      _loadEggs();
    }
  }

  /// 出壳记录对话框
  void _showHatchDialog(BreedingEgg egg) async {
    String? result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('出壳记录'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'hatched'),
            child: const ListTile(
              leading: Icon(Icons.pets, color: Colors.green),
              title: Text('成功出壳'),
              subtitle: Text('苗子健康'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'died'),
            child: const ListTile(
              leading: Icon(Icons.warning, color: Colors.red),
              title: Text('死亡'),
              subtitle: Text('出壳失败'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'culled'),
            child: const ListTile(
              leading: Icon(Icons.remove_circle, color: Colors.grey),
              title: Text('淘汰'),
              subtitle: Text('体质太弱'),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      final updated = egg.copyWith(
        hatchDate: DateTime.now(),
        hatchStatus: result,
        updatedAt: DateTime.now(),
      );
      await _repository.saveEgg(updated);

      // 如果成功出壳，询问是否添加苗子档案
      if (result == 'hatched' && mounted) {
        _showAddOffspringPrompt(egg);
      }

      _loadEggs();
    }
  }

  /// 提示添加苗子档案
  void _showAddOffspringPrompt(BreedingEgg egg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('蛋已标记为出壳成功'),
        action: SnackBarAction(
          label: '添加苗子',
          onPressed: () {
            // 可以扩展：直接跳转到添加苗子页面
          },
        ),
      ),
    );
  }
}
