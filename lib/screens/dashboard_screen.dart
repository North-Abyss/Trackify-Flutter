//dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../widgets/habit_card.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

const uuid = Uuid();
class _DashboardScreenState extends State<DashboardScreen> {
    final List<Map<String, dynamic>> myHabits = [
    {"id": uuid.v4(),"name": "Drink 2L Water", "completed": true},
    {"id": uuid.v4(),"name": "Workout for 30 Mins", "completed": false},
    {"id": uuid.v4(),"name": "Meditate", "completed": true},
    {"id": uuid.v4(),"name": "Read 10 Pages", "completed": false},
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
          
          return Dismissible(
            key: Key(habit["id"]), 

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
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${habit["name"]} deleted')),
              );
            },
            
            child: GestureDetector(
              onTap: () {
                setState(() {
                  myHabits[index]["completed"] = !myHabits[index]["completed"];
                });
              },
              child: HabitCard(
                title: habit["name"], 
                isCompleted: habit["completed"],
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
                          myHabits.add({ "id": uuid.v4(),"name": _habitController.text, "completed": false });
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