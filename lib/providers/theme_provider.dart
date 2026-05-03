//theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = ThemeData.dark();

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    if (_currentTheme == ThemeData.light()) {
      _currentTheme = ThemeData.dark();
    } else {
      _currentTheme = ThemeData.light();
    }
    
    // Tell the whole app to redraw with the new colors!
    notifyListeners(); 
  }
}
