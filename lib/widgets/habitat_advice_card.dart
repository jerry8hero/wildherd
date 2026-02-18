import 'package:flutter/material.dart';
import '../data/models/habitat.dart';

/// 智能建议卡片组件
class HabitatAdviceCard extends StatelessWidget {
  final HabitatSuggestion suggestion;
  final VoidCallback? onTap;

  const HabitatAdviceCard({
    super.key,
    required this.suggestion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getPriorityColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: _getPriorityColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            suggestion.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getPriorityText(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _getPriorityColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (suggestion.category) {
      case 'temperature':
        return Icons.thermostat;
      case 'humidity':
        return Icons.water_drop;
      case 'uv':
        return Icons.wb_sunny;
      case 'space':
        return Icons.square_foot;
      case 'substrate':
        return Icons.grass;
      case 'lighting':
        return Icons.lightbulb;
      default:
        return Icons.info;
    }
  }

  Color _getPriorityColor() {
    switch (suggestion.priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText() {
    switch (suggestion.priority) {
      case 'high':
        return '重要';
      case 'medium':
        return '建议';
      case 'low':
        return '可选';
      default:
        return '普通';
    }
  }
}

/// 建议列表组件
class HabitatAdviceList extends StatelessWidget {
  final List<HabitatSuggestion> suggestions;
  final Function(HabitatSuggestion)? onSuggestionTap;

  const HabitatAdviceList({
    super.key,
    required this.suggestions,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '环境设置良好！暂无需要改进的地方。',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 按优先级排序
    final sortedSuggestions = List<HabitatSuggestion>.from(suggestions)
      ..sort((a, b) {
        final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates, size: 18, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                '改进建议 (${suggestions.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        ...sortedSuggestions.map((suggestion) => HabitatAdviceCard(
          suggestion: suggestion,
          onTap: onSuggestionTap != null ? () => onSuggestionTap!(suggestion) : null,
        )),
      ],
    );
  }
}
