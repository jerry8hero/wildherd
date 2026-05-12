import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../app/providers.dart';
import '../../data/models/shedding_record.dart';
import '../../utils/date_utils.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/delete_confirm_dialog.dart';
import 'shedding_add_sheet.dart';

class SheddingScreen extends ConsumerStatefulWidget {
  final String reptileId;
  final String reptileName;

  const SheddingScreen({
    super.key,
    required this.reptileId,
    required this.reptileName,
  });

  @override
  ConsumerState<SheddingScreen> createState() => _SheddingScreenState();
}

class _SheddingScreenState extends ConsumerState<SheddingScreen> {
  String? _selectedFilter;
  List<SheddingRecord> _allRecords = [];
  List<SheddingRecord> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await ref.read(sheddingRepositoryProvider).getSheddingRecords(widget.reptileId);
    setState(() {
      _allRecords = records;
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_selectedFilter == null) {
      _filteredRecords = _allRecords;
    } else {
      _filteredRecords = _allRecords.where((record) => record.completeness == _selectedFilter).toList();
    }
  }

  Color _getCompletenessColor(String completeness) {
    switch (completeness) {
      case 'complete':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'stuck':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCompletenessText(String completeness) {
    switch (completeness) {
      case 'complete':
        return '完整';
      case 'partial':
        return '不完整';
      case 'stuck':
        return '卡皮';
      default:
        return '未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$widget.reptileName - 蜕皮记录'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('全部'),
                    selected: _selectedFilter == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = null;
                        _applyFilter();
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: _selectedFilter == null ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('完整'),
                    selected: _selectedFilter == 'complete',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? 'complete' : null;
                        _applyFilter();
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(
                      color: _selectedFilter == 'complete' ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('不完整'),
                    selected: _selectedFilter == 'partial',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? 'partial' : null;
                        _applyFilter();
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.orange,
                    labelStyle: TextStyle(
                      color: _selectedFilter == 'partial' ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('卡皮'),
                    selected: _selectedFilter == 'stuck',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? 'stuck' : null;
                        _applyFilter();
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.red,
                    labelStyle: TextStyle(
                      color: _selectedFilter == 'stuck' ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List of records
          Expanded(
            child: _filteredRecords.isEmpty
                ? EmptyState(
                    icon: Icons.pets_outlined,
                    title: '暂无蜕皮记录',
                    subtitle: '点击下方按钮添加第一条记录',
                    onAction: () => _showAddSheet(),
                    actionText: '添加记录',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = _filteredRecords[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            DateTimeUtils.formatDate(record.shedDate),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getCompletenessColor(record.completeness).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getCompletenessText(record.completeness),
                                      style: TextStyle(
                                        color: _getCompletenessColor(record.completeness),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '记录于 ${DateTimeUtils.formatRelativeTime(record.createdAt)}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (record.notes != null && record.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  record.notes!,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await DeleteConfirmDialog.show(
                                context,
                                recordLabel: '蜕皮记录',
                              );
                              if (confirmed == true) {
                                await ref.read(sheddingRepositoryProvider).deleteSheddingRecord(record.id);
                                _loadRecords();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SheddingAddSheet(
        reptileId: widget.reptileId,
        onSaved: () => _loadRecords(),
      ),
    );
  }
}