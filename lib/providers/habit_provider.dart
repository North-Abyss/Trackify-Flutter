// lib/providers/habit_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async'; // REQUIRED FOR TIMERS!
import '../models/habit.dart';
import 'package:uuid/uuid.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = []; final Uuid _uuid = const Uuid();

  List<Habit> get habits => _habits;  // Getter so the UI can read the habits
  HabitProvider() { loadHabits(); } // Load automatically when the app starts!

  // The Global Heartbeat Timer
  Timer? _globalTicker;

  // Add this inside editHabitDuration so changing the duration resets the remaining time:
  // _habits[index].targetDurationSeconds = newDuration;
  // _habits[index].remainingSeconds = newDuration; <--- ADD THIS TO YOUR EDIT METHOD!
  
  // CREATE
  void addHabit(String name) {
    _habits.add(Habit(id: _uuid.v4(), name: name));
    saveHabits(); notifyListeners(); // <--- Tells the UI to update!
  }

  void _startGlobalTicker() {
    // If the timer is already ticking, don't start a second one!
    if (_globalTicker != null && _globalTicker!.isActive) return;

    _globalTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool anyRunning = false;
      bool changesMade = false;

      for (var habit in _habits) {
        if (habit.completed && habit.targetDurationSeconds > 0) {
          anyRunning = true;
          changesMade = true;

          if (habit.remainingSeconds > 0) {
            habit.remainingSeconds--; // Tick down!
          } else {
            // TIMER HIT ZERO!
            habit.completed = false; // "turn off or incompleted state"
            habit.targetDurationSeconds = 0; // "returns to no timer"
            habit.remainingSeconds = 0;
          }
        }
      }

      if (changesMade) notifyListeners();

      // If no habits are currently playing, cancel the timer to save battery!
      if (!anyRunning) {
        timer.cancel();
        saveHabits(); // Save progress to hard drive when timer stops
      }
    });
  }

  // UPDATE (Toggle)
  void toggleHabit(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    var habit = _habits[index];

    // If it's a timer habit, tapping it toggles the timer instead of instant completion
    if (habit.targetDurationSeconds > 0) {
      // Only one timer running at a time
      for (var h in _habits) {
        if (h.targetDurationSeconds > 0 && h.id != habit.id) {
          h.completed = false;
        }
      }

      habit.completed = !habit.completed;

      if (habit.completed) {
        _startGlobalTicker();
      } else {
        saveHabits();
      }
    } else {
      // Normal habit instant completion
      habit.completed = !habit.completed;
      if (habit.completed) {
        habit.lastCompletedDate = DateTime.now();
        habit.currentStreak += 1; 
      }
      saveHabits();
    }
    notifyListeners();
  }

  // UPDATE (Edit Name)
  void editHabitName(String id, String newName) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index].name = newName;
      saveHabits(); notifyListeners();
    }
  }

  // UPDATE (Edit Duration)
  void editHabitDuration(String id, int newDurationSeconds) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index].targetDurationSeconds = newDurationSeconds;
      _habits[index].remainingSeconds = newDurationSeconds; // Reset remaining time on edit
      
      if (newDurationSeconds > 0) {
        // Only one timer running at a time
        for (var h in _habits) {
          if (h.targetDurationSeconds > 0 && h.id != id) {
            h.completed = false;
          }
        }
        
        _habits[index].completed = true;
        _startGlobalTicker();
      }
      
      saveHabits(); notifyListeners();
    }
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
      _checkDailyResets();
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Strip hours/minutes

    for (var habit in _habits) {
      if (habit.lastCompletedDate != null) {
        // Strip hours/minutes from the last completed date too
        final lastCompletedDay = DateTime(
          habit.lastCompletedDate!.year,
          habit.lastCompletedDate!.month,
          habit.lastCompletedDate!.day,
        );

        // Calculate how many days have passed
        final difference = today.difference(lastCompletedDay).inDays;

        if (difference >= 1 && habit.completed) {
          // A new day has started! Uncheck the habit.
          habit.completed = false;
          changesMade = true;
        }

        if (difference >= 2 && habit.currentStreak > 0) {
          // They missed a full day. Break the streak!
          habit.currentStreak = 0;
          changesMade = true;
        }
      }
    }

    if (changesMade) {
      saveHabits(); // Save the reset state to the hard drive
      notifyListeners();
    }
  }

}

