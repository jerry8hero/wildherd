import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../app/providers.dart';
import '../../data/models/feeding_reminder.dart';
import '../../data/models/reptile.dart';

class ReminderAddSheet extends ConsumerStatefulWidget {
  final String? reptileId;
  final String? reptileName;
  final VoidCallback? onAdd;

  const ReminderAddSheet({
    super.key,
    this.reptileId,
    this.reptileName,
    this.onAdd,
  });

  @override
  ConsumerState<ReminderAddSheet> createState() => _ReminderAddSheetState();
}

class _ReminderAddSheetState extends ConsumerState<ReminderAddSheet> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? _selectedReptileId;
  String? _selectedReptileName;
  String? _selectedFoodType;
  int _intervalDays = 3;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  // Available options
  List<Reptile> _reptiles = [];
  final List<String> _foodTypes = [
    '小白鼠',
    '大麦虫',
    '面包虫',
    '蟋蟀',
    '杜比亚',
    '樱桃红',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    _loadReptiles();
    if (widget.reptileId != null && widget.reptileName != null) {
      _selectedReptileId = widget.reptileId;
      _selectedReptileName = widget.reptileName;
    }
  }

  Future<void> _loadReptiles() async {
    // Assuming there's a reptile repository, adjust as needed
    // final reptiles = await ref.read(reptileRepositoryProvider).getAllReptiles();
    // setState(() {
    //   _reptiles = reptiles;
    // });
    // For now, using placeholder data
    setState(() {
      _reptiles = [
        Reptile(id: '1', name: '小龟龟', species: '龟', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        Reptile(id: '2', name: '大蜥蜴', species: '蜥蜴', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ];
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final reminder = FeedingReminder(
        id: const Uuid().v7().toString(),
        reptileId: _selectedReptileId!,
        reptileName: _selectedReptileName!,
        foodType: _selectedFoodType!,
        intervalDays: _intervalDays,
        feedTimeHour: _selectedTime.hour,
        feedTimeMinute: _selectedTime.minute,
        createdAt: now,
      );

      await ref.read(reminderRepositoryProvider).addReminder(reminder);
      widget.onAdd?.call();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '添加喂食提醒',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Reptile selection
            const Text('选择爬宠', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _reptiles.map((reptile) {
                final isSelected = _selectedReptileId == reptile.id;
                return ChoiceChip(
                  label: Text(reptile.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedReptileId = reptile.id;
                      _selectedReptileName = reptile.name;
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedReptileId == null) ...[
              const SizedBox(height: 8),
              const Text(
                '请选择一个爬宠',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: 24),

            // Food type selection
            const Text('食物类型', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _foodTypes.map((foodType) {
                final isSelected = _selectedFoodType == foodType;
                return ChoiceChip(
                  label: Text(foodType),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFoodType = foodType;
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedFoodType == null) ...[
              const SizedBox(height: 8),
              const Text(
                '请选择食物类型',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: 24),

            // Interval days
            const Text('喂食间隔（天）', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _intervalDays.toString(),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入间隔天数';
                }
                final days = int.tryParse(value);
                if (days == null || days <= 0) {
                  return '请输入有效的天数';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _intervalDays = int.parse(value);
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '例如：3',
              ),
            ),
            const SizedBox(height: 24),

            // Time selection
            const Text('喂食时间', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                TextButton(
                  onPressed: _selectTime,
                  child: const Text('选择时间'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveReminder,
                child: const Text('保存提醒'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}