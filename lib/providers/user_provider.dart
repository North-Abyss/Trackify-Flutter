import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _name = "Trackify User";
  String _bio = "This is my bio";

  String get name => _name;
  String get bio => _bio;

  UserProvider() {
    _loadProfile();
  }
  
  // Load from hard drive on startup
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('userName') ?? "Trackify User";
    _bio = prefs.getString('userBio') ?? "On a mission to build amazing habits.";
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

}