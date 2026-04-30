//dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:convert'; // For JSON encoding/decoding
//import '../models/habit.dart';
import '../widgets/habit_card.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../providers/habit_provider.dart'; // Import your new manager
import 'habit_detail_screen.dart';
import 'package:flutter/services.dart'; // REQUIRED for keyboard keys!

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

const uuid = Uuid();
class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _habitController = TextEditingController();

  // Put this inside your _DashboardScreenState class
  void _openNewHabitDialog() {
    _habitController.clear();
    showDialog(
      context: context,
      builder: (context) {
            return AlertDialog(
              
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),                
              title: const Text('Create New Habit'),
              content: TextField(
                controller: _habitController,
                autofocus: true, // Boom! Cursor appears instantly without tapping.
                decoration: const InputDecoration(
                  hintText: 'e.g., Code in Flutter', border: OutlineInputBorder(),
                ),

                // THE KEYBOARD SHORTCUT (Pressing Enter)
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    // Trigger the Provider and close the HUD!
                    context.read<HabitProvider>().addHabit(value);
                    Navigator.pop(context); 
                  }
                },
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Cancel
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_habitController.text.isNotEmpty) {
                      context.read<HabitProvider>().addHabit(_habitController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
              
            );
          }
        );
  }


  @override
  Widget build(BuildContext context) {
    // WATCH THE STATE: This tells the UI to rebuild anytime notifyListeners() is called!
    final habitProvider = context.watch<HabitProvider>();
    final myHabits = habitProvider.habits; // Grab the list from the provider

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyN): NewHabitIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): NewHabitIntent(), // For Mac
      },
      child: Actions(
        // 2. THE TRIGGER: What happens when NewHabitIntent fires?
        actions: <Type, Action<Intent>>{
          NewHabitIntent: CallbackAction<NewHabitIntent>(
            onInvoke: (NewHabitIntent intent) {
              _openNewHabitDialog(); // Call our helper function!
              return null;
            },
          ),
        },

        child: Focus(
          autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(title: const Text('Trackify Dashboard')),
          
          body: ListView.builder(
            itemCount: myHabits.length,
            itemBuilder: (context, index) {
              final habit = myHabits[index];
              
              return Dismissible(
                key: Key(habit.id), 

                direction: DismissDirection.startToEnd, 
                dismissThresholds: const { DismissDirection.startToEnd: 0.5 },
                
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                
                // The logic to execute when swiped off screen
                onDismissed: (direction) {
                  context.read<HabitProvider>().deleteHabit(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${habit.name} deleted')),
                  );
                },
                
                child: GestureDetector(
                  onTap: () { context.read<HabitProvider>().toggleHabit(index); },

                  onLongPress: () async {
                    
                    final String? updatedName = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HabitDetailScreen(habit: habit),
                      ),
                    );
                    // 1. If the widget was destroyed while we were waiting, stop executing!
                    if (!context.mounted) return;
                    // 2. Now it is 100% safe to use the context.
                    if (updatedName != null && updatedName.isNotEmpty) {
                      context.read<HabitProvider>().editHabitName(index, updatedName);                
                    }
                  },

                  child: HabitCard( title: habit.name, isCompleted: habit.completed, ),
                ),
              );
            },
          ),

          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.add),
            onPressed: () {
              _habitController.clear();
              _openNewHabitDialog();
            },
          ),
      
        )
        ),
      ),      
    );
  }
}

// shortcut keys
class NewHabitIntent extends Intent {
  
}