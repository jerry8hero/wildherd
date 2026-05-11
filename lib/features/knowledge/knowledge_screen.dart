import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/knowledge_category.dart';
import '../../data/models/article.dart';
import '../../app/providers.dart';
import 'knowledge_search_screen.dart';
import 'knowledge_category_screen.dart';
import 'knowledge_detail_screen.dart';
import 'knowledge_collection_screen.dart';

class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  List<KnowledgeCategory> _topCategories = [];
  List<Article> _featuredArticles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _topCategories = ref.read(knowledgeRepositoryProvider).getTopCategories();
    _featuredArticles = await ref.read(knowledgeRepositoryProvider).getFeaturedArticles();

    setState(() => _isLoading = false);
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KnowledgeSearchScreen()),
    );
  }

  void _navigateToCategory(KnowledgeCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KnowledgeCategoryScreen(category: category),
      ),
    );
  }

  void _navigateToArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KnowledgeDetailScreen(article: article),
      ),
    );
  }

  void _navigateToCollections() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KnowledgeCollectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // 应用栏（带搜索）
                  SliverAppBar(
                    floating: true,
                    title: const Text('知识库'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.bookmark_outline),
                        onPressed: _navigateToCollections,
                        tooltip: '我的收藏',
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(56),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: GestureDetector(
                          onTap: _navigateToSearch,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.search,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '搜索知识库...',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 知识分类入口
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '知识分类',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          _buildCategoryGrid(),
                        ],
                      ),
                    ),
                  ),

                  // 精选文章
                  if (_featuredArticles.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '精选推荐',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            TextButton(
                              onPressed: () => _navigateToCategory(_topCategories.first),
                              child: const Text('查看更多'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _featuredArticles.length,
                          itemBuilder: (context, index) {
                            return _buildFeaturedCard(_featuredArticles[index]);
                          },
                        ),
                      ),
                    ),
                  ],

                  // 底部留白
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryGrid() {
    final icons = {
      'beginner': Icons.school,
      'species': Icons.pets,
      'care': Icons.home,
      'health': Icons.medical_services,
      'breeding': Icons.egg,
      'equipment': Icons.build,
    };

    final colors = {
      'beginner': Colors.blue,
      'species': Colors.green,
      'care': Colors.orange,
      'health': Colors.red,
      'breeding': Colors.purple,
      'equipment': Colors.teal,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _topCategories.length,
      itemBuilder: (context, index) {
        final category = _topCategories[index];
        final iconData = icons[category.id] ?? Icons.article;
        final color = colors[category.id] ?? Colors.grey;

        return _buildCategoryCard(category, iconData, color);
      },
    );
  }

  Widget _buildCategoryCard(KnowledgeCategory category, IconData iconData, Color color) {
    return GestureDetector(
      onTap: () => _navigateToCategory(category),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(Article article) {
    return GestureDetector(
      onTap: () => _navigateToArticle(article),
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题区域
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 难度标签
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(article.difficultyColorValue).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article.difficultyName,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(article.difficultyColorValue),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${article.readTimeMinutes}分钟',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 标题
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 摘要
                  Text(
                    article.summary,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // 底部信息
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${article.readCount}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (article.isCollection)
                    Icon(
                      Icons.bookmark,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
