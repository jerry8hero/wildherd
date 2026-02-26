import 'package:flutter/material.dart';
import '../../data/models/qa.dart';
import '../../data/repositories/repositories.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final QARepository _repository = QARepository();
  List<Question> _questions = [];
  List<QATag> _tags = [];
  bool _isLoading = true;
  String _sortBy = 'latest';
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final questions = await _repository.getAllQuestions(sortBy: _sortBy);
      final tags = await _repository.getTags();
      setState(() {
        _questions = questions;
        _tags = tags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('问答社区'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 标签筛选
          _buildTagFilter(),
          // 排序选项
          _buildSortOptions(),
          // 问题列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _questions.isEmpty
                    ? _buildEmptyState()
                    : _buildQuestionList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAskQuestion(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTagFilter() {
    if (_tags.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _tags.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('全部'),
                selected: _selectedTag == null,
                onSelected: (selected) {
                  setState(() => _selectedTag = null);
                  _loadData();
                },
              ),
            );
          }
          final tag = _tags[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(tag.nameZh),
              selected: _selectedTag == tag.name,
              onSelected: (selected) {
                setState(() => _selectedTag = selected ? tag.name : null);
                if (selected) {
                  _loadQuestionsByTag(tag.name);
                } else {
                  _loadData();
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildSortChip('latest', '最新'),
          const SizedBox(width: 8),
          _buildSortChip('hot', '热门'),
          const SizedBox(width: 8),
          _buildSortChip('unanswered', '待解答'),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _sortBy = value);
          _loadData();
        }
      },
    );
  }

  Widget _buildQuestionList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          return _buildQuestionCard(_questions[index]);
        },
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(question),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 状态标签
              if (question.isResolved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '已解决',
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 8),
              // 标题
              Text(
                question.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // 内容预览
              Text(
                question.content,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // 底部信息
              Row(
                children: [
                  if (question.speciesName != null) ...[
                    Icon(Icons.pets, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      question.speciesName!,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(Icons.visibility, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${question.viewCount}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.comment, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${question.answerCount}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.question_answer, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '暂无问题',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _navigateToAskQuestion(context),
            child: const Text('提问'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showSearch(
      context: context,
      delegate: QASearchDelegate(repository: _repository),
    );
  }

  Future<void> _loadQuestionsByTag(String tag) async {
    setState(() => _isLoading = true);
    try {
      final questions = await _repository.getQuestionsByTag(tag);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDetail(Question question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QADetailScreen(questionId: question.id),
      ),
    );
  }

  void _navigateToAskQuestion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AskQuestionScreen(),
      ),
    ).then((_) => _loadData());
  }
}

// 问题详情页
class QADetailScreen extends StatefulWidget {
  final String questionId;

  const QADetailScreen({super.key, required this.questionId});

  @override
  State<QADetailScreen> createState() => _QADetailScreenState();
}

class _QADetailScreenState extends State<QADetailScreen> {
  final QARepository _repository = QARepository();
  Question? _question;
  List<Answer> _answers = [];
  bool _isLoading = true;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final question = await _repository.getQuestionDetail(widget.questionId);
      final answers = await _repository.getAnswers(widget.questionId);
      await _repository.viewQuestion(widget.questionId);
      setState(() {
        _question = question;
        _answers = answers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('问题详情'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _question == null
              ? const Center(child: Text('问题不存在'))
              : _buildContent(),
      bottomNavigationBar: _buildAnswerInput(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 问题标题
          Text(
            _question!.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // 用户信息
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Text(_question!.userName[0]),
              ),
              const SizedBox(width: 8),
              Text(
                _question!.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(_question!.createdAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 问题内容
          Text(
            _question!.content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 12),
          // 标签
          if (_question!.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: _question!.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          // 统计
          Row(
            children: [
              Icon(Icons.visibility, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('${_question!.viewCount} 次浏览'),
              const SizedBox(width: 16),
              Icon(Icons.comment, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('${_question!.answerCount} 个回答'),
            ],
          ),
          const Divider(height: 32),
          // 回答列表
          Text(
            '${_answers.length} 个回答',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._answers.map((answer) => _buildAnswerCard(answer)),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(Answer answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: answer.isAccepted ? Colors.green[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 采纳标识
            if (answer.isAccepted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '最佳答案',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            // 用户信息
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey[300],
                  child: Text(answer.userName[0], style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Text(
                  answer.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(answer.createdAt),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 回答内容
            Text(
              answer.content,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 12),
            // 操作按钮
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined, size: 20),
                  onPressed: () => _likeAnswer(answer.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text('${answer.likes}'),
                if (_question!.userId == 'user1' && !_question!.isResolved) ...[
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => _acceptAnswer(answer.id),
                    child: const Text('采纳'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: '写下你的回答...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitAnswer,
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.isEmpty) return;
    final answer = Answer(
      id: 'a${DateTime.now().millisecondsSinceEpoch}',
      questionId: widget.questionId,
      userId: 'current_user',
      userName: '当前用户',
      content: _answerController.text,
      createdAt: DateTime.now(),
    );
    await _repository.addAnswer(answer);
    _answerController.clear();
    _loadData();
  }

  Future<void> _likeAnswer(String answerId) async {
    await _repository.likeAnswer(answerId);
    _loadData();
  }

  Future<void> _acceptAnswer(String answerId) async {
    await _repository.acceptAnswer(widget.questionId, answerId);
    _loadData();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 30) {
      return '${date.year}-${date.month}-${date.day}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

// 提问页面
class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final QARepository _repository = QARepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedSpeciesId;
  String? _selectedSpeciesName;
  final List<String> _selectedTags = [];
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提问'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitQuestion,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('发布'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题输入
            const Text(
              '问题标题',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '简洁描述你的问题...',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            // 内容输入
            const Text(
              '详细描述',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: '描述问题详情、已尝试的解决方法等...',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
              maxLength: 2000,
            ),
            const SizedBox(height: 16),
            // 关联物种
            const Text(
              '关联物种（可选）',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('无'),
                  selected: _selectedSpeciesId == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpeciesId = null;
                      _selectedSpeciesName = null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('玉米蛇'),
                  selected: _selectedSpeciesId == '1',
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpeciesId = selected ? '1' : null;
                      _selectedSpeciesName = selected ? '玉米蛇' : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('豹纹守宫'),
                  selected: _selectedSpeciesId == '3',
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpeciesId = selected ? '3' : null;
                      _selectedSpeciesName = selected ? '豹纹守宫' : null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 标签选择
            const Text(
              '标签',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTagChip('饲养', 'feeding'),
                _buildTagChip('环境', 'environment'),
                _buildTagChip('健康', 'health'),
                _buildTagChip('繁殖', 'breeding'),
                _buildTagChip('物种选择', 'species'),
                _buildTagChip('行为习性', 'behavior'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String label, String tag) {
    final isSelected = _selectedTags.contains(tag);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedTags.add(tag);
          } else {
            _selectedTags.remove(tag);
          }
        });
      },
    );
  }

  Future<void> _submitQuestion() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入问题标题')),
      );
      return;
    }
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入问题详情')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final question = Question(
      id: 'q${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      content: _contentController.text,
      userId: 'current_user',
      userName: '当前用户',
      speciesId: _selectedSpeciesId,
      speciesName: _selectedSpeciesName,
      tags: _selectedTags,
      createdAt: DateTime.now(),
    );

    await _repository.addQuestion(question);
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

// 搜索代理
class QASearchDelegate extends SearchDelegate<String> {
  final QARepository repository;

  QASearchDelegate({required this.repository});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('输入关键词搜索问题'));
    }
    return FutureBuilder<List<Question>>(
      future: repository.searchQuestions(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data!;
        if (results.isEmpty) {
          return const Center(child: Text('未找到相关问题'));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final question = results[index];
            return ListTile(
              title: Text(question.title),
              subtitle: Text(question.content, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                close(context, question.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QADetailScreen(questionId: question.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
