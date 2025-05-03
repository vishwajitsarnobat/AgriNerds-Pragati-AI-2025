import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _updateLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriNerds',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('mr'), // Marathi
        Locale('hi'), // Hindi
        Locale('te'), // Telugu
        Locale('ml'), // Malayalam
        Locale('ta'), // Tamil
      ],
      home: HomePage(
        onLocaleChanged: _changeLocale,
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
        selectedLanguage: _selectedLanguage,
        onLanguageChanged: _updateLanguage,
      ),
    );
  }
}