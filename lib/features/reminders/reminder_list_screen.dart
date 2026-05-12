import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../data/models/feeding_reminder.dart';
import '../../utils/date_utils.dart';
import '../../widgets/empty_state.dart';
import 'reminder_add_sheet.dart';

class ReminderListScreen extends ConsumerStatefulWidget {
  final String? reptileId;
  final String? reptileName;

  const ReminderListScreen({
    super.key,
    this.reptileId,
    this.reptileName,
  });

  @override
  ConsumerState<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends ConsumerState<ReminderListScreen> {
  List<FeedingReminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    List<FeedingReminder> reminders;
    if (widget.reptileId != null) {
      reminders = await ref.read(reminderRepositoryProvider).getRemindersForReptile(widget.reptileId!);
    } else {
      reminders = await ref.read(reminderRepositoryProvider).getAllReminders();
    }
    setState(() {
      _reminders = reminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reptileName ?? '喂食提醒'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReminders,
          ),
        ],
      ),
      body: _reminders.isEmpty
          ? EmptyState(
              icon: Icons.notifications,
              title: '暂无提醒',
              subtitle: '添加喂食提醒，不再错过喂食时间',
              onAction: () => _showAddReminderSheet(),
              actionText: '添加提醒',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return _buildReminderCard(reminder, index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderCard(FeedingReminder reminder, int index) {
    final timeString = '${reminder.feedTimeHour.toString().padLeft(2, '0')}:${reminder.feedTimeMinute.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.reptileName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '食物：${reminder.foodType}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '每 ${reminder.intervalDays} 天一次',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '时间：$timeString',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.enabled,
                  onChanged: (value) async {
                    final updatedReminder = reminder.copyWith(enabled: value);
                    await ref.read(reminderRepositoryProvider).updateReminder(updatedReminder);
                    setState(() {
                      _reminders[index] = updatedReminder;
                    });
                  },
                ),
              ],
            ),
            if (reminder.lastTriggered != null) ...[
              const SizedBox(height: 8),
              Text(
                '上次喂食：${DateTimeUtils.formatRelativeTime(reminder.lastTriggered!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ReminderAddSheet(
        reptileId: widget.reptileId,
        reptileName: widget.reptileName,
        onAdd: () {
          Navigator.pop(context);
          _loadReminders();
        },
      ),
    );
  }
}