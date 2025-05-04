import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'market.dart';
import 'crops.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/weather_widget.dart';
import 'widgets/advisory_widget.dart';
import 'widgets/news_widget.dart';
import '../models/weather_data.dart';

class HomePage extends StatefulWidget {
  final Function(Locale) onLocaleChanged;
  final bool isDarkMode;
  final Function() onThemeChanged;
  final String selectedLanguage;
  final Function(String) onLanguageChanged;
  
  const HomePage({
    super.key,
    required this.onLocaleChanged,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  WeatherData? _weatherData;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateWeatherData(WeatherData weatherData) {
    setState(() {
      _weatherData = weatherData;
    });
  }

  String _getTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_selectedIndex) {
      case 0:
        return l10n.appTitle;
      case 1:
        return l10n.market;
      case 2:
        return l10n.crops;
      case 3:
        return l10n.schemeAI;
      default:
        return l10n.appTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getTitle(context),
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
        onLocaleChanged: widget.onLocaleChanged,
        selectedLanguage: widget.selectedLanguage,
        onLanguageChanged: widget.onLanguageChanged,
      ),
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: AppLocalizations.of(context)!.market,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.eco),
            label: AppLocalizations.of(context)!.crops,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome),
            label: AppLocalizations.of(context)!.schemeAI,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weather Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              WeatherWidget(onWeatherUpdate: _updateWeatherData),
              const SizedBox(height: 24),
              const Text(
                'Farming Advisories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              AdvisoryWidget(weatherData: _weatherData),
              const SizedBox(height: 24),
              const NewsWidget(),
            ],
          ),
        );
      case 1:
        return const MarketPage();
      case 2:
        return const CropPage();
      case 3:
        return const Center(child: Text('Scheme AI Page Content'));
      default:
        return const Center(child: Text('Home Page Content'));
    }
  }
}