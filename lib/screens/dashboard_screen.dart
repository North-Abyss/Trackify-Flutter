//dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding
import '../models/habit.dart';
import '../widgets/habit_card.dart'; 
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

  // 4. The Save Logic
  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert Habit objects to Maps, then to a JSON String!
    final String encoded = jsonEncode(myHabits.map((h) => h.toMap()).toList());
    await prefs.setString('saved_habits', encoded);
  }

  @override
  Widget build(BuildContext context) {
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
              setState(() {
                myHabits.removeAt(index); // Remove it from the Dart List!
              });
              _saveHabits();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${habit.name} deleted')),
              );
            },
            
            child: GestureDetector(
              onTap: () {
                setState(() {
                  myHabits[index].completed = !myHabits[index].completed;
                });
                _saveHabits();
              },

              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Pass the habit object directly. No Parcelable needed!
                    builder: (context) => HabitDetailScreen(habit: habit),
                  ),
                );
              },

              child: HabitCard(
                title: habit.name, 
                isCompleted: habit.completed,
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {

          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                // Padding so it doesn't hug the edges
                padding: const EdgeInsets.all(20.0), 
                child: Column(
                  children: [
                    TextField(
                      controller: _habitController,
                      decoration: const InputDecoration(
                        labelText: 'Enter new habit', border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20), // A little spacing
                    
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          myHabits.add(Habit(id: uuid.v4(),name: _habitController.text)); 
                        });
                        _saveHabits();
                        _habitController.clear(); 
                        Navigator.pop(context); 
                      },
                      child: const Text('Save Habit'),
                    )
                  ],
                ),
              );
            }
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
    }
}