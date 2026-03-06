import 'package:flutter/material.dart';
import '../../data/models/article.dart';
import '../../data/models/faq.dart';
import '../../data/repositories/repositories.dart';
import 'knowledge_detail_screen.dart';

class KnowledgeSearchScreen extends StatefulWidget {
  const KnowledgeSearchScreen({super.key});

  @override
  State<KnowledgeSearchScreen> createState() => _KnowledgeSearchScreenState();
}

class _KnowledgeSearchScreenState extends State<KnowledgeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final KnowledgeRepository _repository = KnowledgeRepository();
  final FocusNode _focusNode = FocusNode();

  String _keyword = '';
  bool _isSearching = false;
  KnowledgeSearchResult? _searchResult;

  @override
  void initState() {
    super.initState();
    // 自动弹出键盘
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _keyword = keyword;
      _isSearching = true;
    });

    _searchResult = await _repository.searchAll(keyword);

    setState(() {
      _isSearching = false;
    });
  }

  void _navigateToArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KnowledgeDetailScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: '搜索知识库...',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _keyword = '';
                          _searchResult = null;
                        });
                      },
                    )
                  : null,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_keyword.isEmpty) {
      return _buildSearchHint();
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResult == null || _searchResult!.isEmpty) {
      return _buildNoResult();
    }

    return _buildSearchResult();
  }

  Widget _buildSearchHint() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '热门搜索',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              '新手入门',
              '守宫饲养',
              '蛇类喂食',
              '疾病预防',
              '环境布置',
              '繁殖技术',
            ].map((keyword) {
              return ActionChip(
                label: Text(keyword),
                onPressed: () {
                  _searchController.text = keyword;
                  _performSearch();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            '搜索建议',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('爬宠多久喂一次食？'),
            dense: true,
            onTap: () {
              _searchController.text = '喂食';
              _performSearch();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('如何布置饲养箱？'),
            dense: true,
            onTap: () {
              _searchController.text = '饲养箱';
              _performSearch();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('爬宠常见疾病有哪些？'),
            dense: true,
            onTap: () {
              _searchController.text = '疾病';
              _performSearch();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '未找到相关内容',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '试试其他关键词',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResult() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 搜索统计
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '找到 ${_searchResult!.totalCount} 个结果',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        // 文章结果
        if (_searchResult!.articles.isNotEmpty) ...[
          Text(
            '文章',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ..._searchResult!.articles.map((article) => _buildArticleItem(article)),
          const SizedBox(height: 16),
        ],

        // FAQ结果
        if (_searchResult!.faqs.isNotEmpty) ...[
          Text(
            '常见问题',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ..._searchResult!.faqs.map((faq) => _buildFAQItem(faq)),
        ],
      ],
    );
  }

  Widget _buildArticleItem(Article article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              article.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(article.difficultyColorValue).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    article.difficultyName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(article.difficultyColorValue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.visibility_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${article.readCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _navigateToArticle(article),
      ),
    );
  }

  Widget _buildFAQItem(FAQ faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          faq.question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq.answer,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
