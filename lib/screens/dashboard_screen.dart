//dashboard_screen.dart

import 'package:flutter/material.dart';
import '../widgets/habit_card.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
    final List<Map<String, dynamic>> myHabits = [
    {"name": "Drink 2L Water", "completed": true},
    {"name": "Read 10 Pages", "completed": false},
    {"name": "Workout for 30 Mins", "completed": false},
    {"name": "Meditate", "completed": true},
  ];
  final TextEditingController _habitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('Trackify Dashboard')),
      
      body: ListView.builder(
        itemCount: myHabits.length,
        itemBuilder: (context, index) {
          final habit = myHabits[index];
          
          return GestureDetector(//button functionality: toggles completion status on tap
            onTap: () {
              setState(() {
                myHabits[index]["completed"] = !myHabits[index]["completed"];
              });
            },
            child: HabitCard(
              title: habit["name"], isCompleted: habit["completed"],
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
                          myHabits.add({ "name": _habitController.text, "completed": false });
                        });
                        
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