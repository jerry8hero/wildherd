import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/reptile.dart';
import '../../data/models/record.dart';
import '../../data/repositories/repositories.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/date_utils.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/delete_confirm_dialog.dart';
import 'feeding_weather_screen.dart';
import '../../app/providers.dart';

class FeedingRecordScreen extends ConsumerStatefulWidget {
  const FeedingRecordScreen({super.key});

  @override
  ConsumerState<FeedingRecordScreen> createState() => _FeedingRecordScreenState();
}

class _FeedingRecordScreenState extends ConsumerState<FeedingRecordScreen> {
  List<Reptile> _reptiles = [];
  List<FeedingRecord> _records = [];
  bool _isLoading = true;
  String? _selectedReptileId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final reptiles = await ref.read(reptileRepositoryProvider).getAllReptiles();
      List<FeedingRecord> records;

      if (_selectedReptileId != null) {
        records = await ref.read(recordRepositoryProvider).getFeedingRecords(_selectedReptileId!);
      } else {
        // 获取所有爬宠的记录
        records = [];
        for (var reptile in reptiles) {
          final reptileRecords = await ref.read(recordRepositoryProvider).getFeedingRecords(reptile.id);
          records.addAll(reptileRecords);
        }
        // 按时间排序
        records.sort((a, b) => b.feedingTime.compareTo(a.feedingTime));
      }

      setState(() {
        _reptiles = reptiles;
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('加载失败，请重试'),
            action: SnackBarAction(label: '重试', onPressed: _loadData),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feedingRecord),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud),
            tooltip: '天气喂食推荐',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedingWeatherScreen(
                    speciesType: _selectedReptileId != null
                        ? _reptiles.firstWhere((r) => r.id == _selectedReptileId).species
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 爬宠筛选
          if (_reptiles.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('全部'),
                      selected: _selectedReptileId == null,
                      onSelected: (selected) {
                        setState(() => _selectedReptileId = null);
                        _loadData();
                      },
                    ),
                  ),
                  ..._reptiles.map((reptile) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(reptile.name),
                      selected: _selectedReptileId == reptile.id,
                      onSelected: (selected) {
                        setState(() => _selectedReptileId = selected ? reptile.id : null);
                        _loadData();
                      },
                    ),
                  )),
                ],
              ),
            ),
          // 记录列表
          Expanded(
            child: _isLoading
                ? Center(child: Text(l10n.loading))
                : _records.isEmpty
                    ? EmptyState(
                        icon: Icons.restaurant,
                        title: l10n.noRecords,
                        subtitle: l10n.addFirstRecord,
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _records.length,
                          itemBuilder: (context, index) {
                            return _buildRecordCard(_records[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: _reptiles.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _showAddRecordDialog,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildRecordCard(FeedingRecord record) {
    final reptile = _reptiles.firstWhere(
      (r) => r.id == record.reptileId,
      orElse: () => Reptile(
        id: '',
        name: '未知',
        species: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.restaurant, color: Colors.orange[700]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reptile.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.foodType,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (record.notes != null && record.notes!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      record.notes!,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateTimeUtils.formatRelativeTime(record.feedingTime),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (record.foodAmount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${record.foodAmount}g',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 20),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.delete),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteRecord(record.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRecordDialog() {
    if (_reptiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先添加爬宠')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddFeedingRecordSheet(
        reptiles: _reptiles,
        selectedReptileId: _selectedReptileId ?? _reptiles.first.id,
        onSave: (record) async {
          await ref.read(recordRepositoryProvider).addFeedingRecord(record);
          _loadData();
        },
      ),
    );
  }

  Future<void> _deleteRecord(String id) async {
    final confirmed = await DeleteConfirmDialog.show(context, recordLabel: '喂食记录');
    if (confirmed == true) {
      await ref.read(recordRepositoryProvider).deleteFeedingRecord(id);
      _loadData();
    }
  }
}

// 添加喂食记录对话框
class _AddFeedingRecordSheet extends StatefulWidget {
  final List<Reptile> reptiles;
  final String selectedReptileId;
  final Function(FeedingRecord) onSave;

  const _AddFeedingRecordSheet({
    required this.reptiles,
    required this.selectedReptileId,
    required this.onSave,
  });

  @override
  State<_AddFeedingRecordSheet> createState() => _AddFeedingRecordSheetState();
}

class _AddFeedingRecordSheetState extends State<_AddFeedingRecordSheet> {
  late String _selectedReptileId;
  String _selectedFoodType = '小白鼠';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _foodTypes = [
    '小白鼠',
    '大麦虫',
    '面包虫',
    '蟋蟀',
    '小鱼',
    '饲料',
    '水果',
    '蔬菜',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    _selectedReptileId = widget.selectedReptileId;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
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
            const Text(
              '添加喂食记录',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // 选择爬宠
            const Text(
              '选择爬宠',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.reptiles.map((reptile) {
                return ChoiceChip(
                  label: Text(reptile.name),
                  selected: _selectedReptileId == reptile.id,
                  onSelected: (selected) {
                    setState(() {
                      _selectedReptileId = selected ? reptile.id : _selectedReptileId;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 食物类型
            const Text(
              '食物类型',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _foodTypes.map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: _selectedFoodType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFoodType = selected ? type : _selectedFoodType;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 食物量
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: '食物量 (g)',
                hintText: '可选填写',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // 备注
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '备注',
                hintText: '可选填写',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('保存'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _saveRecord() {
    final record = FeedingRecord(
      id: 'f${const Uuid().v7()}',
      reptileId: _selectedReptileId,
      feedingTime: DateTime.now(),
      foodType: _selectedFoodType,
      foodAmount: double.tryParse(_amountController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: DateTime.now(),
    );

    widget.onSave(record);
    Navigator.pop(context);
  }
}
