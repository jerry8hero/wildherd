import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../data/models/user.dart';
import '../../data/local/user_preferences.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late UserLevel _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = UserPreferences.getUserLevel();
  }

  Future<void> _saveLevel(UserLevel level) async {
    await UserPreferences.setUserLevel(level);
    setState(() {
      _selectedLevel = level;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已设置为${level.displayName}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择经验等级'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请选择您的饲养经验等级',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '根据您的选择，我们将为您推荐适合的宠物',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildLevelCard(UserLevel.beginner),
            const SizedBox(height: 16),
            _buildLevelCard(UserLevel.intermediate),
            const SizedBox(height: 16),
            _buildLevelCard(UserLevel.advanced),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(UserLevel level) {
    final isSelected = _selectedLevel == level;
    final color = _getLevelColor(level);

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _saveLevel(level),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getLevelIcon(level),
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          level.displayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            level.difficultyLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '适合难度: ${level.difficultyRange.join('-')}级',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(UserLevel level) {
    switch (level) {
      case UserLevel.beginner:
        return Colors.green;
      case UserLevel.intermediate:
        return Colors.orange;
      case UserLevel.advanced:
        return Colors.red;
    }
  }

  IconData _getLevelIcon(UserLevel level) {
    switch (level) {
      case UserLevel.beginner:
        return Icons.school;
      case UserLevel.intermediate:
        return Icons.trending_up;
      case UserLevel.advanced:
        return Icons.emoji_events;
    }
  }
}
