//dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding
import '../models/habit.dart';
import '../widgets/habit_card.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../providers/habit_provider.dart'; // Import your new manager
import 'habit_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

const uuid = Uuid();
class _DashboardScreenState extends State<DashboardScreen> {
  List<Habit> myHabits = [];
  final TextEditingController _habitController = TextEditingController();

  // 2. Override initState to load data when the screen opens
  @override
  void initState() {
    super.initState();
    _loadHabits();
  }
  // 3. The Load Logic 
  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsString = prefs.getString('saved_habits');
    
    if (habitsString != null) {
      final List<dynamic> decoded = jsonDecode(habitsString);
      setState(() {
        // Convert the JSON list back into Habit objects!
        myHabits = decoded.map((item) => Habit.fromjson(item)).toList();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // WATCH THE STATE: This tells the UI to rebuild anytime notifyListeners() is called!
    final habitProvider = context.watch<HabitProvider>();
    final myHabits = habitProvider.habits; // Grab the list from the provider

    return Scaffold(
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

        },
      ),
    
    );
    }
}