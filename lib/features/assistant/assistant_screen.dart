import 'package:flutter/material.dart';
import '../../utils/ai_assistant.dart';
import '../../data/repositories/repositories.dart';
import '../../data/local/database_helper.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final AIAssistant _assistant = AIAssistant();
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAssistant();
  }

  Future<void> _initializeAssistant() async {
    // 加载数据并初始化知识库
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.initEncyclopediaData();
    await dbHelper.initArticleData();
    await dbHelper.initQAData();
    await dbHelper.initMedicalData();

    final species = await EncyclopediaRepository().getAllSpecies();
    final articles = await EncyclopediaRepository().getAllArticles();

    await _assistant.initialize(
      exhibitions: [],
      articles: articles,
      species: species,
      questions: [],
      diseases: [],
    );

    setState(() {
      _isLoading = false;
      _messages.add(ChatMessage(
        content: '您好！我是爬宠知识助手，可以帮您解答饲养问题。\n\n您可以问我：\n- 推荐适合新手的爬宠\n- 玉米蛇怎么饲养\n- 守宫常见疾病\n- 最近展览活动',
        isUser: false,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  content: '知识库已刷新，请问有什么可以帮助您的？',
                  isUser: false,
                ));
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 快捷问题
                _buildQuickQuestions(),
                // 消息列表
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(_messages[index]);
                    },
                  ),
                ),
                // 输入框
                _buildInput(),
              ],
            ),
    );
  }

  Widget _buildQuickQuestions() {
    final quickQuestions = [
      '推荐适合新手的爬宠',
      '玉米蛇怎么饲养',
      '豹纹守宫温度要求',
      '爬宠常见疾病',
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: quickQuestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(quickQuestions[index], style: const TextStyle(fontSize: 12)),
              onPressed: () => _sendMessage(quickQuestions[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smart_toy, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 4),
                  Text(
                    '知识助手',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '输入您的问题...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              onSubmitted: (value) => _sendMessage(value),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(content: text, isUser: true));
    });

    _controller.clear();

    // 显示加载状态
    setState(() {
      _messages.add(ChatMessage(content: '正在思考...', isUser: false, isLoading: true));
    });

    // 获取回答
    Future.delayed(const Duration(milliseconds: 500), () {
      final answer = _assistant.answer(text);

      setState(() {
        // 移除加载消息
        _messages.removeWhere((m) => m.isLoading);
        _messages.add(ChatMessage(content: answer, isUser: false));
      });
    });
  }
}

class ChatMessage {
  final String content;
  final bool isUser;
  final bool isLoading;

  ChatMessage({
    required this.content,
    required this.isUser,
    this.isLoading = false,
  });
}
