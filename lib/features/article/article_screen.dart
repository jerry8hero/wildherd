import 'package:flutter/material.dart';
import '../../data/models/article.dart';
import '../../data/repositories/repositories.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final EncyclopediaRepository _repository = EncyclopediaRepository();
  List<Article> _articles = [];
  List<Article> _featuredArticles = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _repository.initArticleData();
      final articles = await _repository.getAllArticles();
      final featured = articles.where((a) => a.isFeatured).toList();
      setState(() {
        _articles = articles;
        _featuredArticles = featured;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Article>> getAllArticles() async {
    await _repository.initArticleData();
    return await _repository.getAllArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识文章'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // 轮播推荐
                  if (_featuredArticles.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildFeaturedSection(),
                    ),
                  // 分类筛选
                  SliverToBoxAdapter(
                    child: _buildCategoryFilter(),
                  ),
                  // 文章列表
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: _buildArticleList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeaturedSection() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: _featuredArticles.length,
        itemBuilder: (context, index) {
          final article = _featuredArticles[index];
          return _buildFeaturedCard(article);
        },
      ),
    );
  }

  Widget _buildFeaturedCard(Article article) {
    return GestureDetector(
      onTap: () => _navigateToDetail(article),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[400]!,
              Colors.blue[700]!,
            ],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '推荐',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.visibility, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${article.readCount}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        article.categoryName,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildCategoryChip('all', '全部'),
          _buildCategoryChip('feeding', '饲养'),
          _buildCategoryChip('health', '健康'),
          _buildCategoryChip('housing', '环境'),
          _buildCategoryChip('breeding', '繁殖'),
          _buildCategoryChip('species', '物种'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? value : 'all';
          });
        },
      ),
    );
  }

  Widget _buildArticleList() {
    final filteredArticles = _selectedCategory == 'all'
        ? _articles
        : _articles.where((a) => a.category == _selectedCategory).toList();

    if (filteredArticles.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                '暂无文章',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildArticleCard(filteredArticles[index]);
        },
        childCount: filteredArticles.length,
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(article),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 缩略图
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: article.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          article.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.article, color: Colors.blue[700]);
                          },
                        ),
                      )
                    : Icon(Icons.article, color: Colors.blue[700]),
              ),
              const SizedBox(width: 16),
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.summary,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            article.categoryName,
                            style: TextStyle(color: Colors.blue[700], fontSize: 11),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.visibility, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${article.readCount}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
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

  void _navigateToDetail(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(articleId: article.id),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showSearch(
      context: context,
      delegate: ArticleSearchDelegate(repository: _repository),
    );
  }
}

// 文章详情页
class ArticleDetailScreen extends StatefulWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final EncyclopediaRepository _repository = EncyclopediaRepository();
  Article? _article;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _repository.initArticleData();
      final article = await _repository.getArticleDetail(widget.articleId);
      setState(() {
        _article = article;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _article == null
              ? const Center(child: Text('文章不存在'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final article = _article!;
    return CustomScrollView(
      slivers: [
        // 应用栏
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              article.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[400]!,
                    Colors.blue[700]!,
                  ],
                ),
              ),
              child: article.imageUrl != null
                  ? Image.network(
                      article.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.article, size: 60, color: Colors.white54);
                      },
                    )
                  : const Icon(Icons.article, size: 60, color: Colors.white54),
            ),
          ),
        ),
        // 内容
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 作者和时间
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue[100],
                      child: Text(article.author[0], style: TextStyle(color: Colors.blue[700])),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      article.author,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(article.createdAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 统计
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text('${article.readCount} 次阅读', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article.categoryName,
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                // 标签
                if (article.tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: article.tags.map((tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                // 摘要
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article.summary,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 正文
                Text(
                  article.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// 搜索代理
class ArticleSearchDelegate extends SearchDelegate<String> {
  final EncyclopediaRepository repository;

  ArticleSearchDelegate({required this.repository});

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
      return const Center(child: Text('输入关键词搜索文章'));
    }
    return FutureBuilder<List<Article>>(
      future: repository.searchArticles(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data!;
        if (results.isEmpty) {
          return const Center(child: Text('未找到相关文章'));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final article = results[index];
            return ListTile(
              title: Text(article.title),
              subtitle: Text(article.summary, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                close(context, article.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailScreen(articleId: article.id),
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
