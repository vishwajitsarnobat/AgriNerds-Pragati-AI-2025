import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  Locale? _locale;
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';

  Locale? get locale => _locale;
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;

  void changeLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void updateLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }
} 