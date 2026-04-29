// lib/providers/habit_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/habit.dart';
import 'package:uuid/uuid.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = []; final Uuid _uuid = const Uuid();

  List<Habit> get habits => _habits;  // Getter so the UI can read the habits
  HabitProvider() { loadHabits(); } // Load automatically when the app starts!

  // CREATE
  void addHabit(String name) {
    _habits.add(Habit(id: _uuid.v4(), name: name));
    saveHabits(); notifyListeners(); // <--- Tells the UI to update!
  }

  // UPDATE (Toggle)
  void toggleHabit(int index) {
    _habits[index].completed = !_habits[index].completed;
    saveHabits(); notifyListeners();
  }

  // UPDATE (Edit Name)
  void editHabitName(int index, String newName) {
    _habits[index].name = newName;
    saveHabits(); notifyListeners();
  }

  // DELETE
  void deleteHabit(int index) {
    _habits.removeAt(index);
    saveHabits(); notifyListeners();
  }

  // --- STORAGE LOGIC ---
  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsString = prefs.getString('saved_habits');
    if (habitsString != null) {
      final List<dynamic> decoded = jsonDecode(habitsString);
      _habits = decoded.map((item) => Habit.fromjson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_habits.map((h) => h.toMap()).toList());
    await prefs.setString('saved_habits', encoded);
  }
}