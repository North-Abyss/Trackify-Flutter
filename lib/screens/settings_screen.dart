// lib/screens/settings_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart'; // The new native file explorer package
import 'dart:convert'; // Needed for utf8 encoding on web exports
import 'dart:io'; // Needed to read/write the actual file to the hard drive
//import 'dart:typed_data'; // unnecessary import for web export, foundation.dart already includes it
import '../providers/theme_provider.dart';
import '../providers/habit_provider.dart'; // Needed to call import/export

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // WATCH the theme state
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeThemeName = themeProvider.activeThemeName;
    final availableThemes = themeProvider.availableThemes;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children:[
          // --- APPEARANCE SECTION ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              value: activeThemeName,
              items: availableThemes.map((String themeName) {
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
          
          const Divider(), // A thicker divider between major sections

          // --- DATA MANAGEMENT SECTION ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Data & Storage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(),

          // 1. IMPORT BUTTON
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Import Template / Backup'),
            subtitle: const Text('Load habits from a .json file'),
            onTap: () async {
              // Open native file picker
              FilePickerResult? result = await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['json'], // Only allow json files!
              );

              if (result != null && result.files.single.path != null) {
                // Read the file and send it to the Provider
                File file = File(result.files.single.path!);
                String jsonString = await file.readAsString();
                
                if (context.mounted) {
                  context.read<HabitProvider>().importFromJson(jsonString);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Habits imported successfully!',
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),

          const Divider(),

          // 2. EXPORT BUTTON
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Export Backup'),
            subtitle: const Text('Save your current habits to a file'),
            onTap: () async {
              // 1. Grab the JSON data from the Provider first
              final jsonString = context.read<HabitProvider>().exportToJson();

              if (kIsWeb) {
                // --- WEB EXPORT ---
                // Convert the string to bytes so Chrome can trigger a download
                final bytes = Uint8List.fromList(utf8.encode(jsonString));
                
                await FilePicker.saveFile(
                  fileName: 'trackify_backup.json',
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                  bytes: bytes, // <-- THE MAGIC FIX FOR WEB!
                );

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Backup downloaded!',
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                // --- LINUX / ANDROID EXPORT ---
                String? outputFile = await FilePicker.saveFile(
                  dialogTitle: 'Select where to save your backup:',
                  fileName: 'trackify_backup.json',
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );

                if (outputFile != null) {
                  final file = File(outputFile);
                  await file.writeAsString(jsonString);
                  
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Backup saved successfully!',
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),


          const Divider(),
        ]
      )
    );
  }
}