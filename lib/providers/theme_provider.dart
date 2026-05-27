// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // The clean, lightweight Material 3 seed palette!
  final Map<String, Color> _predefinedThemes = {
    "Dynamic": Colors.deepPurple, // The perfect default for M3
    "Ocean Blue": Colors.blue,
    "Forest Green": Colors.green,
    "Deep Purple": Colors.purple,
    "Sunset Orange": Colors.orange,
    "Cherry Red": Colors.red,
    "Teal": Colors.teal,
    "Pink": Colors.pink,
    "Amber": Colors.amber,
    "Indigo": Colors.indigo,
    "Slate": Colors.blueGrey,
    "Cyan": Colors.cyan,
    "Earth": Colors.brown,
  };

  ThemeProvider() {
    _loadPreferences(); 
  }

  String _activeThemeName = "Dynamic"; 

  String get activeThemeName => _activeThemeName;
  List<String> get availableThemes => _predefinedThemes.keys.toList();
  Color getThemeColor(String name) => _predefinedThemes[name] ?? Colors.deepPurple;

  // Light Theme Generator
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: getThemeColor(_activeThemeName),
        brightness: Brightness.light,
      ),
    );
  }

  // Dark Theme Generator
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: getThemeColor(_activeThemeName),
        brightness: Brightness.dark,
      ),
    );
  }

  // Load from Hard Drive
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _activeThemeName = prefs.getString('themeName') ?? "Dynamic"; 
    notifyListeners(); 
  }

  // Set Theme Mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index); 
    notifyListeners();
  }

  // Set Color Palette
  Future<void> setTheme(String themeName) async {
    if (_predefinedThemes.containsKey(themeName)) {
      _activeThemeName = themeName;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeName', _activeThemeName); 
      notifyListeners();
    }
  }
  
}
