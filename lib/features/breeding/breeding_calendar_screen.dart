import 'package:flutter/material.dart';
import '../../data/models/breeding.dart';
import '../../data/repositories/breeding_repository.dart';

class BreedingCalendarScreen extends StatefulWidget {
  const BreedingCalendarScreen({super.key});

  @override
  State<BreedingCalendarScreen> createState() => _BreedingCalendarScreenState();
}

class _BreedingCalendarScreenState extends State<BreedingCalendarScreen> {
  final BreedingRepository _repository = BreedingRepository();
  List<BreedingBatch> _batches = [];
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final batches = await _repository.getAllBatches();
    setState(() {
      _batches = batches;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('繁殖日历'),
      ),
      body: Column(
        children: [
          // 月份选择
          _buildMonthSelector(),
          // 日历网格
          Expanded(
            child: _buildCalendarGrid(),
          ),
          // 选中日期的事件列表
          if (_selectedDate != null)
            Expanded(
              child: _buildEventList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            '${_focusedMonth.year}年${_focusedMonth.month}月',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 周日为0
    final daysInMonth = lastDayOfMonth.day;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42, // 6周 * 7天
      itemBuilder: (context, index) {
        final dayNumber = index - firstWeekday + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox();
        }

        final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
        final events = _getEventsForDate(date);
        final isSelected = _selectedDate != null &&
            _selectedDate!.year == date.year &&
            _selectedDate!.month == date.month &&
            _selectedDate!.day == date.day;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : null,
              borderRadius: BorderRadius.circular(8),
              border: events.isNotEmpty
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: events.isNotEmpty ? FontWeight.bold : null,
                  ),
                ),
                if (events.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(3).map((event) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 2, right: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : _getEventColor(event),
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventList() {
    if (_selectedDate == null) return const SizedBox();

    final events = _getEventsForDate(_selectedDate!);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedDate!.month}月${_selectedDate!.day}日',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (events.isEmpty)
            const Text('无繁殖事件')
          else
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        _getEventIcon(event),
                        color: _getEventColor(event),
                      ),
                      title: Text(event['title'] ?? ''),
                      subtitle: Text(event['reptile'] ?? ''),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    final events = <Map<String, dynamic>>[];

    for (var batch in _batches) {
      // 交配日期
      if (_isSameDay(batch.matingDate, date)) {
        events.add({
          'type': 'mating',
          'title': '交配',
          'reptile': batch.reptileName,
        });
      }

      // 产蛋日期
      if (batch.eggLayingDate != null && _isSameDay(batch.eggLayingDate!, date)) {
        events.add({
          'type': 'egg_laying',
          'title': '产蛋',
          'reptile': batch.reptileName,
        });
      }

      // 孵化开始
      if (batch.incubationStartDate != null && _isSameDay(batch.incubationStartDate!, date)) {
        events.add({
          'type': 'incubation',
          'title': '开始孵化',
          'reptile': batch.reptileName,
        });
      }

      // 预计出壳
      if (batch.expectedHatchDate != null && _isSameDay(batch.expectedHatchDate!, date)) {
        events.add({
          'type': 'hatching',
          'title': '预计出壳',
          'reptile': batch.reptileName,
        });
      }
    }

    return events;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _getEventColor(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'mating':
        return Colors.pink;
      case 'egg_laying':
        return Colors.orange;
      case 'incubation':
        return Colors.blue;
      case 'hatching':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'mating':
        return Icons.favorite;
      case 'egg_laying':
        return Icons.egg;
      case 'incubation':
        return Icons.thermostat;
      case 'hatching':
        return Icons.pets;
      default:
        return Icons.event;
    }
  }
}
