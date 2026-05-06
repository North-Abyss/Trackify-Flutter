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

          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Mode'),
            subtitle: const Text('Follow system or force light/dark mode'),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              items: const [
                DropdownMenuItem(value: ThemeMode.system,child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light,child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark,child: Text('Dark')),
              ],  
              onChanged : (ThemeMode? newMode) {
                if (newMode != null) {
                  themeProvider.setThemeMode(newMode);
                }
              },
            ),
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
                  child: Row(
                    children: [
                      // The Visual Color Circle!
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: context.read<ThemeProvider>().getThemeColor(themeName), 
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(themeName),
                    ],
                  ),
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