import 'package:flutter/material.dart';
import '../../data/models/reptile.dart';
import '../../data/models/record.dart';
import '../../data/repositories/repositories.dart';
import '../../l10n/generated/app_localizations.dart';

class HealthRecordScreen extends StatefulWidget {
  const HealthRecordScreen({super.key});

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  final RecordRepository _repository = RecordRepository();
  final ReptileRepository _reptileRepository = ReptileRepository();
  List<Reptile> _reptiles = [];
  List<HealthRecord> _records = [];
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
      final reptiles = await _reptileRepository.getAllReptiles();
      List<HealthRecord> records;

      if (_selectedReptileId != null) {
        records = await _repository.getHealthRecords(_selectedReptileId!);
      } else {
        // 获取所有爬宠的记录
        records = [];
        for (var reptile in reptiles) {
          final reptileRecords = await _repository.getHealthRecords(reptile.id);
          records.addAll(reptileRecords);
        }
        // 按时间排序
        records.sort((a, b) => b.recordDate.compareTo(a.recordDate));
      }

      setState(() {
        _reptiles = reptiles;
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.healthRecord),
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
                      label: Text(l10n.all),
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
                    ? _buildEmptyState(l10n)
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            l10n.noRecords,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addFirstRecord,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(HealthRecord record) {
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
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.medical_services, color: Colors.blue[700]),
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
                  Row(
                    children: [
                      if (record.weight != null) ...[
                        Text(
                          '体重: ${record.weight}g',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (record.length != null)
                        Text(
                          '体长: ${record.length}cm',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                    ],
                  ),
                  if (record.status != null) ...[
                    const SizedBox(height: 4),
                    _buildStatusChip(record.status!),
                  ],
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
                  _formatDate(record.recordDate),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (record.defecation != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getDefecationText(record.defecation!),
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

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'normal':
        color = Colors.green;
        text = '正常';
        break;
      case 'shedding':
        color = Colors.purple;
        text = '蜕皮中';
        break;
      case 'sick':
        color = Colors.red;
        text = '生病';
        break;
      case 'lethargy':
        color = Colors.orange;
        text = '嗜睡';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  String _getDefecationText(String defecation) {
    switch (defecation) {
      case 'normal':
        return '排便正常';
      case 'abnormal':
        return '排便异常';
      case 'none':
        return '未排便';
      default:
        return defecation;
    }
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
      builder: (context) => _AddHealthRecordSheet(
        reptiles: _reptiles,
        selectedReptileId: _selectedReptileId ?? _reptiles.first.id,
        onSave: (record) async {
          await _repository.addHealthRecord(record);
          _loadData();
        },
      ),
    );
  }

  Future<void> _deleteRecord(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除记录'),
        content: const Text('确定要删除这条健康记录吗？'),
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

    if (confirmed == true) {
      await _repository.deleteHealthRecord(id);
      _loadData();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${date.month}-${date.day}';
    }
  }
}

// 添加健康记录对话框
class _AddHealthRecordSheet extends StatefulWidget {
  final List<Reptile> reptiles;
  final String selectedReptileId;
  final Function(HealthRecord) onSave;

  const _AddHealthRecordSheet({
    required this.reptiles,
    required this.selectedReptileId,
    required this.onSave,
  });

  @override
  State<_AddHealthRecordSheet> createState() => _AddHealthRecordSheetState();
}

class _AddHealthRecordSheetState extends State<_AddHealthRecordSheet> {
  late String _selectedReptileId;
  String _selectedStatus = 'normal';
  String _selectedDefecation = 'normal';
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, String>> _statusOptions = [
    {'value': 'normal', 'label': '正常'},
    {'value': 'shedding', 'label': '蜕皮中'},
    {'value': 'sick', 'label': '生病'},
    {'value': 'lethargy', 'label': '嗜睡'},
  ];

  final List<Map<String, String>> _defecationOptions = [
    {'value': 'normal', 'label': '正常'},
    {'value': 'abnormal', 'label': '异常'},
    {'value': 'none', 'label': '未排便'},
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
        child: SingleChildScrollView(
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
                '添加健康记录',
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

              // 体重
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: '体重 (g)',
                  hintText: '可选填写',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // 体长
              TextField(
                controller: _lengthController,
                decoration: const InputDecoration(
                  labelText: '体长 (cm)',
                  hintText: '可选填写',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // 状态
              const Text(
                '状态',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statusOptions.map((option) {
                  return ChoiceChip(
                    label: Text(option['label']!),
                    selected: _selectedStatus == option['value'],
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? option['value']! : _selectedStatus;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 排便情况
              const Text(
                '排便情况',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _defecationOptions.map((option) {
                  return ChoiceChip(
                    label: Text(option['label']!),
                    selected: _selectedDefecation == option['value'],
                    onSelected: (selected) {
                      setState(() {
                        _selectedDefecation = selected ? option['value']! : _selectedDefecation;
                      });
                    },
                  );
                }).toList(),
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
      ),
    );
  }

  void _saveRecord() {
    final record = HealthRecord(
      id: 'h${DateTime.now().millisecondsSinceEpoch}',
      reptileId: _selectedReptileId,
      recordDate: DateTime.now(),
      weight: double.tryParse(_weightController.text),
      length: double.tryParse(_lengthController.text),
      status: _selectedStatus,
      defecation: _selectedDefecation,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: DateTime.now(),
    );

    widget.onSave(record);
    Navigator.pop(context);
  }
}
