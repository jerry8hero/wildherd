import 'package:flutter/material.dart';
import '../../data/models/article.dart';
import '../../data/models/knowledge_collection.dart';
import '../../data/repositories/repositories.dart';

class KnowledgeDetailScreen extends StatefulWidget {
  final Article article;

  const KnowledgeDetailScreen({super.key, required this.article});

  @override
  State<KnowledgeDetailScreen> createState() => _KnowledgeDetailScreenState();
}

class _KnowledgeDetailScreenState extends State<KnowledgeDetailScreen> {
  final KnowledgeRepository _repository = KnowledgeRepository();
  late Article _article;
  bool _isCollected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _loadArticleDetail();
  }

  Future<void> _loadArticleDetail() async {
    final detail = await _repository.getArticleDetail(_article.id);
    if (detail != null) {
      setState(() {
        _article = detail;
        _isCollected = detail.isCollection;
      });
    }

    // 添加阅读历史
    await _repository.addReadHistory(ReadHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: _article.id,
      itemType: 'article',
      title: _article.title,
      imageUrl: _article.imageUrl,
      readAt: DateTime.now(),
    ));

    setState(() => _isLoading = false);
  }

  Future<void> _toggleCollection() async {
    final result = await _repository.toggleCollection(
      itemId: _article.id,
      itemType: 'article',
      title: _article.title,
      summary: _article.summary,
      imageUrl: _article.imageUrl,
    );

    setState(() {
      _isCollected = result;
      _article = _article.copyWith(isCollection: result);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ? '已收藏' : '已取消收藏'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // 应用栏
                SliverAppBar(
                  pinned: true,
                  title: Text(_article.title),
                  actions: [
                    IconButton(
                      icon: Icon(
                        _isCollected ? Icons.bookmark : Icons.bookmark_outline,
                      ),
                      onPressed: _toggleCollection,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // 分享功能
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('分享功能开发中')),
                        );
                      },
                    ),
                  ],
                ),

                // 文章内容
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Text(
                          _article.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),

                        // 元信息
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            // 难度
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(_article.difficultyColorValue).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.signal_cellular_alt,
                                    size: 14,
                                    color: Color(_article.difficultyColorValue),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _article.difficultyName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(_article.difficultyColorValue),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 阅读时间
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_article.readTimeMinutes}分钟阅读',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            // 作者
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _article.author,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Divider(height: 32),

                        // 摘要
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.summarize,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _article.summary,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 标签
                        if (_article.tags.isNotEmpty) ...[
                          Text(
                            '标签',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _article.tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withValues(alpha: 0.5),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 正文内容
                        _buildContent(_article.content),

                        const SizedBox(height: 32),

                        // 相关推荐提示
                        if (_article.relatedSpeciesIds.isNotEmpty) ...[
                          Text(
                            '相关物种',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '本文关联的物种ID: ${_article.relatedSpeciesIds.join(", ")}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildContent(String content) {
    // 简单的Markdown解析
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      if (line.startsWith('# ')) {
        // 一级标题
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            line.substring(2),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ));
      } else if (line.startsWith('## ')) {
        // 二级标题
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            line.substring(3),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ));
      } else if (line.startsWith('### ')) {
        // 三级标题
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            line.substring(4),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        // 无序列表
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• '),
              Expanded(child: Text(line.substring(2))),
            ],
          ),
        ));
      } else if (line.startsWith('| ')) {
        // 表格行
        widgets.add(Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            line,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ));
      } else if (line.trim().isEmpty) {
        // 空行
        widgets.add(const SizedBox(height: 8));
      } else {
        // 普通段落
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            line,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
