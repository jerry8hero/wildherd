import 'package:flutter/material.dart';
import '../../data/models/selection.dart';
import '../../data/local/selection_storage.dart';
import '../../app/theme.dart';
import 'checklist_screen.dart';
import 'result_screen.dart';

class CandidateListScreen extends StatefulWidget {
  final String speciesId;
  final String speciesName;

  const CandidateListScreen({
    super.key,
    required this.speciesId,
    required this.speciesName,
  });

  @override
  State<CandidateListScreen> createState() => _CandidateListScreenState();
}

class _CandidateListScreenState extends State<CandidateListScreen> {
  List<CandidatePet> _candidates = [];

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  void _loadCandidates() {
    setState(() {
      _candidates = SelectionStorage.getBySpecies(widget.speciesId);
    });
  }

  void _addCandidate() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('添加候选宠物'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: '名称',
              hintText: '例如：店A、朋友家',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final candidate = CandidatePet(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    speciesId: widget.speciesId,
                    speciesName: widget.speciesName,
                    name: controller.text,
                    checks: getDefaultChecks(widget.speciesId),
                    createdAt: DateTime.now(),
                  );
                  SelectionStorage.add(candidate);
                  _loadCandidates();
                  Navigator.pop(context);
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCandidate(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个候选吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              SelectionStorage.delete(id);
              _loadCandidates();
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('挑选${widget.speciesName}'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          if (_candidates.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      speciesId: widget.speciesId,
                      speciesName: widget.speciesName,
                    ),
                  ),
                );
              },
              child: const Text(
                '查看结果',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _candidates.isEmpty
          ? _buildEmptyState()
          : _buildCandidateList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCandidate,
        icon: const Icon(Icons.add),
        label: const Text('添加候选'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '还没有添加候选宠物',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加候选宠物',
            style: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _candidates.length,
      itemBuilder: (context, index) {
        final candidate = _candidates[index];
        return _buildCandidateCard(candidate);
      },
    );
  }

  Widget _buildCandidateCard(CandidatePet candidate) {
    final progress = candidate.progress;
    final score = candidate.score;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChecklistScreen(candidate: candidate),
            ),
          );
          _loadCandidates();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '已检查 ${candidate.checkedCount}/${candidate.checks.length} 项',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${score.toInt()}分',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(score),
                        ),
                      ),
                      Text(
                        _getScoreLabel(score),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getScoreColor(score),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteCandidate(candidate.id),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return '优秀';
    if (score >= 60) return '良好';
    if (score >= 40) return '一般';
    return '较差';
  }
}
