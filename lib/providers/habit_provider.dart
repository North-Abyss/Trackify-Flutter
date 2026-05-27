// lib/providers/habit_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async'; 
import '../models/habit.dart';
import 'package:uuid/uuid.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = []; 
  final Uuid _uuid = const Uuid();
  Timer? _globalTimer;

  List<Habit> get habits => _habits;  
  HabitProvider() { loadHabits(); } 

  // ==========================================
  // 🚀 CALENDAR HISTORY HELPERS
  // ==========================================
  
  // Strips the time (hours/mins) so the calendar can match days perfectly
  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Saves or removes the exact day the habit was completed
  void _recordCompletion(Habit habit, bool isComplete) {
    final cleanDate = _stripTime(DateTime.now());
    if (isComplete) {
      if (!habit.completedDates.any((d) => d.isAtSameMomentAs(cleanDate))) {
        habit.completedDates.add(cleanDate);
      }
    } else {
      habit.completedDates.removeWhere((d) => d.isAtSameMomentAs(cleanDate));
    }
  }

  // ==========================================
  // THE UNIVERSAL HEARTBEAT ENGINE
  // ==========================================
  
  void _startUniversalTicker() {
    if (_globalTimer != null && _globalTimer!.isActive) return;

    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool anyCoolingDown = false;
      bool changesMade = false;
      final now = DateTime.now();

      for (var habit in _habits) {
        if (habit.cooldownEndTime != null) {
          anyCoolingDown = true;
          
          if (now.isAfter(habit.cooldownEndTime!)) {
            habit.cooldownEndTime = null; 
            habit.completed = false; 
            changesMade = true;
          }
        }
      }

      if (anyCoolingDown) {
        notifyListeners(); 
      } else {
        timer.cancel();
      }

      if (changesMade) saveHabits();
    });
  }

  int getRemainingSeconds(Habit habit) {
    if (habit.cooldownEndTime == null) return 0;
    final remaining = habit.cooldownEndTime!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  // ==========================================
  // HABIT CRUD
  // ==========================================
  
  void toggleHabit(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    var habit = _habits[index];

    if (habit.targetDurationSeconds > 0) {
      // --- COOLDOWN HABIT ---
      if (habit.cooldownEndTime != null) {
        habit.cooldownEndTime = null;
        habit.completed = false;
        _recordCompletion(habit, false); // 🚀 REMOVE FROM HISTORY (CANCELLED)
      } else {
        habit.completed = true;
        habit.lastCompletedDate = DateTime.now();
        habit.currentStreak += 1;
        _recordCompletion(habit, true); // 🚀 ADD TO HISTORY
        habit.cooldownEndTime = DateTime.now().add(Duration(seconds: habit.targetDurationSeconds));
        _startUniversalTicker(); 
      }
    } else {
      // --- NORMAL HABIT ---
      habit.completed = !habit.completed;
      _recordCompletion(habit, habit.completed); // 🚀 ADD/REMOVE HISTORY
      
      if (habit.completed) {
        habit.lastCompletedDate = DateTime.now();
        habit.currentStreak += 1; 
      }
    }
    
    saveHabits();
    notifyListeners();
  }

  void saveOrUpdateHabit({
    String? id, 
    required String name, 
    required int durationSeconds,
    required String description,
    required String link, 
    required String tag, 
    required int colorValue,
  }) {
    if (id == null) {
      _habits.add(Habit(
        id: _uuid.v4(), 
        name: name, 
        targetDurationSeconds: durationSeconds,
        description: description,
        link: link,
        tag: tag,
        colorValue: colorValue,
      ));
    } else {
      final index = _habits.indexWhere((h) => h.id == id);
      if (index != -1) {
        _habits[index].name = name;
        _habits[index].description = description;
        _habits[index].link = link;
        _habits[index].tag = tag;
        _habits[index].colorValue = colorValue;
        
        if (durationSeconds != _habits[index].targetDurationSeconds) {
           _habits[index].targetDurationSeconds = durationSeconds;
           _habits[index].cooldownEndTime = null;
           _habits[index].completed = false; 
        }
      }
    }
    saveHabits();
    notifyListeners();
  }

  void deleteHabit(int index) {
    _habits.removeAt(index);
    saveHabits(); notifyListeners();
  }

  // ==========================================
  // STORAGE & BOOT LOGIC
  // ==========================================

  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsString = prefs.getString('saved_habits');
    
    if (habitsString != null) {
      final List<dynamic> decoded = jsonDecode(habitsString);
      _habits = decoded.map((item) => Habit.fromjson(item)).toList();
      
      _checkDailyResets();
      
      final now = DateTime.now();
      bool changesMade = false;
      bool needHeartbeat = false;

      for (var habit in _habits) {
        if (habit.cooldownEndTime != null) {
          if (now.isAfter(habit.cooldownEndTime!)) {
            habit.cooldownEndTime = null;
            habit.completed = false; 
            changesMade = true;
          } else {
            needHeartbeat = true;
          }
        }
      }

      if (changesMade) saveHabits();
      if (needHeartbeat) _startUniversalTicker();
      
      notifyListeners();
    }
  }

  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_habits.map((h) => h.toMap()).toList());
    await prefs.setString('saved_habits', encoded);
  }

  void _checkDailyResets() {
    bool changesMade = false;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day); 

    for (var habit in _habits) {
      if (habit.lastCompletedDate != null) {
        final lastDay = DateTime(habit.lastCompletedDate!.year, habit.lastCompletedDate!.month, habit.lastCompletedDate!.day);
        final diff = today.difference(lastDay).inDays;

        if (diff >= 1 && habit.completed) {
          habit.completed = false; 
          habit.cooldownEndTime = null; 
          changesMade = true;
        }
        if (diff >= 2 && habit.currentStreak > 0) {
          habit.currentStreak = 0; 
          changesMade = true;
        }
      }
    }
    if (changesMade) saveHabits(); 
  }

  // For Clearing All Data (e.g., during testing or if user wants a fresh start):
  void clearAllData() {
    _habits.clear();
    notifyListeners();
  }

  // ==========================================
  // EXPORT / IMPORT LOGIC
  // ==========================================

  String exportToJson() {
    return jsonEncode(_habits.map((h) => h.toMap()).toList());
  }

  void importFromJson(String jsonString) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      _habits = decoded.map((item) => Habit.fromjson(item)).toList();
      saveHabits(); 
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to import JSON: $e");
    }
  }
}