//settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // WATCH the theme state
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;
    final activeThemeName = themeProvider.activeThemeName;
    final availableThemes = themeProvider.availableThemes;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children:[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Appearance', style: TextStyle(fontSize: 18)),
          ),

          const Divider(),

          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark themes'),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode, // The current position of the switch
            onChanged: (bool value) {
              // READ the provider and trigger the toggle function!
              context.read<ThemeProvider>().toggleDarkMode();
            },
          ),
          const Divider(), // Adds a clean line below the setting

          // The Theme Color Selector
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Accent Color'),
            subtitle: const Text('Choose your primary theme color'),
            trailing: DropdownButton<String>(
              value: activeThemeName,
              // Map our list of strings into DropdownMenuItems
              items: availableThemes.map((String themeName) {
                return DropdownMenuItem<String>(
                  value: themeName,
                  child: Text(themeName),
                );
              }).toList(),
              onChanged: (String? newThemeName) {
                if (newThemeName != null) {
                  // Trigger the theme change!
                  context.read<ThemeProvider>().setTheme(newThemeName);
                }
              },
            ),
          ),
          
          const Divider(),
        ]
      )
    );
  }
}