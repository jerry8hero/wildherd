import 'package:flutter/material.dart';
import '../../data/models/community.dart';
import '../../app/theme.dart';
import '../../utils/image_utils.dart';
import '../../utils/date_utils.dart' as app_date;

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // 模拟数据 - 实际应从数据库获取
  final List<Post> _posts = [
    Post(
      id: '1',
      userId: 'user1',
      userName: '宠物爱好者小明',
      content: '今天给玉米蛇喂食了小白鼠，胃口很好！',
      images: [],
      reptileSpecies: '玉米蛇',
      likes: 24,
      comments: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Post(
      id: '2',
      userId: 'user2',
      userName: '守宫达人',
      content: '睫角守宫终于蜕皮完成了，看起来更漂亮了！',
      images: [],
      reptileSpecies: '睫角守宫',
      likes: 56,
      comments: 12,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Post(
      id: '3',
      userId: 'user3',
      userName: '鬃狮蜥铲屎官',
      content: '鬃狮蜥今天第一次吃蔬菜，很给面子！',
      images: [],
      reptileSpecies: '鬃狮蜥',
      likes: 89,
      comments: 23,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(_posts[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPost,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  backgroundImage: post.userAvatar != null && post.userAvatar!.isNotEmpty
                      ? ImageUtils.getImageProvider(post.userAvatar)
                      : null,
                  child: post.userAvatar == null || post.userAvatar!.isEmpty
                      ? Text(
                          post.userName.isNotEmpty ? post.userName[0] : '?',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        app_date.DateTimeUtils.formatRelativeTime(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.reptileSpecies != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.reptileSpecies!,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 内容
            Text(
              post.content,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),

            // 图片列表
            if (post.images.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: index < post.images.length - 1 ? 8 : 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image(
                          image: ImageUtils.getImageProvider(post.images[index]),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 互动按钮
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.favorite_border,
                  count: post.likes,
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  count: post.comments,
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    int? count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          if (count != null) ...[
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  void _createPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreatePostSheet(),
    );
  }
}

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _contentController = TextEditingController();
  String? _selectedSpecies;

  final List<String> _species = [
    '玉米蛇',
    '球蟒',
    '豹纹守宫',
    '鬃狮蜥',
    '绿鬣蜥',
    '红耳龟',
    '睫角守宫',
    '其他',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '发布动态',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 物种选择
          DropdownButtonFormField<String>(
            value: _selectedSpecies,
            decoration: const InputDecoration(
              labelText: '宠物种类（可选）',
              prefixIcon: Icon(Icons.pets),
            ),
            items: _species.map((s) {
              return DropdownMenuItem(value: s, child: Text(s));
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedSpecies = value);
            },
          ),
          const SizedBox(height: 16),

          // 内容输入
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '分享你的宠物日常...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 图片按钮
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.image),
                label: const Text('添加图片'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 发布按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入内容')),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('发布成功')),
                );
              },
              child: const Text('发布'),
            ),
          ),
        ],
      ),
    );
  }
}
