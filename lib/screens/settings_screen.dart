// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/theme_provider.dart';
import '../providers/habit_provider.dart'; 
import '../services/backup_service.dart';
import '../services/update_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    //final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children:[
          // --- APPEARANCE SECTION ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
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
                if (newMode != null) themeProvider.setThemeMode(newMode);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Accent Color'),
            subtitle: const Text('Choose your primary theme color'),
            trailing: DropdownButton<String>(
              value: themeProvider.activeThemeName,
              items: themeProvider.availableThemes.map((String themeName) {
                return DropdownMenuItem<String>(
                  value: themeName,
                  child: Row(
                    children: [
                      Container(
                        width: 16, height: 16,
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
                if (newThemeName != null) context.read<ThemeProvider>().setTheme(newThemeName);
              },
            ),
          ),
          const Divider(thickness: 2),

          // --- DATA & STORAGE SECTION (.trackify Backup) ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Data & Storage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Backup (.trackify)'),
            subtitle: const Text('Restore all habits and settings'),
            onTap: () async {
              bool success = await BackupService.importData();
              if (success && context.mounted) {
                // Tell the HabitProvider to reload its data from the freshly overwritten SharedPreferences
                context.read<HabitProvider>().loadHabits();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup Restored!'), backgroundColor: Colors.green),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Export Backup (.trackify)'),
            subtitle: const Text('Save a complete snapshot of your app'),
            onTap: () async {
              bool success = await BackupService.exportData();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup Saved!'), backgroundColor: Colors.green),
                );
              }
            },
          ),
          const Divider(thickness: 2),

          // --- SYSTEM & ABOUT SECTION ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('System & About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('View Source Code'),
            subtitle: const Text('github.com/North-Abyss/Trackify-Flutter'),
            onTap: () {
              launchUrl(Uri.parse('https://github.com/North-Abyss/Trackify-Flutter'), mode: LaunchMode.externalApplication);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text('Check for Updates'),
            subtitle: const Text('Ping GitHub for the latest release'),
            onTap: () {
              UpdateService.checkForUpdates(context);
            },
          ),
          const Divider(),
          
          // --- THE DANGER ZONE ---
          const SizedBox(height: 20),
          Center( // <-- This is the magic widget that stops it from stretching!
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                // horizontal padding adds breathing room on the left/right of the text
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.delete, size: 20),
              label: const Text(
                'RESET ALL DATA', 
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)
              ),
              onPressed: () => _requestMemoryReset(context),
            ),
          ),
          const SizedBox(height: 40),     

        ]
      )
    );
  }

  // --- DOUBLE CONFIRMATION RESET LOGIC ---
  void _requestMemoryReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset Memory?", style: TextStyle(color: Colors.red)),
        content: const Text("This will delete all your habits, stats, and history. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            child: const Text("Yes, Proceed", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(ctx); 
              _requestFinalConfirmation(context); 
            },
          ),
        ],
      ),
    );
  }

  void _requestFinalConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("FINAL WARNING", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This action cannot be undone. All data will be permanently erased."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // 1. Nuke SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              // 2. Clear Provider Memory & Rebuild UI
              if (context.mounted) {
                context.read<HabitProvider>().clearAllData();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Memory Wiped.'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("CONFIRM RESET", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}