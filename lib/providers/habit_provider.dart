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
  // THE UNIVERSAL HEARTBEAT ENGINE
  // ==========================================
  
  void _startUniversalTicker() {
    // Only start if not already running
    if (_globalTimer != null && _globalTimer!.isActive) return;

    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool anyCoolingDown = false;
      bool changesMade = false;
      final now = DateTime.now();

      for (var habit in _habits) {
        if (habit.cooldownEndTime != null) {
          anyCoolingDown = true;
          
          // Did this specific habit finish its cooldown?
          if (now.isAfter(habit.cooldownEndTime!)) {
            habit.cooldownEndTime = null; // Clear the timer
            habit.completed = false; // UNCHECK it so they can do it again!
            changesMade = true;
          }
        }
      }

      // Always redraw UI if timers are running so the seconds tick down visually
      if (anyCoolingDown) {
        notifyListeners(); 
      } else {
        // If NO habits are cooling down, kill the heartbeat to save battery!
        timer.cancel();
      }

      if (changesMade) saveHabits();
    });
  }

  // Helper to get remaining seconds for a specific habit
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
        // Tapped while cooling down -> Cancel the timer early
        habit.cooldownEndTime = null;
        habit.completed = false;
      } else {
        // Drink Water -> Check it off -> Start cooldown
        habit.completed = true;
        habit.lastCompletedDate = DateTime.now();
        habit.currentStreak += 1;
        habit.cooldownEndTime = DateTime.now().add(Duration(seconds: habit.targetDurationSeconds));
        _startUniversalTicker(); // Ensure heartbeat is running
      }
    } else {
      // --- NORMAL HABIT ---
      habit.completed = !habit.completed;
      if (habit.completed) {
        habit.lastCompletedDate = DateTime.now();
        habit.currentStreak += 1; 
      }
    }
    
    saveHabits();
    notifyListeners();
  }

  // --- CONSOLIDATED ADD/EDIT METHOD ---
  void saveOrUpdateHabit({
    String? id, 
    required String name, 
    required int durationSeconds,
    // NEW REQUIRED PARAMETERS
    required String description,
    required String link, 
    required String tag, 
    required int colorValue,
  }) {
    if (id == null) {
      // CREATE NEW
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
      // UPDATE EXISTING
      final index = _habits.indexWhere((h) => h.id == id);
      if (index != -1) {
        _habits[index].name = name;
        _habits[index].description = description;
        _habits[index].link = link;
        _habits[index].tag = tag;
        _habits[index].colorValue = colorValue;
        
        // --- THE FROZEN TIMER FIX ---
        // If they change the duration, we MUST cancel the current cooldown and uncheck it
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
      
      // Boot Sequence: Catch up on ALL timers!
      final now = DateTime.now();
      bool changesMade = false;
      bool needHeartbeat = false;

      for (var habit in _habits) {
        if (habit.cooldownEndTime != null) {
          if (now.isAfter(habit.cooldownEndTime!)) {
            // Timer finished while app was closed!
            habit.cooldownEndTime = null;
            habit.completed = false; 
            changesMade = true;
          } else {
            // Still running!
            needHeartbeat = true;
          }
        }
      }

      if (changesMade) saveHabits();
      if (needHeartbeat) _startUniversalTicker();
      
      notifyListeners();
    }
  }

  // Put this right above your _checkDailyResets() method!
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
          habit.cooldownEndTime = null; // Clear any leftover timers from yesterday
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
}