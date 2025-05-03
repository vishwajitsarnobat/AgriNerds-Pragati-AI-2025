import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isDarkMode;
  final Function() onThemeChanged;
  final Function(Locale) onLocaleChanged;
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  static const List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Marathi', 'code': 'mr'},
    {'name': 'Hindi', 'code': 'hi'},
    {'name': 'Telugu', 'code': 'te'},
    {'name': 'Malayalam', 'code': 'ml'},
    {'name': 'Tamil', 'code': 'ta'},
  ];

  void _changeLanguage(String? newLanguage) {
    if (newLanguage != null) {
      onLanguageChanged(newLanguage);
      final languageCode = _languages.firstWhere(
        (lang) => lang['name'] == newLanguage,
        orElse: () => {'code': 'en'},
      )['code'];
      onLocaleChanged(Locale(languageCode!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: onThemeChanged,
          tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.language_outlined,
            color: theme.colorScheme.onSurface,
          ),
          onSelected: _changeLanguage,
          tooltip: 'Change Language',
          itemBuilder: (BuildContext context) {
            return _languages.map((Map<String, String> language) {
              final isSelected = selectedLanguage == language['name'];
              return PopupMenuItem<String>(
                value: language['name']!,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      language['name']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              );
            }).toList();
          },
        ),
        const SizedBox(width: 8),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
} 