import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../app/providers.dart';
import '../../data/models/shedding_record.dart';
import '../../utils/date_utils.dart';

class SheddingAddSheet extends ConsumerStatefulWidget {
  final String reptileId;
  final VoidCallback onSaved;

  const SheddingAddSheet({
    super.key,
    required this.reptileId,
    required this.onSaved,
  });

  @override
  ConsumerState<SheddingAddSheet> createState() => _SheddingAddSheetState();
}

class _SheddingAddSheetState extends ConsumerState<SheddingAddSheet> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCompleteness = 'complete';
  final TextEditingController _notesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            '添加蜕皮记录',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Date picker
                ListTile(
                  title: Text(
                    '蜕皮日期',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    DateTimeUtils.formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () => _showDatePicker(),
                ),
                const Divider(),
                const SizedBox(height: 16),
                // Completeness selection
                Text(
                  '蜕皮完整度',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('完整'),
                        selected: _selectedCompleteness == 'complete',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCompleteness = 'complete';
                            });
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(
                          color: _selectedCompleteness == 'complete' ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('不完整'),
                        selected: _selectedCompleteness == 'partial',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCompleteness = 'partial';
                            });
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.orange,
                        labelStyle: TextStyle(
                          color: _selectedCompleteness == 'partial' ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('卡皮'),
                        selected: _selectedCompleteness == 'stuck',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCompleteness = 'stuck';
                            });
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.red,
                        labelStyle: TextStyle(
                          color: _selectedCompleteness == 'stuck' ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Notes field
                Text(
                  '备注（可选）',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: '记录蜕皮过程中的特殊情况...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 32),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveRecord,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '保存记录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      final record = SheddingRecord(
        id: const Uuid().v7(),
        reptileId: widget.reptileId,
        shedDate: _selectedDate,
        completeness: _selectedCompleteness,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(sheddingRepositoryProvider).addSheddingRecord(record);

      // Clear form
      _notesController.clear();
      _selectedDate = DateTime.now();
      _selectedCompleteness = 'complete';

      // Close sheet and notify parent
      Navigator.pop(context);
      widget.onSaved();
    }
  }
}