import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = Locale('de');
  static const String _languageCodeKey = 'language_code';

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(_languageCodeKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      _locale = Locale('de');
    }
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }

  Future<void> setDefaultLanguage() async {
    final deviceLocale = WidgetsBinding.instance.window.locale;
    _locale = Locale(deviceLocale.languageCode);
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, deviceLocale.languageCode);
  }
}
