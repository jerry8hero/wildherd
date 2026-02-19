import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const Locale _defaultLocale = Locale('zh');

  Locale _locale = _defaultLocale;

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  static const List<Locale> supportedLocales = [
    Locale('zh'),
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('es'),
  ];

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'zh':
        return '简体中文';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'es':
        return 'Español';
      default:
        return code;
    }
  }
}
