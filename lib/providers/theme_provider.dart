//theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; //Import SharedPreferences

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  // 1. Our 10 Predefined Themes!
  final Map<String, Color> _predefinedThemes = {
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
  }

  String _activeThemeName = "Ocean Blue"; // Default theme

  // Getters for the UI
  bool get isDarkMode => _isDarkMode;
  String get activeThemeName => _activeThemeName;
  List<String> get availableThemes => _predefinedThemes.keys.toList();
  
  // The Magic: Generating the ThemeData dynamically!
  ThemeData get currentTheme {
    Color seedColor = _predefinedThemes[_activeThemeName]!; // Get the selected color

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }

  // Load from Hard Drive
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _activeThemeName = prefs.getString('themeName') ?? "Ocean Blue";
    notifyListeners(); // Tell the UI we finished loading the saved theme
  }

  // Save to Hard Drive when toggling Dark Mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode); // Save it!
    notifyListeners();
  }

  // Save to Hard Drive when changing Color
  Future<void> setTheme(String themeName) async {
    if (_predefinedThemes.containsKey(themeName)) {
      _activeThemeName = themeName;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeName', _activeThemeName); // Save it!
      notifyListeners();
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
