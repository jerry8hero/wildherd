import 'package:flutter/material.dart';
import '../../data/models/selection.dart';
import '../../data/local/selection_storage.dart';
import '../../app/theme.dart';

class ResultScreen extends StatelessWidget {
  final String speciesId;
  final String speciesName;

  const ResultScreen({
    super.key,
    required this.speciesId,
    required this.speciesName,
  });

  @override
  Widget build(BuildContext context) {
    final candidates = SelectionStorage.getBySpecies(speciesId);

    // 按评分排序
    final sorted = List<CandidatePet>.from(candidates)
      ..sort((a, b) => b.score.compareTo(a.score));

    // 获取最高分
    final topCandidate = sorted.isNotEmpty ? sorted.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('${speciesName}对比结果'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: sorted.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 推荐结果
                  if (topCandidate != null) _buildTopRecommendation(topCandidate),
                  const SizedBox(height: 24),

                  // 对比图表
                  const Text(
                    '评分对比',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...sorted.map((c) => _buildScoreBar(c, sorted.first)),

                  const SizedBox(height: 24),

                  // 详细对比
                  const Text(
                    '各项对比',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailedComparison(sorted),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '暂无对比数据',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请先添加候选宠物并完成检查',
            style: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRecommendation(CandidatePet candidate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.greenAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            '推荐入手',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            candidate.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${candidate.score.toInt()}分',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(CandidatePet candidate, CandidatePet topCandidate) {
    final percentage = topCandidate.score > 0
        ? candidate.score / topCandidate.score
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                candidate.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${candidate.score.toInt()}分',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(candidate.score),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getScoreColor(candidate.score),
              ),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedComparison(List<CandidatePet> candidates) {
    if (candidates.isEmpty || candidates.first.checks.isEmpty) {
      return const SizedBox.shrink();
    }

    final checkTitles = candidates.first.checks.map((c) => c.title).toList();

    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: {
        0: const FlexColumnWidth(2),
        ...List.generate(candidates.length, (i) => i + 1)
            .toList()
            .asMap()
            .map((k, v) => (k + 1, const FlexColumnWidth(1))),
      },
      children: [
        // 表头
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('检查项', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...candidates.map((c) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    c.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )),
          ],
        ),
        // 数据行
        ...checkTitles.asMap().entries.map((entry) {
          final title = entry.value;
          final index = entry.key;
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(title, style: const TextStyle(fontSize: 12)),
              ),
              ...candidates.map((c) {
                final isChecked = index < c.checks.length && c.checks[index].isChecked;
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isChecked ? Icons.check_circle : Icons.cancel,
                    color: isChecked ? Colors.green : Colors.red[300],
                    size: 20,
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
