import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/knowledge_collection.dart';
import '../../app/providers.dart';
import 'knowledge_detail_screen.dart';

class KnowledgeCollectionScreen extends ConsumerStatefulWidget {
  const KnowledgeCollectionScreen({super.key});

  @override
  ConsumerState<KnowledgeCollectionScreen> createState() => _KnowledgeCollectionScreenState();
}

class _KnowledgeCollectionScreenState extends ConsumerState<KnowledgeCollectionScreen> {
  List<KnowledgeCollection> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    _collections = await ref.read(knowledgeRepositoryProvider).getCollections();
    setState(() => _isLoading = false);
  }

  Future<void> _removeCollection(KnowledgeCollection collection) async {
    await ref.read(knowledgeRepositoryProvider).removeCollection(collection.itemId);
    await _loadCollections();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已取消收藏'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _navigateToArticle(String articleId) async {
    final article = await ref.read(knowledgeRepositoryProvider).getArticleDetail(articleId);
    if (article != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KnowledgeDetailScreen(article: article),
        ),
      );
    }
  }

  IconData _getTypeIcon(String itemType) {
    switch (itemType) {
      case 'article':
        return Icons.article;
      case 'tip':
        return Icons.lightbulb;
      case 'species':
        return Icons.pets;
      case 'question':
        return Icons.question_answer;
      default:
        return Icons.bookmark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        actions: [
          if (_collections.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('清空收藏'),
                    content: const Text('确定要清空所有收藏吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          for (var collection in _collections) {
                            await ref.read(knowledgeRepositoryProvider).removeCollection(collection.itemId);
                          }
                          await _loadCollections();
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _collections.isEmpty
              ? _buildEmptyState()
              : _buildCollectionList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无收藏',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '收藏的文章会在此处显示',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionList() {
    return RefreshIndicator(
      onRefresh: _loadCollections,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _collections.length,
        itemBuilder: (context, index) {
          final collection = _collections[index];
          return _buildCollectionItem(collection);
        },
      ),
    );
  }

  Widget _buildCollectionItem(KnowledgeCollection collection) {
    return Dismissible(
      key: Key(collection.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _removeCollection(collection),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(collection.itemType),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            collection.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (collection.summary != null && collection.summary!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  collection.summary!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      collection.itemTypeName,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(collection.collectedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            if (collection.itemType == 'article') {
              _navigateToArticle(collection.itemId);
            }
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '今天';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}
