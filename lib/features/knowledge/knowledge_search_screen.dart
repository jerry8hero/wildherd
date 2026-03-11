import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/article.dart';
import '../../data/models/faq.dart';
import '../../data/repositories/repositories.dart';
import '../../data/services/online_encyclopedia_service.dart';
import 'knowledge_detail_screen.dart';

/// 搜索模式：本地或联网
enum SearchMode { local, online }

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
  SearchMode _searchMode = SearchMode.local;
  List<OnlineEncyclopediaResult> _onlineResults = [];

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
      _onlineResults = [];
    });

    if (_searchMode == SearchMode.online) {
      // 联网搜索
      _onlineResults = await OnlineEncyclopediaService.searchReptile(keyword);
    } else {
      // 本地搜索
      _searchResult = await _repository.searchAll(keyword);
    }

    setState(() {
      _isSearching = false;
    });
  }

  /// 切换搜索模式
  void _toggleSearchMode() {
    setState(() {
      _searchMode = _searchMode == SearchMode.local ? SearchMode.online : SearchMode.local;
      _keyword = '';
      _searchResult = null;
      _onlineResults = [];
    });
  }

  /// 打开Wikipedia链接
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
              hintText: _searchMode == SearchMode.online ? '联网搜索Wikipedia...' : '搜索知识库...',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _keyword = '';
                          _searchResult = null;
                          _onlineResults = [];
                        });
                      },
                    ),
                  // 搜索模式切换按钮
                  IconButton(
                    icon: Icon(
                      _searchMode == SearchMode.online ? Icons.wifi : Icons.wifi_off,
                      color: _searchMode == SearchMode.online
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    tooltip: _searchMode == SearchMode.online ? '联网搜索中' : '点击切换到联网搜索',
                    onPressed: _toggleSearchMode,
                  ),
                ],
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        actions: [
          // 显示当前搜索模式
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(
                _searchMode == SearchMode.online ? '联网' : '本地',
                style: TextStyle(
                  fontSize: 12,
                  color: _searchMode == SearchMode.online
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              backgroundColor: _searchMode == SearchMode.online
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_keyword.isEmpty) {
      return _buildSearchHint();
    }

    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _searchMode == SearchMode.online ? '正在联网搜索...' : '正在搜索...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // 联网搜索结果
    if (_searchMode == SearchMode.online) {
      if (_onlineResults.isEmpty) {
        return _buildNoResult();
      }
      return _buildOnlineSearchResult();
    }

    // 本地搜索结果
    if (_searchResult == null || _searchResult!.isEmpty) {
      return _buildNoResult();
    }

    return _buildSearchResult();
  }

  Widget _buildSearchHint() {
    // 联网模式的热门搜索
    if (_searchMode == SearchMode.online) {
      return _buildOnlineSearchHint();
    }

    // 本地模式的热门搜索
    return _buildLocalSearchHint();
  }

  /// 本地搜索提示
  Widget _buildLocalSearchHint() {
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

  /// 联网搜索提示 - 显示常见爬宠物种
  Widget _buildOnlineSearchHint() {
    final suggestions = [
      'turtle',
      'tortoise',
      'gecko',
      'leopard gecko',
      'corn snake',
      'bearded dragon',
      'ball python',
      'crested gecko',
      'lizard',
      'reptile',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 模式说明
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '联网百科搜索',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          '搜索 Wikipedia 获取更多爬宠知识',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '试试搜索',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((keyword) {
              return ActionChip(
                avatar: const Icon(Icons.search, size: 18),
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
            '常见爬宠英文名',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildReptileList(),
        ],
      ),
    );
  }

  Widget _buildReptileList() {
    final reptiles = [
      {'name': 'Red-eared slider', 'nameCn': '巴西龟'},
      {'name': 'Leopard gecko', 'nameCn': '豹纹守宫'},
      {'name': 'Corn snake', 'nameCn': '玉米蛇'},
      {'name': 'Bearded dragon', 'nameCn': '鬃狮蜥'},
      {'name': 'Ball python', 'nameCn': '球蟒'},
      {'name': 'Crested gecko', 'nameCn': '睫角守宫'},
    ];

    return Column(
      children: reptiles.map((reptile) {
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.pets),
          ),
          title: Text(reptile['name']!),
          subtitle: Text(reptile['nameCn']!),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _searchController.text = reptile['name']!;
            _performSearch();
          },
        );
      }).toList(),
    );
  }

  /// 构建联网搜索结果
  Widget _buildOnlineSearchResult() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 搜索统计
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(
                Icons.language,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Wikipedia 搜索结果 (${_onlineResults.length})',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ..._onlineResults.map((result) => _buildOnlineResultItem(result)),
      ],
    );
  }

  Widget _buildOnlineResultItem(OnlineEncyclopediaResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openUrl(result.url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      result.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              if (result.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  result.description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '点击查看完整Wikipedia页面',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
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
