import 'package:flutter/material.dart';
import '../../data/models/selection.dart';
import '../../data/local/selection_storage.dart';
import '../../app/theme.dart';

class ChecklistScreen extends StatefulWidget {
  final CandidatePet candidate;

  const ChecklistScreen({
    super.key,
    required this.candidate,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late List<CheckItem> _checks;

  @override
  void initState() {
    super.initState();
    _checks = List.from(widget.candidate.checks);
  }

  void _toggleCheck(int index) {
    setState(() {
      _checks[index] = _checks[index].copyWith(
        isChecked: !_checks[index].isChecked,
      );
    });
  }

  void _saveAndExit() {
    final updatedCandidate = widget.candidate.copyWith(checks: _checks);
    SelectionStorage.update(updatedCandidate);
    Navigator.pop(context);
  }

  double get _progress {
    if (_checks.isEmpty) return 0;
    return _checks.where((c) => c.isChecked).length / _checks.length;
  }

  double get _score {
    if (_checks.isEmpty) return 0;
    int totalWeight = _checks.fold(0, (sum, item) => sum + item.weight);
    int passedWeight = _checks
        .where((item) => item.isChecked)
        .fold(0, (sum, item) => sum + item.weight);
    if (totalWeight == 0) return 0;
    return (passedWeight / totalWeight) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('检查${widget.candidate.name}'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          TextButton(
            onPressed: _saveAndExit,
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 进度头
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '进度: ${_checks.where((c) => c.isChecked).length}/${_checks.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '当前评分: ${_score.toInt()}分',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _getScoreColor(_score),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
          // 检查项列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _checks.length,
              itemBuilder: (context, index) {
                final check = _checks[index];
                return _buildCheckItem(check, index);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saveAndExit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              '保存并退出',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(CheckItem check, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _toggleCheck(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: check.isChecked
                      ? Colors.green
                      : Colors.grey[300],
                ),
                child: check.isChecked
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          check.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: check.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            color: check.isChecked
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildWeightStars(check.weight),
                      ],
                    ),
                    if (check.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        check.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightStars(int weight) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(weight, (index) {
        return Icon(
          Icons.star,
          size: 14,
          color: Colors.orange[700],
        );
      }),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
