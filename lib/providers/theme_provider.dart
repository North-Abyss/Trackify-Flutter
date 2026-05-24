// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'dart:convert';
import 'package:flutter/services.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // 1. Added "Dynamic" at the top! 
  // We assign it a default fallback color (like deep purple/indigo) in case 
  // the device doesn't support Material You (e.g., Web or iOS).
  final Map<String, Color> _predefinedThemes = {
    "Dynamic": Colors.cyanAccent, 
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
  };

  ThemeProvider() {
    _loadPreferences(); 
    loadCustomTheme(); 
  }

  // Changed the default fallback to Dynamic
  String _activeThemeName = "Dynamic"; 

  // Getters for the UI
  String get activeThemeName => _activeThemeName;
  List<String> get availableThemes => _predefinedThemes.keys.toList();
  
  Color getThemeColor(String name) => _predefinedThemes[name]!;

  // Generate the Light version of the active color  
  ThemeData get lightTheme {
    Color seedColor = _predefinedThemes[_activeThemeName] ?? _predefinedThemes['Ocean Blue']!;
    
    // If the active theme is Custom, and we have JSON data, use it!
    Color? customBackground;
    Color? customSurface;
    Color? customText;

    if (_activeThemeName == 'Custom (JSON)' && _customThemeData != null) {
        customBackground = _customThemeData!['background'] != null ? hexToColor(_customThemeData!['background']) : null;
        customSurface = _customThemeData!['card'] != null ? hexToColor(_customThemeData!['card']) : null;
        customText = _customThemeData!['text'] != null ? hexToColor(_customThemeData!['text']) : null;
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        // Override the defaults with our JSON colors if they exist
        surface: customBackground,
        surfaceContainerHighest: customSurface,
        onSurface: customText,
        onSurfaceVariant: customText,
      ),
    );
  }

  // Generate the Dark version of the active color
  ThemeData get darkTheme {
    Color seedColor = _predefinedThemes[_activeThemeName] ?? _predefinedThemes['Ocean Blue']!; 
    
    // If the active theme is Custom, and we have JSON data, use it!
    Color? customBackground;
    Color? customSurface;
    Color? customText;

    if (_activeThemeName == 'Custom (JSON)' && _customThemeData != null) {
        customBackground = _customThemeData!['background'] != null ? hexToColor(_customThemeData!['background']) : null;
        customSurface = _customThemeData!['card'] != null ? hexToColor(_customThemeData!['card']) : null;
        customText = _customThemeData!['text'] != null ? hexToColor(_customThemeData!['text']) : null;
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        // Override the defaults with our JSON colors if they exist
        surface: customBackground,
        surfaceContainerHighest: customSurface, 
        onSurface: customText,
        onSurfaceVariant: customText,       
      ),
    );
  }

  // Load from Hard Drive
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _activeThemeName = prefs.getString('themeName') ?? "Dynamic"; // Default to dynamic
    notifyListeners(); 
  }

  // Update the toggle method to use ThemeMode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index); 
    notifyListeners();
  }

  // Save to Hard Drive when changing Color
  Future<void> setTheme(String themeName) async {
    // Also allow Custom (JSON) to be saved
    if (_predefinedThemes.containsKey(themeName) || themeName == 'Custom (JSON)') {
      _activeThemeName = themeName;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeName', _activeThemeName); 
      notifyListeners();
    }
  }

  Map<String, dynamic>? _customThemeData;

  // Fetch and parse the JSON file
  Future<void> loadCustomTheme() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/custom_theme.json');
      _customThemeData = jsonDecode(jsonString);
      
      if (_customThemeData != null && _customThemeData!['primary'] != null) {
        _predefinedThemes['Custom (JSON)'] = hexToColor(_customThemeData!['primary']);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading custom theme: $e");
    }
  }
}

// Helper to convert CSS hex strings ("#0D47A1") into Flutter Colors!
Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) {
    buffer.write('ff'); // Set opacity to 100%
  }
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}