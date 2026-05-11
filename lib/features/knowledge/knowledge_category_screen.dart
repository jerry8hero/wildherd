import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/knowledge_category.dart';
import '../../data/models/article.dart';
import '../../data/models/knowledge_tip.dart';
import '../../data/models/faq.dart';
import '../../app/providers.dart';
import 'knowledge_detail_screen.dart';

class KnowledgeCategoryScreen extends ConsumerStatefulWidget {
  final KnowledgeCategory category;

  const KnowledgeCategoryScreen({super.key, required this.category});

  @override
  ConsumerState<KnowledgeCategoryScreen> createState() => _KnowledgeCategoryScreenState();
}

class _KnowledgeCategoryScreenState extends ConsumerState<KnowledgeCategoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<KnowledgeCategory> _subCategories = [];
  List<Article> _articles = [];
  List<KnowledgeTip> _tips = [];
  List<FAQ> _faqs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _subCategories = ref.read(knowledgeRepositoryProvider).getSubCategories(widget.category.id);
    _articles = await ref.read(knowledgeRepositoryProvider).getArticlesByCategory(widget.category.id);
    _tips = await ref.read(knowledgeRepositoryProvider).getTipsByCategory(widget.category.id);
    _faqs = await ref.read(knowledgeRepositoryProvider).getFAQsByCategory(widget.category.id);

    setState(() => _isLoading = false);
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
    final icons = {
      'beginner': Icons.school,
      'species': Icons.pets,
      'care': Icons.home,
      'health': Icons.medical_services,
      'breeding': Icons.egg,
      'equipment': Icons.build,
    };

    final iconData = icons[widget.category.id] ?? Icons.article;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.category.name),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 子分类
                    if (_subCategories.isNotEmpty) ...[
                      Text(
                        '子分类',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _subCategories.map((sub) {
                          return ActionChip(
                            label: Text(sub.name),
                            avatar: const Icon(
                              Icons.subdirectory_arrow_right,
                              size: 16,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      KnowledgeCategoryScreen(category: sub),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '文章'),
                    Tab(text: '技巧'),
                    Tab(text: '问答'),
                  ],
                ),
                Theme.of(context).colorScheme.surface,
              ),
            ),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildArticleList(),
                  _buildTipList(),
                  _buildFAQList(),
                ],
              ),
      ),
    );
  }

  Widget _buildArticleList() {
    if (_articles.isEmpty) {
      return _buildEmptyState('暂无文章');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return _buildArticleCard(article);
      },
    );
  }

  Widget _buildArticleCard(Article article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToArticle(article),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(article.difficultyColorValue).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article.difficultyName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(article.difficultyColorValue),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${article.readTimeMinutes}分钟',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                article.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
              // 标签
              if (article.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: article.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(fontSize: 10),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipList() {
    if (_tips.isEmpty) {
      return _buildEmptyState('暂无技巧');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tips.length,
      itemBuilder: (context, index) {
        final tip = _tips[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: Text(tip.title),
            subtitle: Text(
              tip.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(tip.content),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFAQList() {
    if (_faqs.isEmpty) {
      return _buildEmptyState('暂无问答');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        final faq = _faqs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: const Icon(Icons.help_outline),
            title: Text(
              faq.question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq.answer,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${faq.helpfulCount} 人觉得有用',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || backgroundColor != oldDelegate.backgroundColor;
  }
}
