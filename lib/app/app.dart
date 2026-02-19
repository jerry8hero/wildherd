import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme.dart';
import 'locale_provider.dart';
import '../features/home/home_screen.dart';
import '../features/encyclopedia/encyclopedia_screen.dart';
import '../features/community/community_screen.dart';
import '../features/market/market_screen.dart';
import '../features/companion/companion_screen.dart';
import '../features/settings/level_select_screen.dart';
import '../features/habitat/habitat_screen.dart';
import '../features/exhibition/exhibition_screen.dart';
import '../l10n/generated/app_localizations.dart';

class ReptileCareApp extends StatelessWidget {
  const ReptileCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'WildHerd',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          supportedLocales: LocaleProvider.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HomeScreen(), // TODO: 添加 PetsScreen
    const EncyclopediaScreen(),
    const MarketScreen(),
    const HabitatScreen(), // 饲养环境
    const ExhibitionScreen(), // 展览资讯
    const CompanionScreen(),
    const CommunityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pets_outlined),
            activeIcon: const Icon(Icons.pets),
            label: l10n.pets,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: l10n.encyclopedia,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up_outlined),
            activeIcon: const Icon(Icons.trending_up),
            label: l10n.market,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.eco_outlined),
            activeIcon: const Icon(Icons.eco),
            label: l10n.habitat,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.event_outlined),
            activeIcon: const Icon(Icons.event),
            label: l10n.information,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            activeIcon: const Icon(Icons.favorite),
            label: l10n.companion,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline),
            activeIcon: const Icon(Icons.people),
            label: l10n.community,
          ),
        ],
      ),
    );
  }
}
