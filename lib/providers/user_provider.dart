import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _name = "Trackify User";
  String _bio = "This is my bio";
  int _exp = 0;

  String get name => _name;
  String get bio => _bio;
  int get exp => _exp;

  // THE MATH: Every 100 EXP is 1 Level. (e.g., 250 EXP = Level 3)
  int get level => (_exp ~/ 100) + 1; 
  
  // How much EXP is needed to hit the next level? (e.g., 250 EXP -> needs 50 more)
  int get expToNextLevel => 100 - (_exp % 100); 
  
  // Get progress as a percentage (0.0 to 1.0) for our future UI Progress Bar!
  double get currentLevelProgress => (_exp % 100) / 100.0;

  UserProvider() {
    _loadProfile();
  }
  
  // Load from hard drive on startup
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('userName') ?? "Trackify User";
    _bio = prefs.getString('userBio') ?? "On a mission to build amazing habits.";
    _exp = prefs.getInt('userExp') ?? 0; // Load EXP
    notifyListeners();
  }

  // Save new details to hard drive
  Future<void> updateProfile(String newName, String newBio) async {
    _name = newName;
    _bio = newBio;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _name);
    await prefs.setString('userBio', _bio);
    notifyListeners();
  }

  // NEW: Add EXP and save to hard drive
  Future<void> addExp(int amount) async {
    _exp += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userExp', _exp);
    notifyListeners();
  }

}