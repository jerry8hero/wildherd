import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../app/locale_provider.dart';
import '../../data/models/user.dart';
import '../../data/local/user_preferences.dart';
import '../../l10n/generated/app_localizations.dart';
import 'schedule_settings_screen.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.success),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = ref.read(localeProvider.notifier);
    final currentLocale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocaleNotifier.supportedLocales.map((locale) {
            final isSelected = currentLocale.languageCode == locale.languageCode;
            return ListTile(
              title: Text(localeNotifier.getLanguageName(locale.languageCode)),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                localeNotifier.setLocale(locale);
                Navigator.pop(dialogContext);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageDialog,
            tooltip: l10n.language,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selector card
            Card(
              child: ListTile(
                leading: const Icon(Icons.language, color: AppTheme.primaryColor),
                title: Text(l10n.language),
                subtitle: Text(localeNotifier.getLanguageName(currentLocale.languageCode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showLanguageDialog,
              ),
            ),
            const SizedBox(height: 16),
            // 定时更新设置
            Card(
              child: ListTile(
                leading: const Icon(Icons.timer, color: AppTheme.primaryColor),
                title: const Text('定时更新'),
                subtitle: const Text('自动更新展览资讯和文章'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScheduleSettingsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.selectLevel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.beginnerDesc,
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
                  color: color.withValues(alpha: 0.1),
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
                            color: color.withValues(alpha: 0.1),
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
